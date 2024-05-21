/**
 * @author Boobalakrishnan Duraisamy
 * @since  10/2022
 * @description CCRM lead conversion actions which includes calling search and create party api, deleting auto created contacts post conversion
 */

public with sharing class CCRMLeadConversionActions {
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }
  public static Boolean manualLeadConversionInitiated = false;
  public static Boolean leadConverionFlow = false;
  /**
   * @description Clear Task, OpportunityContactRole, and Contact of the newly converted Opportunity.
   * @name deleteContact
   * @param oppid The record Id of Opportunity
   * @param conid The record Id of Contact
   */
  public static void deleteAutoCreatedContact(Id oppid, Id conid) {
    updateTasks(oppid, conid);

    Contact leadContact = [
      SELECT Id, RecordTypeId
      FROM Contact
      WHERE Id = :conid
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (
      !Schema.sObjectType.Contact.isDeletable() &&
      !Schema.sObjectType.OpportunityContactRole.isDeletable()
    ) {
      return;
    }

    Database.DeleteResult result = Database.delete(leadContact, false);
    if (!result.isSuccess()) {
      Logger.error(
        'Error occured while deleting contact record during lead conversion.',
        result
      );
      Logger.saveLog();
    }
  }

  /**
   * @description Remove Contact from Task
   * @name updateTasks
   * @param oppid The record Id of Opportunity
   * @param conid The record Id of Contact
   */
  private static void updateTasks(Id oppid, Id conid) {
    List<Task> newTasks = new List<Task>();
    for (Task task : [
      SELECT subject, whoid
      FROM Task
      WHERE WhoId = :conid
      WITH SECURITY_ENFORCED
    ]) {
      if (task.WhoId == conid) {
        task.WhoId = null;
        task.WhatId = oppid;
        newTasks.add(task);
      }
    }
    if (
      !newTasks.isEmpty() &&
      Schema.sObjectType.Task.isUpdateable() &&
      Schema.sObjectType.Task.fields.WhoId.isUpdateable() &&
      Schema.sObjectType.Task.fields.WhatId.isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.update(newTasks, false);
      Logger.error(
        'Error occured while updating tasks during lead conversion',
        results
      );
      Logger.saveLog();
    }
  }

  /**
   * @param record Lead record from lwc component.
   * @return CCRMSearchPartyInfo for lwc
   * @description called from lead conversion lwc component
   */
  @AuraEnabled(cacheable=false)
  public static CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper searchPartyInfoLWC(
    Lead record
  ) {
    CCRMSearchPartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper searchPartyWrapper;
    Set<String> externalIds = new Set<String>();
    try {
      result = ccrmapi.searchPartyInfo(record);
      externalIds.addAll(populateExternalIds(result.certifiedResults));
      externalIds.addAll(populateExternalIds(result.probableResults));
      searchPartyWrapper = populatePartyDetails(externalIds, result);
    } catch (Exception e) {
      Logger.error('Error occured during search', record.Id, e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
    return searchPartyWrapper;
  }

  /**
   * @param externalIds set of unique ids to query from salesforce database
   * @param result response data from callout
   * @return CCRMSearchPartyInfoWrapper for lwc
   * @description populate party details and return to lwc component
   */
  public static CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper populatePartyDetails(
    Set<String> externalIds,
    CCRMSearchPartyModel result
  ) {
    CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper searchPartyWrapper = new CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper();
    searchPartyWrapper.probableAndCertifiedResults = new List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo>();
    Map<String, Account> accountIdMap = new Map<String, Account>();
    for (Account acc : [
      SELECT Id, External_Id__c, Name
      FROM Account
      WHERE External_Id__c IN :externalIds
      WITH SECURITY_ENFORCED
    ]) {
      accountIdMap.put(acc.External_Id__c, acc);
    }
    searchPartyWrapper.probableAndCertifiedResults.addAll(
      populateSearchPartyWrapper(
        result.certifiedResults,
        accountIdMap,
        'certified'
      )
    );
    searchPartyWrapper.probableAndCertifiedResults.addAll(
      populateSearchPartyWrapper(
        result.probableResults,
        accountIdMap,
        'probable'
      )
    );
    return searchPartyWrapper;
  }

  /**
   * @param searchPartyResultList search party list of result from the API, either certified or probable result
   * @param accountIdMap map of accounts with key as external id
   * @param resultType type of result - cer
   * @return CCRMSearchPartyInfo returns search party wrapper for lwc component
   * @description populates search party wrapper used in lwc component
   */
  private static List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo> populateSearchPartyWrapper(
    List<CCRMSearchPartyModel.CustomerDetails> searchPartyResultList,
    Map<String, Account> accountIdMap,
    String resultType
  ) {
    List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo> searchPartyInfoList = new List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo>();
    for (
      CCRMSearchPartyModel.CustomerDetails searchPartyResult : searchPartyResultList
    ) {
      String externalId = generateExternalId(searchPartyResult);
      if (accountIdMap.containsKey(externalId)) {
        CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo rec = new CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo();
        rec.id = accountIdMap.get(externalId).Id;
        rec.ocvId = searchPartyResult.ocvId;
        rec.name = accountIdMap.get(externalId).Name;
        rec.suburb = searchPartyResult.addresses != null
          ? searchPartyResult.addresses[0].city
          : null;
        rec.postCode = searchPartyResult.addresses != null
          ? searchPartyResult.addresses[0].postalCode
          : null;
        rec.cpid = searchPartyResult.cpId;
        rec.kycStatus = searchPartyResult.kycDetails?.status;
        rec.match = resultType;
        searchPartyInfoList.add(rec);
      }
    }
    return searchPartyInfoList;
  }

  /**
   * @param searchPartyResults search party results from the API.
   * @return Set<String> set of external Ids
   * @description called to populate external ids which will be used to account records in salesforce
   */
  private static Set<String> populateExternalIds(
    List<CCRMSearchPartyModel.CustomerDetails> searchPartyResults
  ) {
    Set<String> externalIds = new Set<String>();
    for (
      CCRMSearchPartyModel.CustomerDetails searchPartyResult : searchPartyResults
    ) {
      externalIds.add(generateExternalId(searchPartyResult));
    }
    return externalIds;
  }

  /**
   * @param searchPartyResult search party result from the API, either certified or probable result
   * @return String external Id which is a combination of source system name and source system id
   * @description used to generate external id which will be used to query account object
   */
  private static String generateExternalId(
    CCRMSearchPartyModel.CustomerDetails searchPartyResult
  ) {
    return searchPartyResult.sourceSystems[0].sourceSystemName +
      '_' +
      searchPartyResult.sourceSystems[0].sourceSystemId;
  }

  /**
   * @description called from lead conversion lwc component
   * @name createPartyLWC
   * @param record Lead record from lwc component.
   * @return new oportunity id
   */
  @AuraEnabled(cacheable=false)
  public static String createPartyLWC(Lead record) {
    CCRMCreatePartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      result = ccrmapi.createParty(record);
      return CCRMLeadConversionActionsHelper.updateLeadWithCapcisIdOrg(
        record,
        result
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description called from lead conversion lwc component
   * @name maintainPartyLWC
   * @param record Lead record from lwc component.
   * @return MaintainPartyInfoWrapper new oportunity id
   */
  @AuraEnabled(cacheable=false)
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyLWC(
    Lead record
  ) {
    DCRMMaintainPartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainResult = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
    OCVRequestPayloadWrapper requestRecord = CCRMLeadConversionActionsHelper.getRequestRecord(
      record
    );
    try {
      result = ccrmapi.maintainParty(requestRecord);
      if (result.newCustomer == null) {
        // Throw custom exception
        CCRMLeadConversionActionsHelper.handleError(
          Label.MLCRM_MaintainParty_NewCustomerError,
          record.Id
        );
      }
      if (result.ocvId != null && result.newCustomer == 'true') {
        Account accInstance = CCRMLeadConversionActionsHelper.autoCreateShellProspect(
          requestRecord,
          result
        );
        maintainResult.oppID = '';
        maintainResult.isNewCustomer = true;
        if (accInstance != null) {
          String opptId = CCRMLeadConversionActionsHelper.updateLeadWithCapcisIdIndividual(
            record,
            result,
            accInstance
          );
          maintainResult.oppID = opptId;
        } else {
          maintainResult.oppID = '';
          // Throw custom exception
          CCRMLeadConversionActionsHelper.handleError(
            'Shell Customer Creation Failure.',
            record.Id
          );
        }
      } else if (result.ocvId != null && result.newCustomer == 'false') {
        maintainResult = CCRMLeadConversionActionsHelper.getMaintainPartyExistingCustomerDetails(
          requestRecord,
          result
        );
      }
      return maintainResult;
    } catch (CustomException e) {
      Logger.error(e.getMessage() + record.Id);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Convert CCRM Lead
   * @name convertCCRMLead
   * @param accId get account id created/matched for lead conversion
   * @param leadRec The Lead records created/matched for lead conversion
   * @return string  opportunity id created/matched for lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String convertCCRMLead(String accId, Lead leadRec) {
    if (String.isBlank(accId)) {
      throw new AuraHandledException(
        Label.MLCRM_AccountBlank_LeadConversionError
      );
    }
    try {
      if (
        !CCRMLeadConversionActions.leadConverionFlow &&
        leadRec.RecordType.DeveloperName ==
        MLCRMConstants.MLCRM_LEAD_RECORDTYPE_NAME
      ) {
        //Added to bypass validation rule preventEditShellProspect on Account Trigger (Error: Label.ML_ShellProspect_Update_ErrorMessage)
        CCRMLeadConversionActions.manualLeadConversionInitiated = true;
        CustomerRelationNotesTriggerActions.CustomerRelationshipCreator custRelationCreator = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
        custRelationCreator.createCustomerRelationship(
          accId,
          CCRMLeadConversionActionsHelper.getRequestRecord(leadRec)
        );
      }
      CCRMLeadConversionActions.leadConverionFlow = true;
      return AccountCommonActions.findAndConvertCCRMLead(accId, leadRec);
    } catch (Exception ex) {
      Logger.error('Error occured during lead conversion', leadRec.Id, ex);
      Logger.saveLog();
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /**
   * @description Convert MLCRM Lead for matched maintain party Existing Customer
   * @name convertLeadWithMatchedParty
   * @param accId get account id matched for lead conversion
   * @param cpId get cpid from ocv reponse
   * @param leadRec The Lead record to convert
   * @return string  opportunity id created from lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String convertLeadWithMatchedParty(
    String accId,
    String cpId,
    Lead leadRec
  ) {
    if (String.isBlank(accId)) {
      throw new AuraHandledException(
        Label.MLCRM_AccountBlank_LeadConversionError
      );
    }
    if (String.isBlank(cpId)) {
      throw new AuraHandledException(
        Label.MLCRM_CAPCISIdBlank_LeadConversionError
      );
    }
    try {
      CCRMLeadConversionActions.leadConverionFlow = true;
      Boolean isLeadUpdated = CCRMLeadConversionActionsHelper.updateLeadWithMaintainPartyInfo(
        accId,
        cpId,
        leadRec
      );
      if (isLeadUpdated) {
        return AccountCommonActions.findAndConvertCCRMLead(accId, leadRec);
      } else {
        return null;
      }
    } catch (Exception ex) {
      Logger.error(eX.getMessage() + leadRec.Id);
      Logger.saveLog();
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /**
   * @description Checks if Lead details is mis-match with Customer details
   * @name isLeadMisMatchCustomer
   * @param recordId The record id of selected Lead.
   * @return String The Fields which are mismatched
   */
  @AuraEnabled(cacheable=false)
  public static String isLeadMisMatchCustomer(Id recordId) {
    List<Lead> leads = new List<Lead>();
    Map<Id, String> mismtachLeadsWithFieldsMap = new Map<Id, String>();
    if (recordId != null) {
      leads = MLCRMAutoTaskOnLeadConversionHelper.getLeads(
        new Set<ID>{ recordId }
      );
    }
    if (!leads.isEmpty()) {
      mismtachLeadsWithFieldsMap = MLCRMAutoTaskOnLeadConversionHelper.checkLeadMisMatchCustomer(
        leads
      );
    }
    if (mismtachLeadsWithFieldsMap.containsKey(recordId)) {
      return mismtachLeadsWithFieldsMap.get(recordId);
    }
    return null;
  }
}
