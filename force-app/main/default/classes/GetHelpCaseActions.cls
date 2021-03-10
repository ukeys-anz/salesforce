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
  public static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry')
    .getRecordTypeId();
  public static final Id FRAUD_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Fraud')
    .getRecordTypeId();
  public static final Id IDENTITY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Identity')
    .getRecordTypeId();
  public static final Id RECIPIENT_MULE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Recipient_Mule')
    .getRecordTypeId();
  public static final Id SCAM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Scam')
    .getRecordTypeId();
  public static final Id KYCQA_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('KYC_QA')
    .getRecordTypeId();
  public static final Id BUG_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Bug_Enquiry')
    .getRecordTypeId();
  public static final Id COMPLAINT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('ANZx_Complaint')
    .getRecordTypeId();
  @TestVisible
  public static final List<Id> FRAUD_RT_IDS = new List<Id>{
    FRAUD_RT_ID,
    IDENTITY_RT_ID,
    RECIPIENT_MULE_RT_ID,
    SCAM_RT_ID,
    KYCQA_RT_ID
  };

  // Parent Case validation error message
  private static final String PARENT_CASE_ERROR = 'You cannot add parent case. This case is associated with child cases';

  private static Map<String, String> caseTypeLabelByValue = new Map<String, String>();

  /**
   * @description beforeUpdate(oldMap, records) method handles the following
   * 1. Validate Additional Type - Validates the selected additional types and addError if it has more than 2 values selected or if the Type value is same as one of the additional values
   * 2. Validate Case Type - Validates Case Type and Additional Type to populate Case Subject.
   * 3. Validate Parent Case - Validates the case record and throws an error if the record is having child cases
   * 4. Complete milestones - updates the milestone to closed when the case status is updated to clsoed
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */
  @SuppressWarnings('PMD.StdCyclomaticComplexity')
  public static void beforeUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    List<Id> caseIds = new List<Id>();
    List<Case> validateCaseList = new List<Case>();
    List<Id> milestoneIds = new List<Id>();

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
          milestoneIds.add(record.Id);
        }
      } else if (record.RecordTypeId == COMPLAINT_ID) {
        if (
          oldRecord.Status != 'Closed' &&
          oldRecord.Status != 'Escalated' &&
          (record.Status == 'Closed' ||
          record.Status == 'Escalated')
        ) {
          milestoneIds.add(record.Id);
        }
      }
    }

    validateAdditionalTypes((List<Case>) records, (Map<Id, Case>) oldMap);
    handleCaseSubject((List<Case>) records, (Map<Id, Case>) oldMap);
    if (!caseIds.isEmpty()) {
      validateParentCase(caseIds, validateCaseList);
    }
    if (!milestoneIds.isEmpty()) {
      completeCaseMilestone(milestoneIds);
    }
  }

  /**
   * @description validateParentCase method is called before updating the case record to check and throw error if the record is having child cases
   * @param caseIds list of case ids from the trigger
   * @param validateCaseList list of case records from the trigger
   */
  public static void validateParentCase(
    List<Id> caseIds,
    List<Case> validateCaseList
  ) {
    Set<Id> parentCaseIds = new Set<Id>();
    //to store list of cases where the current record is parent case for other case records
    List<Case> childCaseList = new List<Case>();

    if (Schema.sObjectType.Case.isQueryable()) {
      childCaseList = [
        SELECT Id, ParentId
        FROM Case
        WHERE ParentId IN :caseIds
      ];
    }

    for (Case childCase : childCaseList) {
      parentCaseIds.add(childCase.ParentId);
    }

    for (Case record : validateCaseList) {
      if (parentCaseIds.contains(record.id)) {
        record.addError(PARENT_CASE_ERROR);
      }
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
    for (Integer i = 0; i < caseList.size(); i++) {
      if (
        caseList.get(i).RecordTypeId == GENERAL_INQUIRY_RT_ID &&
        (oldCaseMap == null ||
        (caseList.get(i).Type != oldCaseMap.get(caseList.get(i).Id).Type ||
        caseList.get(i).Additional_Type__c !=
        oldCaseMap.get(caseList.get(i).Id).Additional_Type__c)) &&
        String.isNotBlank(caseList.get(i).Additional_Type__c)
      ) {
        additionalTypeCheckCases.add(caseList.get(i));
      }
    }
    if (!additionalTypeCheckCases.isEmpty()) {
      checkAdditionalTypes(additionalTypeCheckCases);
    }
  }

  /**
   * @description  This method checks if Additional_Type__c has more than 2 values selected or
   * if the Type value is same as one of the additional values
   * @param caseList The caseList for which Additional_Type__c needs to be checked
   */
  private static void checkAdditionalTypes(List<Case> caseList) {
    for (Case singleCase : caseList) {
      List<String> additionalTypes = singleCase.Additional_Type__c.split(';');

      if (additionalTypes.size() > 2) {
        singleCase.addError(
          'You cannot select more than two Additional Types.'
        );
      }

      for (String additionalType : additionalTypes) {
        if (additionalType == singleCase.Type) {
          singleCase.addError(
            'You cannot select a value in Additional Type that is already selected as the Primary Type.'
          );
        }
      }
    }
  }

  /**
   * @description  This method validates Case Type and Additional Type to populate Case Subject.
   * @param caseList list of cases from the trigger
   * @param oldCaseMap old case map
   */
  public static void handleCaseSubject(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    List<Case> additionalTypeCheckCases = new List<Case>();
    for (Case record : caseList) {
      // Check for General Inquiry Cases
      if (
        record.RecordTypeId == GENERAL_INQUIRY_RT_ID &&
        (String.isNotBlank(record.Type) ||
        String.isNotBlank(record.Additional_Type__c)) &&
        (oldCaseMap == null ||
        (record.Type != oldCaseMap.get(record.Id).Type ||
        record.Additional_Type__c !=
        oldCaseMap.get(record.Id).Additional_Type__c ||
        record.RecordTypeId != oldCaseMap.get(record.Id).RecordTypeId))
      ) {
        populateGeneralEnquiryCaseSubject(record);
      }

      // Check for Fraud Cases
      // Note: We are excluding the possibility of 'Type' being empty, because we only care about data entered via UI (required field) or controlled entries via API, both of which should have values for 'Type'
      if (
        FRAUD_RT_IDS.contains(record.RecordTypeId) &&
        String.isNotBlank(record.Type) &&
        (oldCaseMap == null ||
        record.Type != oldCaseMap.get(record.Id).Type ||
        record.RecordTypeId != oldCaseMap.get(record.Id).RecordTypeId)
      ) {
        populateFraudCaseSubject(record);
      }

      if (
        record.RecordTypeId == COMPLAINT_ID &&
        (oldCaseMap == null ||
        record.Type != oldCaseMap.get(record.Id).Type)
      ) {
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
    if (String.isNotBlank(record.Additional_Type__c)) {
      caseTypeList.addAll(record.Additional_Type__c.split(';'));
    }
    //populate case subject
    if (!caseTypeList.isEmpty()) {
      record.Subject = String.join(caseTypeList, ', ');
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
   * @description  This method populates complaint Case subject based on Case record type and issue values
   * @param record Case record from trigger
   */
  public static void populateComplaintCaseSubject(Case record) {
    String typeLabel = CommonUtils.getSinglePicklistLabel(
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
      caseTypeLabelByValue = CommonUtils.getPicklistLabelsByValues(Case.Type);
    }
  }

  /**
   * @description This method updates the entitlement field on the case
   * if the case is of General Inquiry or ANZX Complaint record type
   * @param caseList list of cases from the trigger
   */
  public static void updateEntitlement(List<Case> caseList) {
    List<Id> accountIds = new List<Id>();
    Map<Id, Id> entMap = new Map<Id, Id>();
    for (Case c : caseList) {
      if (
        (c.RecordTypeId == GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == COMPLAINT_ID) && c.AccountId != null
      ) {
        accountIds.add(c.AccountId);
      }
    }

    if (Entitlement.sObjectType.getDescribe().isQueryable()) {
      List<Entitlement> entList;
      entList = [
        SELECT Id, AccountId
        FROM Entitlement
        WHERE
          AccountId IN :accountIds
          AND EndDate = NULL
          AND Name = 'Basic Subscription'
      ];

      for (Entitlement en : entList) {
        entMap.put(en.AccountId, en.Id);
      }
    }

    for (Case c : caseList) {
      if (
        (c.RecordTypeId == GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == COMPLAINT_ID) && c.AccountId != null
      ) {
        if (!entMap.containsKey(c.AccountId)) {
          c.addError('No entitlement found for account.');
        } else {
          c.EntitlementId = entMap.get(c.AccountId);
        }
      }
    }
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
    for (Case c : records) {
      if (c.Related_Bug__c != null && c.RecordTypeId == BUG_RT_ID) {
        bugIdSet.add(c.Related_Bug__c);
      }
    }
    for (Case c : oldRecords) {
      if (c.Related_Bug__c != null && c.RecordTypeId == BUG_RT_ID) {
        bugIdSet.add(c.Related_Bug__c);
      }
    }

    List<Reported_Bug__c> bugs;
    if (Reported_Bug__c.SObjectType.getDescribe().isAccessible()) {
      bugs = [
        SELECT Id, (SELECT Id FROM Cases__r)
        FROM Reported_Bug__c
        WHERE Id IN :bugIdSet
      ];
    } else {
      bugs = new List<Reported_Bug__c>();
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
    log.insertLog();
  }

  /**
   * @description future method to recalculate in a deletion scenario, because if done in before delete, the rollup will be wrong. does not check record type, do this before calling
   * @param bugIdSet set of salesforce bug id's to recalculate
   */
  @future
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static void futureRollupRelatedBug(Set<Id> bugIdSet) {
    List<Reported_Bug__c> bugs;
    if (
      Reported_Bug__c.SObjectType.getDescribe().isAccessible() &&
      Reported_Bug__c.SObjectType.getDescribe().isUpdateable()
    ) {
      bugs = [
        SELECT Id, (SELECT Id FROM Cases__r)
        FROM Reported_Bug__c
        WHERE Id IN :bugIdSet
      ];
    } else {
      bugs = new List<Reported_Bug__c>();
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
   * @description This method updates the milestone to closed when
   * the case status is updated to clsoed
   * @param caseIds list of case ids from the trigger
   */
  public static void completeCaseMilestone(List<Id> caseIds) {
    //Mark milestones as completed
    MilestoneUtils.completeMilestone(caseIds, 'Resolution Time', System.now());
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
      BusinessHours bhs = [
        SELECT Id
        FROM BusinessHours
        WHERE Name = 'ANZx Case Business Hours'
      ];

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
      if (isANZPlusCaseType(record)) {
        setBusinessHours(record);
      }
    }
  }

  /**
   * @description isANZPlusCaseType checks if record type is of ANZ Plus type.
   * As this Trigger will be used across various teams we identify case record based on ANZ Plus record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of ANZ Plus type false otherwise.
   */
  private static Boolean isANZPlusCaseType(Case record) {
    if (
      FRAUD_RT_IDS.contains(record.RecordTypeId) ||
      record.RecordTypeId == GENERAL_INQUIRY_RT_ID ||
      record.RecordTypeId == BUG_RT_ID ||
      record.RecordTypeId == COMPLAINT_ID
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description auto-populate Contact lookup on ANZ Plus Cases.
   * Assumption: Case record types would not be manually changed from AR&C to ANZ Plus
   * @param records new trigger case records
   */
  public static void populateContactLookupForANZPlus(List<Case> records) {
    List<Case> anzPlusCases = new List<Case>();
    List<Id> relatedAccountIDs = new List<Id>();
    for (Case record : records) {
      if (isANZPlusCaseType(record) && record.AccountId != null) {
        anzPlusCases.add(record);
        relatedAccountIDs.add(record.AccountId);
      }
    }

    Map<Id, Account> relatedAccountsMap = new Map<Id, Account>(
      [
        SELECT Id, IsPersonAccount, PersonContactId
        FROM Account
        WHERE Id IN :relatedAccountIDs
      ]
    );

    List<Case> casesToBeUpdated = new List<Case>();
    for (Case record : anzPlusCases) {
      casesToBeUpdated.add(
        new Case(
          Id = record.Id,
          ContactId = getContactFromAccount(
            relatedAccountsMap.get(record.AccountId)
          )
        )
      );
    }

    List<Database.SaveResult> results = Database.Update(
      casesToBeUpdated,
      false
    );

    //log errors to application log
    lib_systemLog log = new lib_systemLog(
      'GetHelpCaseActions',
      'populateContactLookupForANZPlus'
    );
    log.addDatabaseSaveResult('Case', results, new List<Case>());
    log.insertLog();
  }

  /**
   * @description returns the Contact instance related to a particular Account record
   * @param accountRecord the parent Account record related to a Case
   * @return `Id` Contact Id related to the parent Account
   */
  private static Id getContactFromAccount(Account accountRecord) {
    Id contactId = null;
    // Currently only caters for cases having PersonAccounts as parent.
    // (will have to handle Business Accounts later when we roll it out)
    if (accountRecord.IsPersonAccount) {
      contactId = accountRecord.PersonContactId;
    }
    return contactId;
  }
}
