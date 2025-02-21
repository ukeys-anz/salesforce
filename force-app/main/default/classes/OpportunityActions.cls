/**
 * @author Ankit Garg
 * @since  19/July/2023
 * @group MLCRM (Moblie Lending CRM)
 * @description OpportunityActions is class to handle all the MLCRM Opportunity Actions
 */
public with sharing class OpportunityActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final OpportunityActionsRepository OPPACTION_REPOSITORY = (OpportunityActionsRepository) Lib_InstanceProvider.forType(
    OpportunityActionsRepository.class
  );
  private static final OpportunityContactRoleActionsRepository OPP_ROLE_REPOSITORY = (OpportunityContactRoleActionsRepository) Lib_InstanceProvider.forType(
    OpportunityContactRoleActionsRepository.class
  );
  private static final AccountActionsRepository ACCOUNT_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );

  private static final String STR_GUARANTOR = 'Guarantor';
  private static final String STR_APPLICANT = 'Applicant';
  private static final String STAGE_CLOSED = 'Closed';
  private static final String STAGE_LOST = 'Lost';
<<<<<<< HEAD
=======
  @testVisible
  private static final String DUPLICATE_LAR_ERROR = 'This Loanapp Reference is already linked to an Opportunity. Check the Loanapp Reference is correct and De-link from the other opportunity before proceeding.';
