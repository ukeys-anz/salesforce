/**
 * @author Ankit Garg
 * @since  19/July/2023
 * @group MLCRM (Moblie Lending CRM)
 * @description MLCRMOpportunityActions is class to handle all the MLCRM Opportunity Actions
 */
public with sharing class MLCRMOpportunityActions {
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }
  /**
   * @description validate MLCRM Opportunity
   * 1. CC-4528 validate opporutnity that it can't be closed unless all associated tasks are marked either as 'completed' or 'not required'.
   * @name validateMLCRMOpprtunity
   * @param newOppList list of new records
   * @param oldOppMap map of old records
   */
  public static void validateMLCRMOpportunity(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    Map<Id, Opportunity> closingOppMap = new Map<Id, Opportunity>();
    for (Opportunity opp : newOppList) {
      //CC-4528 validate opporutnity that it can't be closed unless all associated tasks are marked either as 'completed' or 'not required'.
      if (
        opp.RecordTypeId == MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID &&
        oldOppMap != null &&
        opp.StageName != oldOppMap.get(opp.Id).StageName &&
        (opp.StageName.equalsIgnoreCase(MLCRMConstants.STAGE_CLOSED) ||
        opp.StageName.equalsIgnoreCase(MLCRMConstants.STAGE_LOST))
      ) {
        closingOppMap.put(opp.id, opp);
      }
    }
    if (!closingOppMap.isEmpty()) {
      CCRMOpportunityActions.checkOpportunityHasOpenTaskBeforeStageChange(
        closingOppMap,
        new Map<Id, Opportunity>()
      );
    }
  }

  /**
   * @description called from create Propect from opportunity lwc component
   * @name createProspectFromOpportunity
   * @param requestPayload wrapper of request payload to be sent to OCV
   * @param oppId current record opportunity Id
   * @param strRole Role that user selects on create prospect UI.
   * @return MaintainPartyInfoWrapper wrapper of response returned from OCV.
   */
  @AuraEnabled(cacheable=false)
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper createProspectFromOpportunity(
    String requestPayload,
    String oppId,
    String strRole
  ) {
    DCRMMaintainPartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainResult = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
    OCVRequestPayloadWrapper requestRecord = (OCVRequestPayloadWrapper) JSON.deserialize(
      requestPayload,
      OCVRequestPayloadWrapper.class
    );
    requestRecord.strOwnerId = getOpportunity(new Set<ID>{ oppId })[0].OwnerId;
    requestRecord.strRecordId = oppId;
    requestRecord = setRemainingRequestValues(requestRecord);
    try {
      result = ccrmapi.maintainParty(requestRecord);
      if (result.ocvId != null && result.newCustomer == 'true') {
        Account accInstance = CCRMLeadConversionActionsHelper.autoCreateShellProspect(
          requestRecord,
          result
        );

        createOppContactRoleForCustomer(accInstance.Id, oppId, strRole);
        maintainResult.isNewCustomer = true;
      } else if (result.ocvId != null && result.newCustomer == 'false') {
        maintainResult = CCRMLeadConversionActionsHelper.getMaintainPartyExistingCustomerDetails(
          requestRecord,
          result
        );
      }
      return maintainResult;
    } catch (CustomException e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description called from create Prospect from opportunity lwc component
   * @name createProspectForCustomer
   * @param strRecordId personcontactId
   * @param oppId current record opportunity Id
   * @param strRole Role that user selects on create prospect UI.
   */
  @AuraEnabled(cacheable=false)
  public static void createOppContactRoleForCustomer(
    String strRecordId,
    String oppId,
    String strRole
  ) {
    OpportunityCreateShellProspect objInnerClass = new OpportunityCreateShellProspect();
    objInnerClass.createProspect(strRecordId, oppId, strRole);
  }

  /**
   * @description called from create Propect from opportunity lwc component
   *              without sharing due to new shell prospect won't be shared to current
   *              user for further querying until after the current transaction
   */
  private without sharing class OpportunityCreateShellProspect {
    /**
     * @description called from create Propect from opportunity lwc component
     * @name createProspect
     * @param accId personcontactId
     * @param oppId current record opportunity Id
     * @param strRole Role that user selects on create prospect UI.
     */
    private void createProspect(String accId, String oppId, String strRole) {
      Account objShellAccount = [
        SELECT PersoncontactId
        FROM Account
        WHERE Id = :accId
      ];
      OpportunityContactRole objContactRole = new OpportunityContactRole(
        opportunityId = oppId,
        ContactId = objShellAccount.PersoncontactId,
        Role = strRole
      );
      try {
        insert objContactRole;
      } catch (CustomException e) {
        Logger.error(e.getMessage());
        Logger.saveLog();
        throw new AuraHandledException(e.getMessage());
      }
    }
  }

  /**
   * @description This method to query Opportunity details along with customer details
   * @name getOpportunity
   * @param oppIds Set of Lead Ids
   * @return List<Opportunity>
   * @US CC-5314
   */
  public static List<Opportunity> getOpportunity(Set<Id> oppIds) {
    return [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :oppIds];
  }

  /**
   * @description payload request to OCV
   * @name setRemainingRequestValues
   * @param record OCVRequestPayloadWrapper request record from lwc component.
   * @return record as OCVRequestPayloadWrapper
   */
  public static OCVRequestPayloadWrapper setRemainingRequestValues(
    OCVRequestPayloadWrapper record
  ) {
    record.isValidStreet = false;
    record.strStreet = '';
    record.strCity = '';
    record.strState = '';
    record.strCountry = '';
    record.strPostalCode = '';
    record.strHomePhone = '';
    record.strWorkPhone = '';
    record.strGender = '';
    return record;
  }
}
