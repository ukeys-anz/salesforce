/**
 *
 * @author David Dawson
 * @since 08/2020
 * @description Common Account Action methods
 */
public with sharing class AccountCommonActions {
  // Variable used to store the account Ids into which matching leads were converted into
  // This is used to revert the changes on accounts that resulted from lead conversion process
  private static Set<Id> convertedAccountIds = new Set<Id>();
  private static final String DELETED_IN_OCV_FLAG_ERROR_MSG = 'having multiple records with the Deleted_In_OCV__C flag set in a single transaction is not supported';
  @TestVisible
  private static final String CUSTOMER_LINKED_TO_KYC_QA_SUCCESS = 'Customer has been successfuly link to KYC QA Case.';
  @TestVisible
  private static final String CUSTOMER_LINKED_TO_KYC_QA_ERROR = 'Error occured while linking Customer to KYC QA Case.';
  @TestVisible
  public static Boolean forceDMLError = false; // This is to force a DML error to increase unit test coverage

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );

  /**
   * @description checkForAccountDeletion is called to check if the Deleted_In_OCV__c flag is updated for deletion
   * @param records The Account records passed from Trigger.new()
   */
  public static void checkForAccountDeletion(List<Account> records) {
    List<Account> accList = new List<Account>();

    for (Account acc : records) {
      if (acc.Deleted_In_OCV__c == true) {
        accList.add(acc);
      }
    }
    if (accList.size() == 1) {
      System.enqueuejob(new QueueAccountDeletion(accList[0]));
    } else if (accList.size() > 1) {
      for (Account acc : accList) {
        acc.addError(DELETED_IN_OCV_FLAG_ERROR_MSG);
      }
    }
  }

  /**
   * @description createEntitlement is called to create an entitlement for the account
   * @param records The Account records passed from Trigger.new()
   */
  public static void createEntitlement(List<Account> records) {
    List<Entitlement> entitlementList = new List<Entitlement>();

    for (Account acc : records) {
      if (acc.ANZx_Customer__c) {
        entitlementList.add(
          createEntitlement(
            acc.id,
            'Basic Subscription',
            'anz plus - basic subscription',
            'anzPlusBasic'
          )
        );
      }
    }

    if (!entitlementList.isEmpty()) {
      if (
        Entitlement.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Entitlement.fields.AccountId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.Name.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.SlaProcessId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.StartDate.isCreateable()
      ) {
        insert entitlementList;
      } else {
        CommonUtil.logAndThrowIAE(
          'AccountCommonActions',
          'createEntitlement',
          'Not enough permissions to create Entitlement.'
        );
      }
    }
  }

  /**
   * @description updateEntitlement is called to create or remove an entitlement for the account
   * based on whether or not it is shifting to or from ANZx
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void updateEntitlement(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    List<Entitlement> entitlementList = new List<Entitlement>();
    List<Id> idList = new List<Id>();

    for (Account acc : records) {
      Account oldAccount = (Account) oldMap.get(acc.Id);
      //Check if its a new ANZx account and created entitlement
      if (acc.ANZx_Customer__c && !oldAccount.ANZx_Customer__c) {
        entitlementList.add(
          createEntitlement(
            acc.id,
            'Basic Subscription',
            'anz plus - basic subscription',
            'anzPlusBasic'
          )
        );
      } else if (
        acc.ANZx_Customer__c != true &&
        oldAccount.ANZx_Customer__c == true
      ) {
        //If account is moving away from ANZx add to idList
        idList.add(acc.Id);
      }
    }

    //If account shifts away from ANZx, end the entitlement
    if (
      !idList.isEmpty() && Entitlement.sObjectType.getDescribe().isQueryable()
    ) {
      List<Entitlement> entList = [
        SELECT Id
        FROM Entitlement
        WHERE AccountId IN :idList
      ];

      for (Entitlement ent : entList) {
        ent.EndDate = System.today();
      }
      if (
        Entitlement.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.Entitlement.fields.EndDate.isUpdateable()
      ) {
        update entList;
      } else {
        CommonUtil.logAndThrowIAE(
          'AccountCommonActions',
          'updateEntitlement',
          'Not enough permissions to update Entitlement.'
        );
      }
    }

    if (!entitlementList.isEmpty()) {
      if (
        Entitlement.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Entitlement.fields.AccountId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.Name.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.SlaProcessId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.StartDate.isCreateable()
      ) {
        insert entitlementList;
      } else {
        CommonUtil.logAndThrowIAE(
          'AccountCommonActions',
          'updateEntitlement',
          'Not enough permissions to create Entitlement.'
        );
      }
    }
  }

  private static String getSLAId(String processName, String cacheName) {
    String slaId = (String) Cache.Org.get('local.Utility.' + cacheName);
    if (slaId != null) {
      return slaId;
    } else {
      SlaProcess sla = [
        SELECT Id
        FROM SlaProcess
        WHERE
          Name = :processName
          AND IsVersionDefault = TRUE
          AND IsActive = TRUE
      ];
      Cache.Org.put('local.Utility.' + cacheName, sla.Id);
      return (String) sla.Id;
    }
  }

  private static Entitlement createEntitlement(
    Id accountId,
    String entitlementName,
    String slaProcessName,
    String cacheName
  ) {
    Entitlement ent = new Entitlement();
    ent.AccountId = accountId;
    ent.Name = entitlementName;
    ent.SlaProcessId = getSLAId(slaProcessName, cacheName);
    ent.StartDate = System.today();

    return ent;
  }

  /**
   * @description findAndConvertLead find leads with matching details and convert them
   * @param records The Account records passed from Trigger.new()
   */
  public static void findAndConvertLead(List<Account> records) {
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    // Find matching ANZx leads
    matchingLeadsByAccIdMap.putAll(
      AccountCommonActionsHelper.findMatchingLeads(records)
    );

    // Convert matching leads into accounts
    if (matchingLeadsByAccIdMap.size() > 0) {
      LeadDMLOperator dmlOperator = new LeadDMLOperator();
      dmlOperator.convertLeads(matchingLeadsByAccIdMap);
    }
  }

  /**
   * @description findAndConvertCCRMLead find CCRM leads with matching details and convert them
   * @param accId get account id created/matched for lead conversion
   * @param leadRec The Lead records created/matched for lead conversion
   * @return string  opportunity id created/matched for lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String findAndConvertCCRMLead(String accId, Lead leadRec) {
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    // Find matching CCRM leads
    if (!String.isBlank(accId)) {
      matchingLeadsByAccIdMap.put(accId, new List<Lead>{ leadRec });
    } else {
      return Label.MLCRM_AccountBlank_LeadConversionError;
    }

    // Convert matching leads into accounts
    if (!matchingLeadsByAccIdMap.isEmpty()) {
      LeadDMLOperator dmlOperator = new LeadDMLOperator();
      CCRMLeadPlatformEventHelper.leadTask = [
        SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId, CreatedDate
        FROM Task
        WHERE WhoId = :leadRec.Id
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
      ];
      mapOfOpportunityId = dmlOperator.convertLeads(matchingLeadsByAccIdMap);
    }
    return mapOfOpportunityId.containsKey(leadRec.Id)
      ? mapOfOpportunityId.get(leadRec.Id)
      : 'Error occured while Opportunity creation during lead conversion.';
  }

  /**
   * @description revertAccountChanges revert any changes on the account that are not from OCV Integration User
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void revertAccountChanges(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    if (convertedAccountIds.size() == 0) {
      return;
    }
    for (Account rec : records) {
      if (convertedAccountIds.contains(rec.Id)) {
        Account oldRec = (Account) oldMap.get(rec.Id);
        AccountCommonActionsHelper.revertAccountFieldChanges(rec, oldRec);
      }
    }
  }

  /**
   * @description private without sharing class to bypass lead sharing setting in lead conversion process
   */
  @TestVisible
  private without sharing class LeadDMLOperator {
    /**
     * @description convertLeads convert leads into their matching accounts
     * @param matchingLeadsByAccIdMap A map fo leads to be converted and their corresponding account Ids
     * @return Map<Id,Id> map Of lead and OpportunityId
     */
    private Map<Id, Id> convertLeads(
      Map<Id, List<Lead>> matchingLeadsByAccIdMap
    ) {
      Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
      convertedAccountIds = matchingLeadsByAccIdMap.keySet();
      List<Database.LeadConvert> converts = new List<Database.LeadConvert>();
      List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>();
      LeadStatus convertedStatus = [
        SELECT MasterLabel
        FROM LeadStatus
        WHERE IsConverted = TRUE
        LIMIT 1
      ];
      //Added as per CC-4230
      CCRMLeadConversionActions.leadConverionFlow = true;
      mapOfOpportunityId = divCRMPreLeadConversionActions(
        matchingLeadsByAccIdMap
      );
      for (String accountId : matchingLeadsByAccIdMap.keySet()) {
        for (Lead l : matchingLeadsByAccIdMap.get(accountId)) {
          Database.LeadConvert convert = new Database.LeadConvert();
          convert.setLeadId(l.Id);
          convert.setAccountId(accountId);
          convert.setConvertedStatus(convertedStatus.MasterLabel);
          /* CC-4230 to createOpportunity before lead convert and linked during lead converion */
          if (
            CCRMLeadUtil.isCCRMLeadType(l) || CCRMLeadUtil.isMLCRMLeadType(l)
          ) {
            convert.setOpportunityId(mapOfOpportunityId.get(l.Id));
          } else {
            convert.setDoNotCreateOpportunity(true);
          }
          converts.add(convert);
        }
      }
      lcResults = Database.convertLead(converts);
      //Added as per CC-4230
      divCRMPostLeadConversionActions(
        matchingLeadsByAccIdMap,
        lcResults,
        mapOfOpportunityId
      );
      for (Database.LeadConvertResult lcr : lcResults) {
        if (!lcr.isSuccess()) {
          Logger.error(
            'Account_Id: ' +
              lcr.getAccountId() +
              '; Lead_Id: ' +
              lcr.getLeadId() +
              '; Error_Message: ' +
              lcr.getErrors()[0].getMessage()
          );
        }
      }
      Logger.saveLog();
      return mapOfOpportunityId;
    }

    /**
     * @description Post lead conversion actions for CCRM leads
     * @param leadMap map of leads from lead conversion
     * @param mapOfAccountId map of lead and account id
     * @return mapOf lead and OpportunityId
     */
    private Map<Id, Id> createOpportunities(
      Map<Id, Lead> leadMap,
      Map<Id, Id> mapOfAccountId
    ) {
      Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
      if (leadMap.isEmpty()) {
        return mapOfOpportunityId;
      }
      Map<Id, Opportunity> mapOfLeadsWithOpportunities = new CCRMLeadMappingEngine()
        .mapLeadToOpportunityFields(leadMap, mapOfAccountId);
      if (mapOfLeadsWithOpportunities.isEmpty()) {
        return mapOfOpportunityId;
      }
      insert mapOfLeadsWithOpportunities.values();
      for (Id leadId : leadMap.keySet()) {
        mapOfOpportunityId.put(
          leadId,
          mapOfLeadsWithOpportunities.get(leadId).Id
        );
      }
      return mapOfOpportunityId;
    }

    /**
     * @description divCRMPreLeadConversionActions Pre lead conversion actions for DivCRM leads
     * @param matchingLeadsByAccIdMap account and lead records map from lead conversion
     * @return mapOf lead and OpportunityId
     */
    private Map<Id, Id> divCRMPreLeadConversionActions(
      Map<Id, List<Lead>> matchingLeadsByAccIdMap
    ) {
      Map<Id, Lead> leadMap = new Map<Id, Lead>();
      List<Lead> leadList = new List<Lead>();
      Map<Id, Id> mapOfAccountId = new Map<Id, Id>();
      for (String accountId : matchingLeadsByAccIdMap.keySet()) {
        for (Lead l : matchingLeadsByAccIdMap.get(accountId)) {
          if (
            CCRMLeadUtil.isCCRMLeadType(l) || CCRMLeadUtil.isMLCRMLeadType(l)
          ) {
            leadMap.put(l.Id, l);
            leadList.add(l);
            mapOfAccountId.put(l.Id, accountId);
          }
        }
      }
      //Added skip_validation check as per CC-4248
      CCRMLeadConversion.checkSkipValidation(leadList);
      Map<Id, Id> mapOfOpportunityId = createOpportunities(
        leadMap,
        mapOfAccountId
      );
      return mapOfOpportunityId;
    }

    /**
     * @description divCRMPostLeadConversionActions Pre lead conversion actions for DivCRM leads
     * @param matchingLeadsByAccIdMap account and lead records map from lead conversion
     * @param lcResults Lead conversion result
     * @param mapOfOpportunityId map of opportunity id with lead id
     */
    @TestVisible
    private void divCRMPostLeadConversionActions(
      Map<Id, List<Lead>> matchingLeadsByAccIdMap,
      List<Database.LeadConvertResult> lcResults,
      Map<Id, Id> mapOfOpportunityId
    ) {
      if (mapOfOpportunityId.isEmpty()) {
        return;
      }
      LeadConversionActions objHelperClass = new LeadConversionActions();
      List<Database.LeadConvertResult> lcSuccessResults = objHelperClass.getSuccessConvertedLeads(
        lcResults
      );
      List<Lead> convertedLeads = objHelperClass.getConvertedLeads(
        lcSuccessResults,
        matchingLeadsByAccIdMap
      );
      Set<Id> leadIds = objHelperClass.getLeadListForUnicaAdobeOnLC(
        convertedLeads
      );
      Boolean autoMisMatchTaskRequired = objHelperClass.isAutoMisMatchTaskRequired(
        convertedLeads
      );
      Map<Id, Lead> mapCCRMLeads = objHelperClass.getCCRMLeadsMap(
        convertedLeads
      );
      Map<Id, Lead> mapDCRMLeads = objHelperClass.getDCRMLeadsMap(
        convertedLeads
      );
      Set<ID> contactIds = objHelperClass.getContactsToDelete(
        lcSuccessResults,
        mapDCRMLeads
      );
      Map<Id, Id> mapOfAccountIdWithLead = objHelperClass.getMapOfAccountIdWithCCRMLead(
        lcSuccessResults,
        mapCCRMLeads
      );
      if (!leadIds.isEmpty()) {
        CCRMLeadPlatformEventActions.sendUpdateToUnicaOrAdobeOnLeadConversion(
          leadIds,
          mapOfOpportunityId
        );
        transferTasksToOpportunity(mapOfOpportunityId);
      }
      if (autoMisMatchTaskRequired) {
        System.enqueuejob(
          new MLCRMAutoTaskOnLeadConversionQueueable(mapOfOpportunityId)
        );
      }
      transferA2ZReviewToOpportunity(
        mapOfAccountIdWithLead.keySet(),
        mapOfOpportunityId,
        mapOfAccountIdWithLead
      );
      deleteAutoCreatedContacts(contactIds);
    }

    /**
     * @description transfer tasks from lead to opportunity by updating WhatId
     * Used System Mode DML as the Reviews can updated only by Owners
     * @param ccrmLeadIdSet set of ccrm lead ids
     * @param mapOfOpportunityId map of opportunity id with lead id
     * @param mapOfAccountIdWithLeadId map of Account id with lead id
     */
    @TestVisible
    private void transferA2ZReviewToOpportunity(
      Set<Id> ccrmLeadIdSet,
      Map<Id, Id> mapOfOpportunityId,
      Map<Id, Id> mapOfAccountIdWithLeadId
    ) {
      List<A_Z_Review__c> listOfA2ZReviews = CCRMA2ZReviewActionHelper.fetchReviewsByLead(
        ccrmLeadIdSet
      );
      CCRMA2ZReviewActionHelper.associateReviewsToOpportunity(
        listOfA2ZReviews,
        mapOfOpportunityId
      );
      CCRMA2ZReviewActionHelper.associateReviewsToCustomer(
        listOfA2ZReviews,
        mapOfAccountIdWithLeadId
      );
      CCRMA2ZReviewActionHelper.updateReviews(listOfA2ZReviews);
    }

    /**
     * @description transfer tasks from lead to opportunity by updating WhatId
     * @param mapOfOpportunityId map of opportunity id with lead id
     */
    private void transferTasksToOpportunity(Map<Id, Id> mapOfOpportunityId) {
      for (Task taskRecord : CCRMLeadPlatformEventHelper.leadTask) {
        if (!mapOfOpportunityId.containsKey(taskRecord.WhoId)) {
          continue;
        }
        taskRecord.WhatId = mapOfOpportunityId.get(taskRecord.WhoId);
        taskRecord.WhoId = null;
        taskRecord.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      }
      DML_REPOSITORY.updateRecords(
        CCRMLeadPlatformEventHelper.leadTask,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.SYSTEM_MODE
      );
    }
    /**
     * @description delete auto created contacts post lead conversion
     * @param contactIds contacts from lead conversion
     */
    private void deleteAutoCreatedContacts(Set<ID> contactIds) {
      //Separate contactList into org contacts vs person accounts
      List<Contact> orgContactList = new List<Contact>();
      Set<Id> personContactsIdSet = new Set<Id>();
      for (
        Contact contactRec : LEADCONV_REPOSITORY.getContactList(contactIds)
      ) {
        if (contactRec.isPersonAccount) {
          personContactsIdSet.add(contactRec.id);
        } else {
          orgContactList.add(contactRec);
        }
      }
      DML_REPOSITORY.deleteRecords(
        orgContactList,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.SYSTEM_MODE
      );
      List<OpportunityContactRole> personOpportunityContactRoleList = LEADCONV_REPOSITORY.getOpportunityContactRole(
        personContactsIdSet
      );
      DML_REPOSITORY.deleteRecords(
        personOpportunityContactRoleList,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.SYSTEM_MODE
      );
    }
  }

  /**
   * @description populateFieldsValue to update field values
   * exp: if Bankrupt_Date__c is not null, it will make BankruptCheckBox__c to be true
   * @param records All the account records
   */
  public static void populateFieldsValue(List<Account> records) {
    for (Account record : records) {
      record.BankruptCheckBox__c = record.Bankrupt_Date__c != null;
      record.Was_ANZx_Customer__c =
        record.ANZx_Customer__c || record.Was_ANZx_Customer__c;
    }
  }

  /**
   * @description linkKYCQACasesToAccount is called to Link the KYC QA Case to Account using OCV ID/Mobile Number
   * @param accounts The Account records passed from Trigger.new()
   */
  public static void linkKYCQACasesToAccount(List<Account> accounts) {
    Set<String> ocvIds = AccountCommonActionsHelper.getOcvIdsFromAccounts(
      accounts
    );
    Map<String, Case> ocvIdToKYCQACaseMap = AccountCommonActionsHelper.getKYCQACasesFromOcvIds(
      ocvIds
    );

    Set<String> mobileNumbers = AccountCommonActionsHelper.getMobileNumbersFromAccounts(
      accounts
    );
    Map<String, Case> mobileNumberToKYCQACaseMap = AccountCommonActionsHelper.getKYCQACasesFromMobileNumbers(
      mobileNumbers
    );

    List<Case> kycQACaseToUpdateList = new List<Case>();
    for (Account acc : accounts) {
      String sanitisedMobileNumber = TextUtils.sanitiseMobileNumber(
        acc.PersonMobilePhone
      );
      if (
        String.isNotEmpty(acc.OCV_Id__c) &&
        ocvIdToKYCQACaseMap.containsKey(acc.OCV_Id__c)
      ) {
        Case kycQACase = ocvIdToKYCQACaseMap.get(acc.OCV_Id__c);
        kycQACase.AccountId = acc.Id;
        kycQACaseToUpdateList.add(kycQACase);
      } else if (
        String.isNotEmpty(sanitisedMobileNumber) &&
        mobileNumberToKYCQACaseMap.containsKey(sanitisedMobileNumber)
      ) {
        Case kycQACase = mobileNumberToKYCQACaseMap.get(sanitisedMobileNumber);
        kycQACase.AccountId = acc.Id;
        kycQACaseToUpdateList.add(kycQACase);
      }
    }

    List<Database.SaveResult> results = DMLUtil.updateRecords(
      kycQACaseToUpdateList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
    for (Integer i = 0; i < results.size(); i++) {
      if (results[i].isSuccess() == false || forceDMLError == true) {
        Logger.error(
          CUSTOMER_LINKED_TO_KYC_QA_ERROR +
            ' Persona ID: ' +
            kycQACaseToUpdateList.get(i).PersonaId__c +
            (results[i].getErrors().isEmpty()
              ? ''
              : ' Error: ' + results[i].getErrors().get(0)),
          Logger.Severity.HIGH
        );
      } else {
        Logger.debug(
          CUSTOMER_LINKED_TO_KYC_QA_SUCCESS +
            ' Persona ID: ' +
            kycQACaseToUpdateList.get(i).PersonaId__c
        );
      }
    }

    Logger.saveLog();
  }
}