>>>>>>> develop

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
    List<Opportunity> filteredOpportunities = ListUtil.filter(
        newOppList,
        oldOppMap
      )
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .changed(Opportunity.StageName)
      .equals(
        Opportunity.StageName,
        new Set<String>{ STAGE_CLOSED, STAGE_LOST }
      )
      .toList();
    Map<Id, Opportunity> closingOppMap = (Map<Id, Opportunity>) ListUtil.mapBy(
      filteredOpportunities,
      Opportunity.Id
    );
    CommercialOpportunityHelper.checkOpenTaskForClosedOpportunities(
      closingOppMap
    );
  }

  /**
   * @description This method is used to create opportunity contact role record on insert
   * @name createOpportunityContactRole
   * @param newOppList list of Opportunity sobject records
   * @US CC-10213
   */
  public static void createOpportunityContactRole(
    List<Opportunity> newOppList
  ) {
    List<Opportunity> lstOfMlOppty = ListUtil.filter(newOppList)
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .toList();
    if (lstOfMlOppty.isEmpty()) {
      return;
    }
    List<Opportunity> lstOfMlOpptyCreatedDirectly = ListUtil.filter(
        lstOfMlOppty
      )
      .equals(Opportunity.Lead_Converted__c, false)
      .toList();
    if (lstOfMlOpptyCreatedDirectly.isEmpty()) {
      return;
    }
    Map<Id, Account> mapOfAcc = getAccountsFromOpportunities(
      lstOfMlOpptyCreatedDirectly
    );
    List<OpportunityContactRole> lstPrimaryApplicantContactRole = prepareOpportunityContactRoles(
      lstOfMlOpptyCreatedDirectly,
      mapOfAcc,
      null
    );
    DML_REPOSITORY.doInsert(lstPrimaryApplicantContactRole);
  }

  /**
   * @description This method is used to update role of applicant or insert a new role on change of customer on opportunity
   * @name updatePrimaryApplicantOnUpdate
   * @param newOppList list of Opportunity sobject records
   * @param oldOppMap map of old opportunity sobject records
   * @US CC-10213
   */
  public static void updatePrimaryApplicantOnUpdate(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    List<Opportunity> lstOfMlOppty = ListUtil.filter(newOppList)
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .toList();
    if (lstOfMlOppty.isEmpty()) {
      return;
    }
    List<Opportunity> lstOfOppsAcctUpd = ListUtil.filter(
        lstOfMlOppty,
        oldOppMap
      )
      .changed(Opportunity.AccountId)
      .toList();
    if (lstOfOppsAcctUpd.isEmpty()) {
      return;
    }

    Set<Id> idsOfOpp = ListUtil.getIds(
      lstOfOppsAcctUpd,
      Opportunity.Id.getDescribe().getSObjectField()
    );
    List<OpportunityContactRole> lstOfOppContactRole = OPP_ROLE_REPOSITORY.getOppContactRole(
      idsOfOpp
    );
    Map<String, OpportunityContactRole> mapOfOppContactRole = prepareMapOfContactRoleByAccountId(
      lstOfOppContactRole
    );
    Map<Id, Account> mapOfAcc = getAccountsFromOpportunities(lstOfOppsAcctUpd);

    List<OpportunityContactRole> lstOfOppContactRoleToUpsert = new List<OpportunityContactRole>();
    lstOfOppContactRoleToUpsert.addAll(
      updateRoleForExistingOCR(lstOfOppsAcctUpd, mapOfOppContactRole)
    );
    lstOfOppContactRoleToUpsert.addAll(
      prepareOpportunityContactRoles(
        lstOfOppsAcctUpd,
        mapOfAcc,
        mapOfOppContactRole
      )
    );
    DML_REPOSITORY.doUpsert(lstOfOppContactRoleToUpsert);
  }

  /**
   * @description This method is used to prepare map of contact role by accountId
   * @name prepareMapOfContactRoleByAccountId
   * @param lstOfOppContactRole list of Opportunity contact role sobject records
   * @return Map<Id,OpportunityContactRole> map of Opportunity contact role sobject records
   * @US CC-10213
   */
  @testVisible
  private static Map<String, OpportunityContactRole> prepareMapOfContactRoleByAccountId(
    List<OpportunityContactRole> lstOfOppContactRole
  ) {
    Map<String, OpportunityContactRole> mapOfOppContactRole = new Map<String, OpportunityContactRole>();
    for (OpportunityContactRole objRole : lstOfOppContactRole) {
      mapOfOppContactRole.put(
        String.valueOf(objRole.opportunityId) +
        String.valueOf(objRole.contact.AccountId),
        objRole
      );
    }
    return mapOfOppContactRole;
  }

  /**
   * @description This method is used to get accountid from opportunity
   * @name getAccountsFromOpportunities
   * @param lstOfOpp list of Opportunity sobject records
   * @return Map<Id, Account> map of account records
   * @US CC-10213
   */
  @testVisible
  private static Map<Id, Account> getAccountsFromOpportunities(
    List<Opportunity> lstOfOpp
  ) {
    Set<Id> idsOfOppAccountId = ListUtil.getIds(
      lstOfOpp,
      Opportunity.AccountId.getDescribe().getSObjectField()
    );
    return ACCOUNT_REPOSITORY.getAccountByIds(idsOfOppAccountId);
  }

  /**
   * @description This method is used to prepare opportunity contact based on whether applicant exists or not on opportunity.
   * @name updateRoleForExistingOCR
   * @param lstOfOpp list of Opportunity sobject records
   * @param mapOfOppContactRole map of OpportunityContactRole sobject records
   * @return List<OpportunityContactRole> list of OpportunityContactRole sobject records
   * @US CC-10213
   */
  @testVisible
  private static List<OpportunityContactRole> updateRoleForExistingOCR(
    List<Opportunity> lstOfOpp,
    Map<String, OpportunityContactRole> mapOfOppContactRole
  ) {
    List<OpportunityContactRole> lstofOppRole = new List<OpportunityContactRole>();

    for (Opportunity opp : lstOfOpp) {
      OpportunityContactRole existingRole = mapOfOppContactRole.get(
        String.valueOf(opp.Id) + String.valueOf(opp.AccountId)
      );
      if (
        existingRole != null &&
        (existingRole.Role == STR_GUARANTOR ||
        existingRole.Role == null)
      ) {
        OpportunityContactRole objRole = new OpportunityContactRole();
        objRole.Role = STR_APPLICANT;
        objRole.Id = existingRole.Id;
        lstofOppRole.add(objRole);
      }
    }
    return lstofOppRole;
  }

  /**
   * @description This method is used to prepare opportunity contact based on whether applicant exists or not on opportunity.
   * @name prepareOpportunityContactRoles
   * @param lstOfOpp list of Opportunity sobject records
   * @param mapOfAcc map of Opportunity sobject records
   * @param mapOfOppContactRole map of OpportunityContactRole sobject records
   * @return List<OpportunityContactRole> list of OpportunityContactRole sobject records
   * @US CC-10213
   */
  @testVisible
  private static List<OpportunityContactRole> prepareOpportunityContactRoles(
    List<Opportunity> lstOfOpp,
    Map<Id, Account> mapOfAcc,
    Map<String, OpportunityContactRole> mapOfOppContactRole
  ) {
    List<OpportunityContactRole> lstofOppRole = new List<OpportunityContactRole>();

    for (Opportunity opp : lstOfOpp) {
      if (
        mapOfOppContactRole == null ||
        mapOfOppContactRole.get(
          String.valueOf(opp.Id) + String.valueOf(opp.AccountId)
        ) == null
      ) {
        lstofOppRole.add(
          new OpportunityContactRole(
            opportunityId = opp.Id,
            contactId = mapOfAcc.get(opp.accountId).PersonContactId,
            Role = STR_APPLICANT
          )
        );
      }
    }
    return lstofOppRole;
  }

  /**
   * @description called from create Propect from opportunity lwc component
   * @name createProspectFromOpportunity
   * @param requestPayload wrapper of request payload to be sent to OCV
   * @param oppId current record opportunity Id
   * @param strRole Role that user selects on create prospect UI.
   * @return MaintainPartyResult wrapper of response returned from OCV.
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
      if (result.ocvId == null) {
        // Throw custom exception
        CCRMLeadConversionActionsHelper.handleError(
          Label.MLCRM_CAPCISIdBlank_LeadConversionError,
          oppId
        );
      }
      if (result.newCustomer == 'true') {
        Account accInstance = CCRMLeadConversionActionsHelper.autoCreateShellProspect(
          requestRecord,
          result
        );
        CustomerRelationNotesTriggerActions.CustomerRelationshipCreator custRelationCreator = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
        custRelationCreator.createCustomerRelationship(
          accInstance.Id,
          requestRecord
        );
        createOppContactRoleForCustomer(accInstance.Id, oppId, strRole);
        maintainResult.isNewCustomer = true;
      } else if (result.newCustomer == 'false') {
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
    OpportunityContactRoleGenerator objInnerClass = new OpportunityContactRoleGenerator();
    objInnerClass.createOpportunityContactRole(strRecordId, oppId, strRole);
  }

  /**
<<<<<<< HEAD
=======
   * @description This method is used to throw an error on duplicate Loanapp_Reference__c
   * @name preventDuplicateLoanappReferenceNumber
   * @param lstOfOpp list of Opportunity sobject records
   * @param oldOppMap map of old Opportunity sObject records
   */
  public static void preventDuplicateLoanappReferenceNumber(
    List<Opportunity> lstOfOpp,
    Map<Id, Opportunity> oldOppMap
  ) {
    List<Opportunity> oppErrorList = new List<Opportunity>();
    Set<String> duplicateLARSetLowercase = new Set<String>();
    List<Opportunity> filteredOppList = getFilteredOpportunitiesForLoanappReferenceNumber(
      lstOfOpp,
      oldOppMap
    );
    Set<String> loanappRefNumSet = ListUtil.getStrings(
      filteredOppList,
      Opportunity.Loanapp_Reference__c
    );
    List<Opportunity> duplicateOppList = OPPACTION_REPOSITORY.getOpportunityByLoanappReference(
      loanappRefNumSet
    );
    for (
      String loanappRef : ListUtil.getStrings(
        duplicateOppList,
        Opportunity.Loanapp_Reference__c
      )
    ) {
      duplicateLARSetLowerCase.add(loanappRef.toLowerCase());
    }
    for (Opportunity opp : filteredOppList) {
      if (
        !duplicateLARSetLowerCase.contains(
          opp.Loanapp_Reference__c.toLowerCase()
        )
      ) {
        duplicateLARSetLowerCase.add(opp.Loanapp_Reference__c);
        continue;
      }
      oppErrorList.add(opp);
    }
    CommonUtil.raiseSobjectError(oppErrorList, DUPLICATE_LAR_ERROR);
  }

  /**
   * @description This method is used to filter Opportunities for Loanapp_Reference__c
   * @name getFilteredOpportunitiesForLoanappReferenceNumber
   * @param oppList list of Opportunity sobject records
   * @param oldOppMap map of old Opportunity sObject records
   * @return List<Opportunity>
   */
  public static List<Opportunity> getFilteredOpportunitiesForLoanappReferenceNumber(
    List<Opportunity> oppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    return ListUtil.filter(oppList, oldOppMap)
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .changed(Opportunity.Loanapp_Reference__c)
      .isNotNull(Opportunity.Loanapp_Reference__c)
      .toList();
  }

  /**
>>>>>>> develop
   * @description called from create Propect from opportunity lwc component
   *              without sharing due to new shell prospect won't be shared to current
   *              user for further querying until after the current transaction
   */
  private without sharing class OpportunityContactRoleGenerator {
    /**
     * @description called from create Propect from opportunity lwc component
     * @name createProspect
     * @param accId personcontactId
     * @param oppId current record opportunity Id
     * @param strRole Role that user selects on create prospect UI.
     */
    private void createOpportunityContactRole(
      String accId,
      String oppId,
      String strRole
    ) {
      Account objShellAccount = OPPACTION_REPOSITORY.getAccount(accId);
      OpportunityContactRole objContactRole = new OpportunityContactRole(
        opportunityId = oppId,
        ContactId = objShellAccount.PersoncontactId,
        Role = strRole
      );
      try {
        DML_REPOSITORY.doInsert(objContactRole, new DmlConfig().systemMode());
      } catch (CustomException e) {
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
    return OPPACTION_REPOSITORY.getOpportunity(oppIds);
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
    record.strAdvertisingIndicator = ''; //added as part of CC-6745
    return record;
  }
}
