/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Helper class for @link GetHelpCaseActions
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 * ExcessivePublicCount Surpressed : GetHelpCaseActions to have all the public methods and attributes together.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public with sharing class GetHelpCaseActionsHelper {
  public static final String YES = 'Yes';
  public static final String FRAUD_GENERIC_CUSTOMER_NAME = 'Fraud Entitlement Account';
  // Set of record type Ids that will be sent to PEGA
  public static final Set<Id> DISPUTE_PEGA_RT_IDS = new Set<Id>{
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID,
    GetHelpConstants.NPP_DISPUTE_RT_ID
  };

  // Set of all the dispute record Types for case closure
  public static final Set<Id> CASE_CLOSURE_EMAIL_DISPUTE_RT_IDS = new Set<Id>{
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID
  };

  // Parent Case validation error message
  private static final String PARENT_CASE_ERROR = 'You cannot add parent case. This case is associated with child cases';

  private static final String MORE_THAN_TWO_ADDITIONAL_TYPES_ERROR_MSG = 'You cannot select more than two Additional Types.';
  private static final String SAME_ADDITIONAL_TYPES_ERROR_MSG = 'You cannot select a value in Additional Type that is already selected as the Primary Type.';
  private static final String NO_ENTITLEMENT_ERROR_MSG = 'No entitlement found for account.';

  @TestVisible
  private static final Group PENDING_KYC_QA_WO_CUSTOMER = CommonUtil.getQueueByName(
    'Pending_KYC_QA_No_Customer'
  );

  /**
   * @description  This method checks if Additional_Type__c has more than 2 values selected or
   * if the Type value is same as one of the additional values
   * @param caseList The caseList for which Additional_Type__c needs to be checked
   */
  public static void checkAdditionalTypes(List<Case> caseList) {
    for (Case singleCase : caseList) {
      if (singleCase.Additional_Type__c != null) {
        List<String> additionalTypes = singleCase.Additional_Type__c.split(';');

        if (additionalTypes.size() > 2) {
          singleCase.addError(MORE_THAN_TWO_ADDITIONAL_TYPES_ERROR_MSG);
        }

        for (String additionalType : additionalTypes) {
          if (additionalType == singleCase.Type) {
            singleCase.addError(SAME_ADDITIONAL_TYPES_ERROR_MSG);
          }
        }
      }
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
   * @description auto-populate Contact lookup on ANZ Plus Cases.
   * Assumption: Case record types would not be manually changed from AR&C to ANZ Plus
   * @param records new trigger case records
   */
  public static void populateContactLookupForANZPlus(List<Case> records) {
    List<Case> anzPlusCases = new List<Case>();
    List<Id> relatedAccountIDs = new List<Id>();
    for (Case record : records) {
      if (
        CheckCaseRecordType.isANZPlusCaseType(record) &&
        record.AccountId != null
      ) {
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

    for (Case record : anzPlusCases) {
      // Currently only caters for cases having PersonAccounts as parent (will have to handle Business Accounts later when we roll it out)
      record.ContactId = relatedAccountsMap.get(record.AccountId)
          .IsPersonAccount
        ? relatedAccountsMap.get(record.AccountId).PersonContactId
        : null;
    }
  }

  /**
   * @description Get a set of bug Ids
   * @param bugIdSet a list of cases that we need to check for bugs
   * @return list of reported bugs
   */
  public static List<Reported_Bug__c> getReportedBugs(Set<Id> bugIdSet) {
    return [
      SELECT Id, (SELECT Id FROM Cases__r)
      FROM Reported_Bug__c
      WHERE Id IN :bugIdSet
    ];
  }

  /**
   * @description Get a list of account Ids related to entitlement enabled cases
   * @param caseList a list of cases that we need to get account ids from
   * @return list of account ids
   */
  public static Set<Id> getEntitlementAccountIds(List<Case> caseList) {
    Set<Id> accountIds = new Set<Id>();

    for (Case c : caseList) {
      if (
        (c.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID ||
        c.RecordTypeId == GetHelpConstants.KYCQA_RT_ID ||
        CheckCaseRecordType.isDispute(c)) && c.AccountId != null
      ) {
        accountIds.add(c.AccountId);
      }
    }
    return accountIds;
  }

  /**
   * @description Get a list of account Ids from general enquiry cases
   * @param accountIds a list of account Ids
   * @param name name of the entitilement
   * @return Map of account Ids and their entitlement Ids
   */
  public static Map<Id, Id> getEntitlements(Set<Id> accountIds, String name) {
    Map<Id, Id> entMap = new Map<Id, Id>();
    if (
      accountIds.isEmpty() || PermissionUtils.canQuery('Entitlement') == false
    ) {
      return entMap;
    }

    for (Entitlement en : [
      SELECT Id, AccountId
      FROM Entitlement
      WHERE AccountId IN :accountIds AND EndDate = NULL AND Name = :name
    ]) {
      entMap.put(en.AccountId, en.Id);
    }

    return entMap;
  }

  /**
   * @description Update the Entitlement Id on the case and the parent account has an entitlement
   * @param caseList a list of cases that we need to update the entitlement Id
   * @param entMap a map of account id and its corresponding entitlement id
   */
  public static void updateEntitlementIdOnCase(
    List<Case> caseList,
    Map<Id, Id> entMap
  ) {
    for (Case c : caseList) {
      if (
        (c.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID ||
        CheckCaseRecordType.isDispute(c)) && c.AccountId != null
      ) {
        if (!entMap.containsKey(c.AccountId)) {
          c.addError(NO_ENTITLEMENT_ERROR_MSG);
        } else {
          c.EntitlementId = entMap.get(c.AccountId);
        }
      } else if (
        (c.RecordTypeId == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID &&
        c.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN)
      ) {
        c.EntitlementId = IDRCaseActions.getEntitlement();
        c.IDR_Milestone_Sla__c = IDRConstants.MILESTONE_SLA_NORMAL;
      } else if (c.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID) {
        c.EntitlementId = IDRCaseActions.getEntitlement();
        c.IDR_Milestone_Sla__c = IDRCaseActions.getMilestoneSla(
          c.Status,
          c.IDR_Date_Received__c,
          c.BusinessHoursId
        );
      }
    }
  }

  /**
   * @description Check if a case is General Enquiry or a case requires addtional type check
   * @param record The case record to check
   * @param oldCaseMap old case map
   * @return if the case is a General Enquiry
   */
  public static Boolean isEnquiryOrAdditionalCheckRequired(
    Case record,
    Map<Id, Case> oldCaseMap
  ) {
    if (
      record.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID &&
      (String.isNotBlank(record.Type) ||
      String.isNotBlank(record.Additional_Type__c)) &&
      (oldCaseMap == null ||
      (record.Type != oldCaseMap.get(record.Id).Type ||
      record.Additional_Type__c !=
      oldCaseMap.get(record.Id).Additional_Type__c ||
      record.RecordTypeId != oldCaseMap.get(record.Id).RecordTypeId))
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description getCaseNumberByTransactionId is called to get all open cases that are linked to a set of transaction Ids
   * @param transactionIds set of transaction Ids
   * @return Map<String, String> a map of case number by their transaction Id
   */
  public static Map<String, String> getCaseNumberByTransactionId(
    Set<String> transactionIds
  ) {
    //remove any null values from the set to ensure case can be created
    transactionIds.remove(null);
    Map<String, String> caseNumberByTransactionId = new Map<String, String>();
    for (Case c : [
      SELECT CaseNumber__c, Transaction_Id__c
      FROM Case
      WHERE Transaction_Id__c IN :transactionIds AND Status != 'Closed'
    ]) {
      caseNumberByTransactionId.put(c.Transaction_Id__c, c.CaseNumber__c);
    }
    return caseNumberByTransactionId;
  }

  /**
   * @description This method check if a case has "Closed" status
   * @param record The case record
   * @return Boolean if a case's status is "Closed"
   */
  public static Boolean isClosed(Case record) {
    Boolean isClosed = record.Status == 'Closed' ? true : false;
    return isClosed;
  }

  /**
   * @description Gett a list of financial account roles based on financial account id, account ids and if the role should be active
   * @param accountIds List of account Ids
   * @param financialAccIds Set of financial account Ids
   * @param isActive If the financial account role is active
   * @return Map<Id, FinServ__FinancialAccountRole__c> a map of financial account roles and their Ids
   */
  public static Map<Id, FinServ__FinancialAccountRole__c> getFinancialAccountRolesMap(
    Set<Id> accountIds,
    Set<Id> financialAccIds,
    Boolean isActive
  ) {
    Map<Id, FinServ__FinancialAccountRole__c> financialRolesMap = new Map<Id, FinServ__FinancialAccountRole__c>();
    if (
      FinServ__FinancialAccountRole__c.SObjectType.getDescribe().isAccessible()
    ) {
      financialRolesMap = new Map<Id, FinServ__FinancialAccountRole__c>(
        [
          SELECT Id, FinServ__FinancialAccount__c, FinServ__RelatedAccount__c
          FROM FinServ__FinancialAccountRole__c
          WHERE
            FinServ__FinancialAccount__c IN :financialAccIds
            AND FinServ__RelatedAccount__c IN :accountIds
            AND FinServ__Active__c = :isActive
        ]
      );
    }
    return financialRolesMap;
  }

  /**
   * @description Checks if a case is a valid PEGA dispute
   * @param record The case record
   * @return Boolean if a case is a valid PEGA dispute
   */
  public static Boolean isValidPegaDispute(Case record) {
    if (
      record.RecordTypeId == GetHelpConstants.NPP_DISPUTE_RT_ID &&
      record.Dispute_Reason__c ==
      GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION
    ) {
      return false;
    }
    return DISPUTE_PEGA_RT_IDS.contains(record.RecordTypeId) &&
      record.Submitted__c &&
      record.Status == 'Open';
  }

  /**
   * @description Build a list of platform events from the dispute cases' details
   * @param records New record instances to process
   * @return List<sObject> List of platform events to publish
   */
  public static List<sObject> buildPegaPlatformEvents(List<Case> records) {
    List<sObject> peList = new List<sObject>();
    for (Case record : records) {
      // Create a list of platform events
      Disputes_PEGA_Integration_Event__e pe = new Disputes_PEGA_Integration_Event__e(
        Case_Id__c = record.Id,
        Transaction_Id__c = record.Transaction_Id__c,
        Original_Case_Number__c = (record.CaseNumber__c != null)
          ? record.CaseNumber__c
          : record.CaseNumber,
        Record_Type_Name__c = Schema.getGlobalDescribe()
          .get('Case')
          .getDescribe()
          .getRecordTypeInfosById()
          .get(record.RecordTypeId)
          .getName(),
        Span_Id__c = UniqueIdUtil.generateSpanId(),
        Correlation_Id__c = UniqueIdUtil.getTraceId()
      );
      peList.add(pe);
    }
    return peList;
  }

  /**
   * @description Check if the case is a non customer complaint and if the user
   * is ANZx
   * @param records New record instances to process
   */
  public static void setANZxCustomerNonCustomerComplaints(List<Case> records) {
    for (Case record : records) {
      if (
        record.RecordTypeId == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID &&
        UserInfo.getProfileId() ==
        CommonUtil.getProfileByName('ANZx Standard User').Id
      ) {
        record.ANZx_Customer__c = true;
      }
    }
  }

  /**
   * @description Check if the case is a false customer profile, then make the onboarding customer name value -
   * - to be customer name
   * @param records New record instances to process
   */
  public static void setFraudCustomerProfileCase(List<Case> records) {
    Map<Id, Case> caseList = new Map<Id, Case>();
    set<Id> accountIds = new Set<Id>();

    for (Case record : records) {
      if (
        record.RecordTypeId == GetHelpConstants.FALSE_CUSTOMER_PROFILE_RT_ID
      ) {
        accountIds.add(record.AccountId);
        caseList.put(record.AccountId, record);
      }
    }
    if (accountIds.Size() > 0 && Schema.sObjectType.Account.isQueryable()) {
      List<Account> accs = [
        SELECT Id, Name
        FROM Account
        WHERE Id IN :accountIds
      ];
      for (Account acc : accs) {
        Case c = caseList.get(acc.Id);
        if (
          String.isBlank(c.Fraud_Onboarding_Customer_Name__c) ||
          (c.Fraud_Onboarding_Customer_Name__c != FRAUD_GENERIC_CUSTOMER_NAME &&
          acc.Name != FRAUD_GENERIC_CUSTOMER_NAME)
        ) {
          c.Fraud_Onboarding_Customer_Name__c = acc.Name;
        }
      }
    }
  }

  /**
   * @description Check if the account on the case has changed
   * @param records New record instances to process
   * @param oldCaseMap Old case map
   * @return Boolean if a case's account id has changed
   */
  public static Boolean hasAccountUpdated(
    List<Case> records,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case record : (List<Case>) records) {
      if (record.AccountId != oldCaseMap.get(record.Id).AccountId) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description Set card to null if status isn't open
   * @param record Case to process
   */
  public static void handleCardTokenNumber(Case record) {
    if (record.Status != GetHelpConstants.OPEN_STATUS) {
      record.Card_Token_Number__c = null;
    }
  }

  /**
   * @description populate default fields on KYC QA cases
   * @param record record
   */
  public static void populateKYCQACaseClosedNoDefectDefaults(Case record) {
    record.Fraud_Customer_Details__c = YES;
    record.Fraud_Middle_Name__c = YES;
    record.Fraud_Middle_Initial__c = YES;
    record.Fraud_MiddleNameCheck__c = YES;
    record.Fraud_Selfie_Comparison_Match__c = YES;
    record.Fraud_PO_Box__c = YES;
    record.Fraud_Address_Valid__c = YES;
    record.Fraud_ID_Legible__c = YES;
    record.Fraud_ID_Not_Picture__c = YES;
    record.Fraud_Customer_Photo_Modified__c = YES;
    record.Fraud_Security_Features__c = YES;
    record.Fraud_Restraint_Status__c = 'N/A';
    record.Fraud_Defects_Rectified__c = 'Not Applicable';
  }

  /**
   * @description This method will check if a case is converted from AEM to General Inquiry/ANZX Complaint/Non-Cusotmer Complaint
   * @param oldRecord case: old values of a record to process
   * @param newRecord case: new record instances to process
   * @return Boolean find all the AEM converted cases.
   */
  public static Boolean isAEMConverted(Case oldRecord, Case newRecord) {
    List<String> convertedTypes = new List<String>{
      GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      GetHelpConstants.COMPLAINT_RT_ID,
      GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID
    };
    return CheckCaseRecordType.isUnauthenticatedEnquiry(oldRecord) &&
      newRecord.ANZx_Customer__c &&
      newRecord.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN &&
      convertedTypes.contains(newRecord.RecordTypeId);
  }

  /**
   * @description This method will check if the case is converted from AEM to General Inquiry/ANZX Complaint/Non-Cusotmer Complaint
   * @param oldMap Map<Id, Case> oldMap: Map of the old values of the records to process
   * @param caseList List<Case> caseList: New record instances to process
   * @return List<Case> find all the AEM converted cases.
   */
  public static List<Case> filterAEMConvertedCases(
    Map<Id, Case> oldMap,
    List<Case> caseList
  ) {
    List<Case> filteredCases = new List<Case>();
    for (Case newRecord : caseList) {
      Case oldRecord = (Case) oldMap.get(newRecord.Id);
      if (isAEMConverted(oldRecord, newRecord)) {
        filteredCases.add(newRecord);
      }
    }
    return filteredCases;
  }

  /**
   * @description  handleEntitlementForUpdate method is used to update the entitlment and time to escalation flag for ANZ Plus Complaints.
   * 1. when a case is updated by the indexing team. entitlment ID and Flag both need to be calculated.
   * 2. when a case has a status change. Flag status is needs to be recalculated.
   * Note : IDR_Milestone_Sla__c is updated by entitlment process. this code is to handle the edge case scenarios.
   * where the date received is back dated and milestones warning actions will not execute.
   * @param record The actual case record from the trigger
   * @param oldRec The old record values for the case
   */
  public static void handleEntitlementForUpdate(Case record, Case oldRec) {
    //If status changes, recalculate the flag status.
    if (
      record.Status != oldRec.Status &&
      (record.Status == GetHelpConstants.UNDER_INVESTIGATION_STATUS ||
      record.Status == GetHelpConstants.OPEN_STATUS)
    ) {
      record.IDR_Milestone_Sla__c = IDRCaseActions.getMilestoneSla(
        record.Status,
        record.IDR_Date_Received__c,
        record.BusinessHoursId
      );
    }

    // if the date received has been updated , this information needs to flow on to SlaStartDate field. for the entitlments to work as expected.
    if (record.IDR_Date_Received__c != oldRec.IDR_Date_Received__c) {
      record.SlaStartDate = record.IDR_Date_Received__c;
    }
  }

  /**
   * @description Check if the case status was changed
   * @param newRecord The actual case record from the trigger
   * @param oldRecord The old record values for the case
   * @return Boolean True if current status is different from previous status
   */
  public static Boolean isStatusChanged(Case newRecord, Case oldRecord) {
    return newRecord.Status != oldRecord?.Status;
  }

  /**
   * @description Get cases by ids
   * @param caseIds Case ids
   * @return List<Case> List of cases
   */
  public static List<Case> getCasesByIds(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }

    List<Case> cases = new List<Case>();
    if (PermissionUtils.canQuery('Case')) {
      cases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
    }

    return cases;
  }

  /**
   * @description Get ID Ops Cases with set status to be updated
   * @param parentIdAndChildCasedMap Id Ops ids and case details
   * @return List<Case> List of cases with set status
   */
  public static List<Case> setIDOpsCaseStatus(
    Map<Id, Case> parentIdAndChildCasedMap
  ) {
    List<Case> idOpsCases = getCasesByIds(parentIdAndChildCasedMap.keySet());

    for (Case idOpsCase : idOpsCases) {
      Case fraudCheckCase = parentIdAndChildCasedMap.get(idOpsCase.Id);

      idOpsCase.Status = GetHelpConstants.COB_FRAUD_CHECK_TO_ID_OPS_STATUS_MAP.get(
        fraudCheckCase.Status
      );

      if (idOpsCase.Status == GetHelpConstants.COB_FAILED_OK_STATUS) {
        idOpsCase.OnboardingVerificationFailedReason__c = fraudCheckCase.OnboardingVerificationFailedReason__c;
      }
    }

    return idOpsCases;
  }

  /**
   * @description create closed case map which are last modified by Non Standard User
   * @param records Case records from trigger
   * @param oldMap oldMap of the cases
   * @return closed case map
   */
  public static Map<Id, Case> createClosedCaseMap(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Map<Id, Case> mapClosedCases = new Map<Id, Case>();
    List<Case> closedCases = [
      SELECT
        Id,
        AccountId,
        Subject,
        BusinessHoursId,
        LastModifiedBy.Profile.Name,
        IsClosed,
        RecordTypeId,
        Status
      FROM Case
      WHERE Id IN :records
    ];
    for (Case record : closedCases) {
      Case oldCase = oldMap.get(record.Id);
      if (
        GetHelpCaseActionsHelper.CASE_CLOSURE_EMAIL_DISPUTE_RT_IDS.contains(
          record.RecordTypeId
        ) &&
        !record.LastModifiedBy.Profile.Name.endsWith('Standard User') &&
        record.IsClosed &&
        record.Status != oldCase.Status
      ) {
        mapClosedCases.put(record.Id, record);
      }
    }

    return mapClosedCases;
  }

  /**
   * @description create task on case
   * @param caseRecord case record
   * @param externalCaseStatusRecord External_Case_Status__c Record
   * @param taskOwnerId gives the owner to which the created task to be assigned
   * @return task record
   */
  public static Task createEmailTask(
    Case caseRecord,
    External_Case_Status__c externalCaseStatusRecord,
    Id taskOwnerId
  ) {
    Task newTask = new Task();
    newTask.WhatId = caseRecord.Id;
    newTask.WhoId = externalCaseStatusRecord.Case__r.ContactId;
    newTask.Subject = caseRecord.Subject + ' Closure Communication Required';
    newTask.Description = GetHelpConstants.TASK_EMAIL_DESCRIPTION;
    newTask.PEGA_Case_Status__c = externalCaseStatusRecord.External_Status__c;
    newTask.OwnerId = taskOwnerId;
    newTask.RecordTypeId = GetHelpConstants.TASK_EMAIL_RT;
    newTask.Case__c = caseRecord.Id;
    newTask.ActivityDate = DateTimeUtils.addBusinessDays(
        caseRecord.BusinessHoursId,
        System.now(),
        3
      )
      .date();
    return newTask;
  }

  /**
   * @description Get Mobile Number and Case map
   * @param oldCaseIds Set of old KYC QA Case Ids trigger.oldMap
   * @return Mobile Number and Case Id map
   */
  public static Map<String, String> getMobileByCaseId(Set<Id> oldCaseIds) {
    if (oldCaseIds.isEmpty() || PermissionUtils.canQuery('Case') == false) {
      return new Map<String, String>();
    }

    Map<String, String> mobileByCaseIdMap = new Map<String, String>();
    for (Case c : [
      SELECT Id, CustomerOnboardingApplication__r.SecurityMobile__c
      FROM Case
      WHERE Id IN :oldCaseIds AND RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ]) {
      if (
        String.isNotBlank(c.CustomerOnboardingApplication__r.SecurityMobile__c)
      ) {
        mobileByCaseIdMap.put(
          c.Id,
          '+' + c.CustomerOnboardingApplication__r.SecurityMobile__c
        );
      }
    }
    return mobileByCaseIdMap;
  }

  /**
   * @description Get Mobile Phones and Account map
   * @param mobileNumbers List of mobiles from COB Applications
   * @return Mobile Phones and Account map
   */
  public static Map<String, Account> getAccountsByMobile(
    List<String> mobileNumbers
  ) {
    if (
      mobileNumbers.isEmpty() || PermissionUtils.canQuery('Account') == false
    ) {
      return new Map<String, Account>();
    }

    Map<String, Account> accountByMobileMap = new Map<String, Account>();
    for (Account acc : [
      SELECT Id, PersonMobilePhone, PersonContactId
      FROM Account
      WHERE PersonMobilePhone IN :mobileNumbers AND ANZx_Customer__c = TRUE
    ]) {
      accountByMobileMap.put(acc.PersonMobilePhone, acc);
    }
    return accountByMobileMap;
  }

  /**
   * @description Get Account Ids Entitlment map
   * @param accounts List of Accounts
   * @return Account Ids Entitlment map
   */
  public static Map<Id, Id> getAccountIdEntitlmentMap(List<Account> accounts) {
    Set<Id> accIds = (new Map<Id, SObject>(accounts)).keySet();
    // Get matched Accounts Entitelments
    return getEntitlements(
      accIds,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );
  }

  /**
   * @description Set case fileds with matching Account
   * @param c Case
   * @param matchingAcc Matched Account
   * @param accountEntitlmentId Matched Account Entitlment Id
   */
  public static void setMatchingAccountFields(
    Case c,
    Account matchingAcc,
    Id accountEntitlmentId
  ) {
    c.AccountId = matchingAcc.Id;
    c.ContactId = matchingAcc.PersonContactId;
    c.EntitlementId = accountEntitlmentId;
  }

  /**
   * @description Handle KYC QA Case in the situatuon there is still no MAtched Account:
   * Either move to "Pending KYC QA - No Customer" queue in the event the case is not closed yet or
   * remain in the "Pending KYC QA - No Customer" queue untill there is a Matched Account
   * @param c Case
   * @param oldCase Old case
   */
  public static void handleKYCQACaseNoCustomer(Case c, Case oldCase) {
    if (
      (oldCase.Status != GetHelpConstants.CLOSED_STATUS &&
      c.Status == GetHelpConstants.CLOSED_STATUS) ||
      oldCase.OwnerId == PENDING_KYC_QA_WO_CUSTOMER.Id
    ) {
      c.OwnerId = PENDING_KYC_QA_WO_CUSTOMER.Id;
    }
  }

  /**
   * @description Filter cases by Record Type Id
   * @param records List of case records
   * @return List of filtered cases
   */
  public static List<Case> getKYCQACasesWithoutCustomer(List<Case> records) {
    List<Case> kycQACases = CommonUtil.filterCasesByRecordTypeId(
      records,
      GetHelpConstants.KYCQA_RT_ID
    );

    List<Case> kycQACasesWithNoCustomer = new List<Case>();
    for (Case c : kycQACases) {
      if (c.AccountId == null) {
        kycQACasesWithNoCustomer.add(c);
      }
    }

    return kycQACasesWithNoCustomer;
  }
}
