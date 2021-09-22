/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Helper class for @link GetHelpCaseActions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class GetHelpCaseActionsHelper {
  // Parent Case validation error message
  private static final String PARENT_CASE_ERROR = 'You cannot add parent case. This case is associated with child cases';

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
      GetHelpCaseActions.FRAUD_RT_IDS.contains(record.RecordTypeId) ||
      record.RecordTypeId == GetHelpCaseActions.GENERAL_INQUIRY_RT_ID ||
      record.RecordTypeId == GetHelpCaseActions.BUG_RT_ID ||
      record.RecordTypeId == GetHelpCaseActions.COMPLAINT_ID
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
        c.RecordTypeId == GetHelpCaseActions.BUG_RT_ID
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
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) // Already check for CRUD permissions in the parent method
  public static List<Reported_Bug__c> getReportedBugs(Set<Id> bugIdSet) {
    return [
      SELECT Id, (SELECT Id FROM Cases__r)
      FROM Reported_Bug__c
      WHERE Id IN :bugIdSet
    ];
  }

  /**
   * @description Get a list of account Ids from general enquiry cases
   * @param caseList a list of cases that we need to get account ids from
   * @return list of account ids
   */
  public static List<Id> getGeneralEnquiryAccountIds(List<Case> caseList) {
    List<Id> accountIds = new List<Id>();
    for (Case c : caseList) {
      if (
        (c.RecordTypeId == GetHelpCaseActions.GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == GetHelpCaseActions.COMPLAINT_ID) &&
        c.AccountId != null
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
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) // Already check for CRUD permission in the parent method
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
        (c.RecordTypeId == GetHelpCaseActions.GENERAL_INQUIRY_RT_ID ||
        c.RecordTypeId == GetHelpCaseActions.COMPLAINT_ID) &&
        c.AccountId != null
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
   * @description Get the Id of a record type using its developer name
   * @param developerName The developer name of the record type
   * @return the Id of the record type
   */
  public static Id getCaseRecordTypeIdByDeveloperName(String developerName) {
    if (String.isNotBlank(developerName)) {
      return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get(developerName)
        .getRecordTypeId();
    }
    return null;
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
      record.RecordTypeId == GetHelpCaseActions.GENERAL_INQUIRY_RT_ID &&
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
      GetHelpCaseActions.FRAUD_RT_IDS.contains(record.RecordTypeId) &&
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
    if (GetHelpCaseActions.DISPUTE_RT_IDS.contains(record.RecordTypeId)) {
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
      record.RecordTypeId == GetHelpCaseActions.COMPLAINT_ID &&
      (oldCaseMap == null ||
      record.Type != oldCaseMap.get(record.Id).Type)
    ) {
      return true;
    } else {
      return false;
    }
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
   * @description Complete milestone on Closed cases
   * @param closedCaseIds  list of closed case ids
   */
  @future
  public static void completeMilestoneOnClosedCases(List<Id> closedCaseIds) {
    MilestoneUtils.completeMilestone(
      closedCaseIds,
      GetHelpCaseActions.MILESTONE_NAME,
      System.now()
    );
  }
}
