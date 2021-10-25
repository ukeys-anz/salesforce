/**
 *
 * @author Boobalakrishnan Duraisamy
 * @since 04/2020
 * @description GetHelpCaseActions class is to handle all the Get Help Case Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class GetHelpCaseActions {
  // General Inquiry Record Type Id
  @TestVisible
  public static final Id GENERAL_INQUIRY_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'General_Inquiry'
  );
  public static final Id FRAUD_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Fraud'
  );
  public static final Id IDENTITY_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Identity'
  );
  public static final Id RECIPIENT_MULE_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Recipient_Mule'
  );
  public static final Id SCAM_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Scam'
  );
  public static final Id KYCQA_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'KYC_QA'
  );
  public static final Id BUG_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Bug_Enquiry'
  );
  @TestVisible
  public static final List<Id> FRAUD_RT_IDS = new List<Id>{
    FRAUD_RT_ID,
    IDENTITY_RT_ID,
    RECIPIENT_MULE_RT_ID,
    SCAM_RT_ID,
    KYCQA_RT_ID
  };
  public static final Id ATM_DISPUTE_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'ATM_Dispute'
  );
  public static final Id CARD_DISPUTE_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Card_Dispute'
  );
  public static final Id DIRECT_DEBIT_DISPUTE_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Direct_Debit_Dispute'
  );
  public static final Id DIRECT_ENTRY_DISPUTE_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Direct_Entry_Dispute'
  );
  public static final Id URGENT_DISHONOUR_DISPUTE_RT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'Urgent_Dishonour_Request_Dispute'
  );
  @TestVisible
  public static final List<Id> DISPUTE_RT_IDS = new List<Id>{
    ATM_DISPUTE_RT_ID,
    CARD_DISPUTE_RT_ID,
    DIRECT_DEBIT_DISPUTE_RT_ID,
    DIRECT_ENTRY_DISPUTE_RT_ID,
    URGENT_DISHONOUR_DISPUTE_RT_ID
  };
  public static final Id COMPLAINT_ID = GetHelpCaseActionsHelper.getCaseRecordTypeIdByDeveloperName(
    'ANZx_Complaint'
  );

  public static final String DUPLICATE_DISPUTE_ERROR = 'Error occurred while creating dispute. An open dispute already exists for this transaction. Case number: ';

  private static Map<String, String> caseTypeLabelByValue = new Map<String, String>();

  public static final String RESOLUTION_TIME_MILESTONE = 'Resolution Time';

  public static final String INVESTIGATION_TIME_MILESTONE = 'Investigation Time';

  public static final String MISALIGNED_FINANCIAL_ACCOUNT_ERROR = 'Error occurred while create dispute.  There is a misalignment between customer\'s OCV ID and Financial Account';

  private static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';

  /**
   * @description beforeUpdate(oldMap, records) method handles the following
   * 1. Validate Additional Type - Validates the selected additional types and addError if it has more than 2 values selected or if the Type value is same as one of the additional values
   * 2. Handle Populate Case Subject- Check the case type and populate its subject accordingly.
   * 3. Validate Parent Case - Validates the case record and throws an error if the record is having child cases
   * 4. Complete milestones - updates the milestone to closed when the case status is updated to clsoed
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */
  @SuppressWarnings('PMD.StdCyclomaticComplexity')
  public static void beforeUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    List<Id> caseIds = new List<Id>();
    List<Case> validateCaseList = new List<Case>();
    Set<Id> milestoneCaseIds = new Set<Id>();

    for (Case record : (List<Case>) records) {
      Case oldRecord = (Case) oldMap.get(record.id);
      if (oldRecord.Status != 'Closed' && record.Status == 'Closed') {
        updateCaseDurationTime(record);
      }

      if (record.RecordTypeId == GENERAL_INQUIRY_RT_ID) {
        if (
          String.isNotBlank(record.ParentId) &&
          record.ParentId != oldRecord.ParentId
        ) {
          caseIds.add(record.id);
          validateCaseList.add(record);
        }

        if (oldRecord.Status != 'Closed' && record.Status == 'Closed') {
          milestoneCaseIds.add(record.Id);
        }
      } else if (record.RecordTypeId == COMPLAINT_ID) {
        if (
          oldRecord.Status != 'Closed' &&
          oldRecord.Status != 'Escalated' &&
          oldRecord.Status != 'Withdrawn' &&
          oldRecord.Status != 'Resolved' &&
          (record.Status == 'Closed' ||
          record.Status == 'Escalated' ||
          record.Status == 'Withdrawn' ||
          record.Status == 'Resolved')
        ) {
          milestoneCaseIds.add(record.Id);
        }
      } else if (GetHelpCaseActionsHelper.isDispute(record)) {
        if (oldRecord.Status == 'Open' && record.Status != 'Open') {
          milestoneCaseIds.add(record.Id);
        }
        if (
          oldRecord.Status == UNDER_INVESTIGATION_STATUS &&
          record.Status == 'Closed'
        ) {
          milestoneCaseIds.add(record.Id);
        }
      }
    }

    handlePopulateCaseSubject((List<Case>) records, (Map<Id, Case>) oldMap);
    validateAdditionalTypes((List<Case>) records, (Map<Id, Case>) oldMap);

    if (!caseIds.isEmpty()) {
      GetHelpCaseActionsHelper.validateParentCase(caseIds, validateCaseList);
    }

    if (!milestoneCaseIds.isEmpty()) {
      MilestoneUtils.completeMilestone(
        milestoneCaseIds,
        new List<String>{
          RESOLUTION_TIME_MILESTONE,
          INVESTIGATION_TIME_MILESTONE
        },
        System.now()
      );
    }
  }

  /**
   * @description validate the selected additional types
   * @param caseList The case list to validate the additional types on
   * @param oldCaseMap old case map
   */
  public static void validateAdditionalTypes(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    List<Case> additionalTypeCheckCases = new List<Case>();
    for (Case record : caseList) {
      if (
        GetHelpCaseActionsHelper.isEnquiryOrAdditionalCheckRequired(
          record,
          oldCaseMap
        )
      ) {
        additionalTypeCheckCases.add(record);
      }
    }
    GetHelpCaseActionsHelper.checkAdditionalTypes(additionalTypeCheckCases);
  }

  /**
   * @description  This method validates Case Type and Additional Type to populate Case Subject.
   * @param caseList list of cases from the trigger
   * @param oldCaseMap old case map
   */
  public static void handlePopulateCaseSubject(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case record : caseList) {
      // Check for General Inquiry Cases
      if (
        GetHelpCaseActionsHelper.isEnquiryOrAdditionalCheckRequired(
          record,
          oldCaseMap
        )
      ) {
        populateGeneralEnquiryCaseSubject(record);
      }

      // Check for Fraud Cases
      // Note: We are excluding the possibility of 'Type' being empty, because we only care about data entered via UI (required field) or controlled entries via API, both of which should have values for 'Type'
      if (GetHelpCaseActionsHelper.isFraud(record, oldCaseMap)) {
        populateFraudCaseSubject(record);
      }

      // Check for Dispute Cases
      if (GetHelpCaseActionsHelper.isDispute(record)) {
        populateDisputeCaseSubject(record);
      }

      // Check for Complaint Cases
      if (GetHelpCaseActionsHelper.isComplaint(record, oldCaseMap)) {
        populateComplaintCaseSubject(record);
      }
    }
  }

  /**
   * @description  This method populates Case subject based on Case type and additional type values
   * @param record Case record from trigger
   */
  public static void populateGeneralEnquiryCaseSubject(Case record) {
    List<String> caseTypeList = new List<String>();

    if (String.isNotBlank(record.Type)) {
      fetchCaseTypeLabelsByValues();
      caseTypeList.add(caseTypeLabelByValue.get(record.Type));
    }
    if (String.isNotBlank(record.Sub_Type__c)) {
      caseTypeList.addAll(record.Sub_Type__c.split(';'));
    }
    //populate case subject
    if (!caseTypeList.isEmpty()) {
      record.Subject = String.join(caseTypeList, ' - ');
    }
  }

  /**
   * @description  This method populates subject on Fraud cases based on Record Type and Type
   * @param record Case record from trigger
   */
  public static void populateFraudCaseSubject(Case record) {
    List<String> caseTypeList = new List<String>();

    if (String.isNotBlank(record.Type)) {
      fetchCaseTypeLabelsByValues();
      // Setting a different Subject format for KYC QA Cases
      if (KYCQA_RT_ID == record.RecordTypeId) {
        record.Subject = caseTypeLabelByValue.get(record.Type);
      } else {
        record.Subject =
          Schema.getGlobalDescribe()
            .get('Case')
            .getDescribe()
            .getRecordTypeInfosById()
            .get(record.RecordTypeId)
            .getName() +
          ' - ' +
          caseTypeLabelByValue.get(record.Type);
      }
    }
  }

  /**
   * @description  This method populates the subject of Dispute cases based on Record Type and Dispute Reason
   * @param record Case record from trigger
   */
  public static void populateDisputeCaseSubject(Case record) {
    // For dispute cases, subject will be text comprising "<Record Type Name> - <Dispute Reason>
    if (String.isNotBlank(record.Dispute_Reason__c)) {
      record.Subject =
        Schema.getGlobalDescribe()
          .get('Case')
          .getDescribe()
          .getRecordTypeInfosById()
          .get(record.RecordTypeId)
          .getName() +
        ' - ' +
        record.Dispute_Reason__c;
    }
  }

  /**
   * @description  This method populates complaint Case subject based on Case record type and issue values
   * @param record Case record from trigger
   */
  public static void populateComplaintCaseSubject(Case record) {
    String typeLabel = CommonUtil.getSinglePicklistLabel(
      Case.Type,
      record.Type
    );
    record.Subject = 'ANZ Plus Complaint - ' + typeLabel;
  }

  /**
   * @description Fetches (if not already available) a map of Case 'Type' Picklist Labels by Values
   */
  public static void fetchCaseTypeLabelsByValues() {
    if (caseTypeLabelByValue.isEmpty()) {
      caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(Case.Type);
    }
  }

  /**
   * @description This method updates the entitlement field on the case
   * if the case is of General Inquiry, ANZX Complaint, or any of the Dispute record types
   * @param caseList list of cases from the trigger
   */
  public static void updateEntitlement(List<Case> caseList) {
    List<Id> accountIds = new List<Id>();
    Map<Id, Id> entMap = new Map<Id, Id>();

    accountIds = GetHelpCaseActionsHelper.getEntitlementAccountIds(caseList);

    if (Entitlement.sObjectType.getDescribe().isQueryable()) {
      List<Entitlement> entList;
      entList = GetHelpCaseActionsHelper.getEntitlements(
        accountIds,
        'Basic Subscription'
      );

      for (Entitlement en : entList) {
        entMap.put(en.AccountId, en.Id);
      }
    }

    GetHelpCaseActionsHelper.updateEntitlementIdOnCase(caseList, entMap);
  }

  /**
   * @description recalculate related bug rollup whenever a case is inserted/updated/deleted
   * @param records new trigger case records to calculate rollups for
   * @param oldRecords old trigger case records to calculate rollups for
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static void rollupRelatedBug(
    List<Case> records,
    List<Case> oldRecords
  ) {
    Set<Id> bugIdSet = new Set<Id>();
    bugIdSet = GetHelpCaseActionsHelper.getBugIdSet(records, bugIdSet);
    bugIdSet = GetHelpCaseActionsHelper.getBugIdSet(oldRecords, bugIdSet);

    List<Reported_Bug__c> bugs = new List<Reported_Bug__c>();
    if (Reported_Bug__c.SObjectType.getDescribe().isAccessible()) {
      bugs = GetHelpCaseActionsHelper.getReportedBugs(bugIdSet);
    }

    for (Reported_Bug__c bug : bugs) {
      bug.Number_of_Related_Cases__c = bug.Cases__r.size();
    }
    List<Database.SaveResult> results = Database.Update(bugs, false);

    //log errors to application log
    lib_systemLog log = new lib_systemLog(
      'GetHelpCaseActions',
      'rollupRelatedBug'
    );
    log.addDatabaseSaveResult('Case', results, new List<Case>());
    log.insertLogAsync();
  }

  /**
   * @description future method to recalculate in a deletion scenario, because if done in before delete, the rollup will be wrong. does not check record type, do this before calling
   * @param bugIdSet set of salesforce bug id's to recalculate
   */
  @future
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static void futureRollupRelatedBug(Set<Id> bugIdSet) {
    List<Reported_Bug__c> bugs = new List<Reported_Bug__c>();
    if (
      Reported_Bug__c.SObjectType.getDescribe().isAccessible() &&
      Reported_Bug__c.SObjectType.getDescribe().isUpdateable()
    ) {
      bugs = GetHelpCaseActionsHelper.getReportedBugs(bugIdSet);
    }

    for (Reported_Bug__c bug : bugs) {
      bug.Number_of_Related_Cases__c = bug.Cases__r.size();
    }

    List<Database.SaveResult> results = Database.Update(bugs, false);

    //log errors to application log
    lib_systemLog log = new lib_systemLog(
      'GetHelpCaseActions',
      'futureRollupRelatedBug'
    );
    log.addDatabaseSaveResult('Case', results, new List<Case>());
    log.insertLog();
  }

  /**
   * @description This method updates the case duration hours field for EA for further usage
   * when the case status is updated to closed
   * @param record case from the trigger
   */
  public static void updateCaseDurationTime(Case record) {
    CaseDurationObject.DurationTime durationTime = CaseDurationService.getCaseDurationTime(
      record.Id
    );
    record.Case_Hour_Duration__c = durationTime.dHours.setScale(
      2,
      RoundingMode.HALF_UP
    );
  }

  /**
   * @description This method updates the case business hours field
   * to be ANZ Plus specific
   * @param record the record we are updating
   */
  private static void setBusinessHours(Case record) {
    if (BusinessHours.SObjectType.getDescribe().isAccessible()) {
      BusinessHours bhs = CommonUtil.getBusinessHours();
      record.BusinessHoursId = bhs.Id;
    }
  }

  /**
   * @description applyDefaults is called onBeforeInsert to set the following values as defaults
   * 1. Update business hours field to match ANZ Plus business hours
   * @param records The record list form which we need to apply defaults
   */
  public static void applyDefaults(List<Case> records) {
    for (Case record : records) {
      if (GetHelpCaseActionsHelper.isANZPlusCaseType(record)) {
        setBusinessHours(record);
      }
    }
  }

  /**
   * @description checkOpenDisputeOnTransaction is called onBeforeInsert to check if there is already an open dispute for a particular transaction, if so,
   * throw an exception to prevent a duplicate dispute from being created
   * @param records a list of cases
   */
  public static void checkOpenDisputeOnTransaction(List<Case> records) {
    Set<String> transactionIds = new Set<String>();
    List<Case> disputeCases = new List<Case>();
    for (Case c : records) {
      if (GetHelpCaseActionsHelper.isDispute(c)) {
        transactionIds.add(c.Transaction_Id__c);
        disputeCases.add(c);
      }
    }
    Map<String, String> caseNumberByTransactionId = GetHelpCaseActionsHelper.getCaseNumberByTransactionId(
      transactionIds
    );
    for (Case c : disputeCases) {
      String caseNumber = caseNumberByTransactionId.get(c.Transaction_Id__c);
      if (caseNumber != null) {
        c.addError(DUPLICATE_DISPUTE_ERROR + caseNumber);
      }
    }
  }

  /**
   * @description Check if the provided financial account is ACTIVE and linked to the provided customer account
   * @param records The list of cases whose financial accounts need to be validated
   */
  public static void validateFinancialAccByAccId(List<Case> records) {
    Map<Id, Case> caseByCaseIdMap = new Map<Id, Case>();
    Map<Id, String> accountCombinedKeyByCaseIdMap = new Map<Id, String>();
    Map<Id, Id> finAccIdByAccIdMap = new Map<Id, Id>();
    for (Case record : records) {
      if (
        record.FinServ__FinancialAccount__c != null &&
        record.AccountId != null
      ) {
        caseByCaseIdMap.put(record.Id, record); // Get a map of case and its Id
        accountCombinedKeyByCaseIdMap.put(
          record.Id,
          String.valueOf(record.FinServ__FinancialAccount__c) +
          String.valueOf(record.AccountId)
        ); // Get a map of a case key (combination of its customer account Id and financial account Id) and its Id
        finAccIdByAccIdMap.put(
          record.AccountId,
          record.FinServ__FinancialAccount__c
        ); // Get a map of a case customer Id and its financial account Id
      }
    }
    Map<Id, FinServ__FinancialAccountRole__c> financialAccRolesByIdMap = GetHelpCaseActionsHelper.getFinancialAccountRolesMap(
      finAccIdByAccIdMap.values(),
      finAccIdByAccIdMap.keyset(),
      true
    ); // Get a list of ACTIVE financial account roles which are linked to the provided customer accounts and financial accounts

    Map<Id, String> combinedKeyByRoleIdMap = new Map<Id, String>();

    for (
      FinServ__FinancialAccountRole__c record : financialAccRolesByIdMap.values()
    ) {
      // Loop through the list of ACTIVE financial account roles, get a list of keys that constructed from each role's financial account Id and customer account Id
      combinedKeyByRoleIdMap.put(
        record.Id,
        String.valueOf(record.FinServ__FinancialAccount__c) +
        String.valueOf(record.FinServ__RelatedAccount__c)
      );
    }

    for (String caseId : accountCombinedKeyByCaseIdMap.keySet()) {
      if (
        !combinedKeyByRoleIdMap.values()
          .contains(accountCombinedKeyByCaseIdMap.get(caseId)) // If a case's combination key does not exist in the list of combine keys above, aka this case does not have an ACTIVE financial role between its customer account and financial account
      ) {
        caseByCaseIdMap.get(caseId)
          .addError(MISALIGNED_FINANCIAL_ACCOUNT_ERROR); // The case should not be created
      }
    }
  }
}
