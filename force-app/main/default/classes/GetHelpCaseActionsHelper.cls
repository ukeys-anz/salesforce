/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Helper class for @link GetHelpCaseActions
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class GetHelpCaseActionsHelper {
  public static final Set<Id> FRAUD_RT_IDS = new Set<Id>{
    GetHelpConstants.FRAUD_RT_ID,
    GetHelpConstants.IDENTITY_RT_ID,
    GetHelpConstants.RECIPIENT_MULE_RT_ID,
    GetHelpConstants.SCAM_RT_ID,
    GetHelpConstants.KYCQA_RT_ID
  };

  public static final Set<Id> DISPUTE_RT_IDS = new Set<Id>{
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID,
    GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID,
    GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
    GetHelpConstants.NPP_DISPUTE_RT_ID
  };

  // Set of record type Ids that will be sent to PEGA
  public static final Set<Id> DISPUTE_PEGA_RT_IDS = new Set<Id>{
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID,
    GetHelpConstants.NPP_DISPUTE_RT_ID
  };

  // Parent Case validation error message
  private static final String PARENT_CASE_ERROR = 'You cannot add parent case. This case is associated with child cases';

  private static final String MORE_THAN_TWO_ADDITIONAL_TYPES_ERROR_MSG = 'You cannot select more than two Additional Types.';
  private static final String SAME_ADDITIONAL_TYPES_ERROR_MSG = 'You cannot select a value in Additional Type that is already selected as the Primary Type.';
  private static final String NO_ENTITLEMENT_ERROR_MSG = 'No entitlement found for account.';
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
   * @description isANZPlusCaseType checks if record type is of ANZ Plus type.
   * As this Trigger will be used across various teams we identify case record based on ANZ Plus record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of ANZ Plus type false otherwise.
   */
  public static Boolean isANZPlusCaseType(Case record) {
    if (
      FRAUD_RT_IDS.contains(record.RecordTypeId) ||
      record.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID ||
      record.RecordTypeId == GetHelpConstants.BUG_RT_ID ||
      record.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID ||
      record.RecordTypeId == GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID ||
      DISPUTE_RT_IDS.contains(record.RecordTypeId)
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
   * @param records a list of cases that we need to check for bugs
   * @param bugIdSetParam a set of bug Ids
   * @return the set of bug record Ids
   */
  public static Set<Id> getBugIdSet(List<Case> records, Set<Id> bugIdSetParam) {
    Set<Id> bugIdSet = (bugIdSetParam != null) ? bugIdSetParam : new Set<Id>();
    for (Case c : records) {
      if (
        c.Related_Bug__c != null &&
        c.RecordTypeId == GetHelpConstants.BUG_RT_ID
      ) {
        bugIdSet.add(c.Related_Bug__c);
      }
    }
    return bugIdSet;
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
  public static List<Id> getEntitlementAccountIds(List<Case> caseList) {
    List<Id> accountIds = new List<Id>();

    for (Case c : caseList) {
      if (
        (c.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID ||
        c.RecordTypeId == GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID ||
        isDispute(c)) && c.AccountId != null
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
   * @return list of account ids
   */
  public static List<Entitlement> getEntitlements(
    List<Id> accountIds,
    String name
  ) {
    List<Entitlement> entList = new List<Entitlement>();
    entList = [
      SELECT Id, AccountId
      FROM Entitlement
      WHERE AccountId IN :accountIds AND EndDate = NULL AND Name = :name
    ];
    return entList;
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
        c.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID ||
        c.RecordTypeId == GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID ||
        isDispute(c)) && c.AccountId != null
      ) {
        if (!entMap.containsKey(c.AccountId)) {
          c.addError(NO_ENTITLEMENT_ERROR_MSG);
        } else {
          c.EntitlementId = entMap.get(c.AccountId);
        }
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
   * @description Check if a case is Fraud case
   * @param record The case record to check
   * @param oldCaseMap old case map
   * @return if the case is a Fraud case
   */
  public static Boolean isFraud(Case record, Map<Id, Case> oldCaseMap) {
    if (
      FRAUD_RT_IDS.contains(record.RecordTypeId) &&
      String.isNotBlank(record.Type) &&
      (oldCaseMap == null ||
      record.Type != oldCaseMap.get(record.Id).Type ||
      record.RecordTypeId != oldCaseMap.get(record.Id).RecordTypeId)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is Dispute Case
   * @param record The case record to check
   * @return if the case is a Dispute Case
   */
  public static Boolean isDispute(Case record) {
    if (DISPUTE_RT_IDS.contains(record.RecordTypeId)) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is Complaint case
   * @param record The case record to check
   * @param oldCaseMap old case map
   * @return if the case is a Complaint case
   */
  public static Boolean isComplaint(Case record, Map<Id, Case> oldCaseMap) {
    if (
      record.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID &&
      (oldCaseMap == null ||
      record.Type != oldCaseMap.get(record.Id).Type)
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
        Span_Id__c = UniqueIdUtil.getParentId(),
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
  public static void isNonCustomerComplaint(List<Case> records) {
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
}
