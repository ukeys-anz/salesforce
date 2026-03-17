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
  private static final CustomerRelationshipsRepository CR_REPOSITORY = (CustomerRelationshipsRepository) Lib_InstanceProvider.forType(
    CustomerRelationshipsRepository.class
  );

  private static final String STR_GUARANTOR = 'Guarantor';
  private static final String STR_APPLICANT = 'Applicant';
  private static final String STAGE_CLOSED = 'Closed';
  private static final String STAGE_LOST = 'Lost';
  @testVisible
  private static final String DUPLICATE_LAR_ERROR = 'This Loanapp Reference is already linked to an Opportunity. Check the Loanapp Reference is correct and De-link from the other opportunity before proceeding.';

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }
  /**
   * @description validate Opportunity during closure
   * 1. CC-4528 validate opporutnity that it can't be closed unless all associated tasks are marked either as 'completed' or 'not required'.
   * @name validateClosedOpportunity
   * @param newOppList list of new records
   * @param oldOppMap map of old records
   */
  public static void validateClosedOpportunity(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    List<Opportunity> filteredOpportunities = ListUtil.filter(
        newOppList,
        oldOppMap
      )
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
    List<Opportunity> lstOfOpptyCreatedDirectly = ListUtil.filter(newOppList)
      .equals(Opportunity.Lead_Converted__c, false)
      .toList();
    Map<Id, Account> mapOfAcc = getAccountsFromOpportunities(
      lstOfOpptyCreatedDirectly
    );
    List<OpportunityContactRole> lstPrimaryApplicantContactRole = prepareOpportunityContactRoles(
      lstOfOpptyCreatedDirectly,
      mapOfAcc,
      null
    );
    DML_REPOSITORY.doInsert(
      lstPrimaryApplicantContactRole,
      new DmlConfig().allowPartial()
    );
  }

  /**
   * @description This method is used to update role of applicant or insert a new role on change of customer on opportunity
   * @name updatePrimaryApplicantOnUpdate
   * @param records list of Opportunity sobject records
   * @param oldOppMap map of old opportunity sobject records
   * @US CC-10213
   */
  public static void updatePrimaryApplicantOnUpdate(
    List<Opportunity> records,
    Map<Id, Opportunity> oldOppMap
  ) {
    List<Opportunity> filteredRecords = ListUtil.filter(records, oldOppMap)
      .changed(Opportunity.AccountId)
      .toList();
    Set<Id> idsOfOpp = ListUtil.getIds(filteredRecords, Opportunity.Id);
    List<OpportunityContactRole> lstOfOppContactRole = OPP_ROLE_REPOSITORY.getOppContactRole(
      idsOfOpp
    );
    Map<String, OpportunityContactRole> mapOfOppContactRole = prepareMapOfContactRoleByAccountId(
      lstOfOppContactRole
    );
    Map<Id, Account> mapOfAcc = getAccountsFromOpportunities(filteredRecords);

    List<OpportunityContactRole> lstOfOppContactRoleToUpsert = new List<OpportunityContactRole>();
    lstOfOppContactRoleToUpsert.addAll(
      updateRoleForExistingOCR(filteredRecords, mapOfOppContactRole)
    );
    lstOfOppContactRoleToUpsert.addAll(
      prepareOpportunityContactRoles(
        filteredRecords,
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
    Set<Id> accountIds = ListUtil.getIds(lstOfOpp, Opportunity.AccountId);
    return ACCOUNT_REPOSITORY.getAccountByIds(accountIds);
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
  public static MaintainPartyInformationWrapper.MaintainPartyResult createProspectFromOpportunity(
    String requestPayload,
    String oppId,
    String strRole
  ) {
    MaintainPartyModel result;
    PartyAPIRepository partyApi = new PartyAPIRepository();
    MaintainPartyInformationWrapper.MaintainPartyResult maintainResult = new MaintainPartyInformationWrapper.MaintainPartyResult();
    OCVRequestPayloadWrapper requestRecord = (OCVRequestPayloadWrapper) JSON.deserialize(
      requestPayload,
      OCVRequestPayloadWrapper.class
    );
    requestRecord.strOwnerId = getOpportunity(new Set<ID>{ oppId })[0].OwnerId;
    requestRecord.strRecordId = oppId;
    requestRecord = setRemainingRequestValues(requestRecord);
    Boolean shellProspectRequired = false;
    String externalId;
    ShellProspectInfoWrapper shellProspectInfoInstance;
    maintainResult.retrievePartyRequired = false;
    try {
      result = partyApi.maintainParty(requestRecord);
      if (result.ocvId == null) {
        // Throw custom exception
        LeadConversionHelper.handleError(
          Label.MLCRM_CAPCISIdBlank_LeadConversionError,
          oppId
        );
      }
      if (result.newCustomer == 'false') {
        shellProspectInfoInstance = LeadConversionHelper.getMaintainPartyInfo(
          result
        );
        externalId = LeadConversionController.getExternalId(
          shellProspectInfoInstance
        );
        maintainResult = LeadConversionHelper.populateMaintainPartyDetails(
          externalId,
          shellProspectInfoInstance,
          requestRecord
        );
        if (!maintainResult.matchedResults.isEmpty()) {
          return maintainResult;
        }
        shellProspectRequired = true;
        maintainResult.retrievePartyRequired = true;
      }
      // is a shell prospect need to be created?
      if ((result.newCustomer == 'true') || shellProspectRequired) {
        Account accInstance = LeadConversionHelper.autoCreateShellProspect(
          requestRecord,
          result
        );
        CustomerRelationNotesTriggerActions.createCustomerRelationship(
          accInstance.Id,
          requestRecord
        );
        if (result.newCustomer == 'true') {
          createOppContactRoleForCustomer(accInstance.Id, oppId, strRole);
          maintainResult.isNewCustomer = true;
        } else {
          //fetch the customer information for matched existing customer after shell prospect creation
          maintainResult = LeadConversionHelper.populateMaintainPartyDetails(
            externalId,
            shellProspectInfoInstance,
            requestRecord
          );
          maintainResult.retrievePartyRequired = true;
          maintainResult.isNewCustomer = false;
        }
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
    Account objShellAccount = OPPACTION_REPOSITORY.getAccount(strRecordId);
    OpportunityContactRole objContactRole = new OpportunityContactRole(
      opportunityId = oppId,
      ContactId = objShellAccount.PersoncontactId,
      Role = strRole
    );
    try {
      DML_REPOSITORY.doInsert(
        objContactRole,
        new DmlConfig().systemMode().withoutSharing()
      );
    } catch (CustomException e) {
      Logger.error(
        'Error Occured while creating Opportunity Contact Role record! ' +
        e.getMessage(),
        e
      );
      Logger.saveLog();
      throw new AuraHandledException(
        'Error Occured while creating Opportunity Contact Role record!'
      );
    }
  }

  /**
   * @description This method is used to throw an error on duplicate Loanapp_Reference__c
   * @name preventDuplicateLoanappReferenceNumber
   * @param lstOfOpp list of Opportunity sobject records
   * @param oldOppMap map of old Opportunity sObject records
   */
  public static void preventDuplicateLoanappReferenceNumber(
    List<Opportunity> lstOfOpp,
    Map<Id, Opportunity> oldOppMap
  ) {
    Set<String> duplicateLARSetLowercase = new Set<String>();
    List<Opportunity> filteredOppList = ListUtil.filter(lstOfOpp, oldOppMap)
      .isNotNull(Opportunity.Loanapp_Reference__c)
      .changed(Opportunity.Loanapp_Reference__c)
      .toList();
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
        duplicateLARSetLowerCase.add(opp.Loanapp_Reference__c.toLowerCase());
        continue;
      }
      opp.addError(DUPLICATE_LAR_ERROR);
    }
  }

  /**
   * @description update the OwnerId with the  Opportunity_Owner__c field
   * @name transferOpportunityOwnership
   * @param newOppList List of new lead records.
   * @param oldOppMap Map of old lead records.
   */
  public static void transferOpportunityOwnership(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    List<Opportunity> filteredRecords = ListUtil.filter(newOppList, oldOppMap)
      .isNotNull(Opportunity.Opportunity_Owner__c)
      .changed(Opportunity.Opportunity_Owner__c)
      .toList();

    for (Opportunity record : filteredRecords) {
      record.OwnerId = record.Opportunity_Owner__c;
    }
  }

  /**
   * @description This method will validate and update Has_Close_Date_Changed__c.
   * @name setHasCloseDateChanged
   * @param records New opportunity records
   * @param oldMap Map of old Opportunity record
   */
  public static void setHasCloseDateChanged(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    List<Opportunity> filteredRecords = ListUtil.filter(records, oldMap)
      .equals(Opportunity.Has_Close_Date_Changed__c, false)
      .changed(Opportunity.CloseDate)
      .toList();
    ListUtil.setField(
      filteredRecords,
      Opportunity.Has_Close_Date_Changed__c,
      true
    );
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

  /**
   * @description update ocr sync records on loanapp reference change
   * @name updateOCRSyncRecordsOnLARChange
   * @param oppList opportunityRecords
   * @param oldMap set of Record Type ids
   */
  public static void updateOCRSyncRecordsOnLARChange(
    List<Opportunity> oppList,
    Map<Id, Opportunity> oldMap
  ) {
    List<Opportunity_Contact_Role_Sync__c> ocrSyncToUpdate = new List<Opportunity_Contact_Role_Sync__c>();
    List<Opportunity> filteredOpportunities = ListUtil.filter(oppList, oldMap)
      .isNotNull(Opportunity.Loanapp_Reference__c)
      .changed(Opportunity.Loanapp_Reference__c)
      .toList();
    Set<Id> oppIdSet = ListUtil.getIds(filteredOpportunities, Opportunity.Id);
    Map<Id, OpportunityContactRole> relatedOCRMap = new Map<Id, OpportunityContactRole>(
      OPPACTION_REPOSITORY.getOpportunityContactRolesByOppIds(oppIdSet)
    );
    List<Opportunity_Contact_Role_Sync__c> relatedOCRSyncList = OPPACTION_REPOSITORY.getOCRSyncByOCRIds(
      relatedOCRMap.keySet()
    );
    for (Opportunity_Contact_Role_Sync__c ocrSync : relatedOCRSyncList) {
      ocrSyncToUpdate.add(
        createOCRSyncInstance(
          relatedOCRMap.get(ocrSync.OpportunityContactRoleId__c),
          ocrSync
        )
      );
    }
    DML_REPOSITORY.doUpdate(ocrSyncToUpdate);
  }

  /**
   * @description create an instance for OCR Sync
   * @name createOCRSyncInstance
   * @param ocr ocr record
   * @param ocrSync ocr sync record
   * @return Opportunity_Contact_Role_Sync__c
   */
  private static Opportunity_Contact_Role_Sync__c createOCRSyncInstance(
    OpportunityContactRole ocr,
    Opportunity_Contact_Role_Sync__c ocrSync
  ) {
    if (ocr == null || ocrSync == null) {
      return null;
    }
    return new Opportunity_Contact_Role_Sync__c(
      Id = ocrSync.Id,
      ExternalId__c = ocr.ExternalId__c,
      OpportunityId__c = ocr.Opportunity.Loanapp_Reference__c
    );
  }

  /**
   * @description This method will update opoortunity name with the Name provided in the corresponding Account.
   * @name populateName
   * @param records from the trigger
   */
  public static void populateName(List<Opportunity> records) {
    List<Opportunity> filteredOpportunities = ListUtil.filter(records)
      .equals(Opportunity.Lead_Converted__c, true)
      .isNotNull(Opportunity.AccountId)
      .toList();
    Map<Id, Account> accountMap;
    Set<Id> accountIds = ListUtil.getIds(
      filteredOpportunities,
      Opportunity.AccountId
    );
    try {
      accountMap = OPPACTION_REPOSITORY.getAccountByIds(accountIds);
    } catch (System.QueryException e) {
      Logger.error('InsufficientAccessException', e).save();
    }
    for (Opportunity record : filteredOpportunities) {
      //CC-5603 Opportunity name should be account name for Mobile Lending Opportunity
      record.Name = accountMap.get(record.AccountId)?.Name;
    }
  }

  /**
   * @description This method will auto create customer relationship records.
   * @name createCustomerRelationshipRecords
   * @param opportunities from the trigger
   */
  public static void createCustomerRelationshipRecords(
    List<Opportunity> opportunities
  ) {
    //get non-lead converted opportunities
    List<Opportunity> nonLeadConvertedOpportunities = ListUtil.filter(
        opportunities
      )
      .equals(Opportunity.Lead_Converted__c, false)
      .toList();
    dedupeAndInsertCustomerRelationships(nonLeadConvertedOpportunities);
  }

  /**
   * @description This method will deduplicate and insert customer relationships.
   * @name dedupeAndInsertCustomerRelationships
   * @param nonLeadConvertedOpportunities opportunities that have been created manually
   */
  @testVisible
  private static void dedupeAndInsertCustomerRelationships(
    List<Opportunity> nonLeadConvertedOpportunities
  ) {
    //get set of account ids on opportunities
    Set<Id> oppCustomerIds = ListUtil.getIds(
      nonLeadConvertedOpportunities,
      Opportunity.AccountId
    );

    //query existing customer relationship records.
    List<Customer_Relationship__c> existingCustomerRelationships = CR_REPOSITORY.getCustomerRelationshipByCustomerIds(
      oppCustomerIds
    );

    Map<String, Customer_Relationship__c> existingCRRMap = OpportunityActionsHelper.getExistingCRRMap(
      existingCustomerRelationships
    );

    List<Customer_Relationship__c> crrsToInsert = OpportunityActionsHelper.insertCustomerRelationships(
      existingCRRMap,
      nonLeadConvertedOpportunities
    );
    DML_REPOSITORY.doInsert(
      crrsToInsert,
      new DmlConfig().allowPartial().withoutSharing().systemMode()
    );
  }

  /**
   * @description Remove Lost Reason fields when stage changed from Lost to other stage
   * @param records records to update
   * @param oldMap old records map
   */
  public static void revertLostReasonDetails(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    List<Opportunity> opptsUpdatedFromLost = ListUtil.filter(records, oldMap)
      .changedFrom(Opportunity.StageName, STAGE_LOST)
      .toList();

    ListUtil.setField(opptsUpdatedFromLost, Opportunity.Lost_Reason__c, null);
    ListUtil.setField(
      opptsUpdatedFromLost,
      Opportunity.Lost_Reason_Detail__c,
      null
    );
  }
}
