/**
 * @author Kopal Goswami
 * @since 11/2024
 * @description AccountClosureCaseActions class is to handle all the Account Closure Case Actions
 */
public with sharing class AccountClosureCaseActions {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  public static final String DUPLICATE_CASEGROUP_ERROR = 'Error occurred while creating CaseGroup Case. A CaseGroup Case already exists for this customer. Case number: ';

  /**
   * @description This method process account closure cases and find if Case Group (Parent case) exists.
   * If none are found, it creates a new "Case Group" and links the "Account closure" cases to it.
   * @param records The list of Case records with record type as Account closure
   */
  public static void assignParentCaseToChildCase(List<Case> records) {
    List<Case> cases = getAccountClosureCasesWithoutParent(records);
    if (cases == null || cases.isEmpty()) {
      return;
    }

    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);
    List<Case> caseGroupRecords = ACCOUNT_CLOSURE_REPOSITORY.queryNotClosedCaseGroups(
      accountIds
    );
    Map<Id, Case> accountIdToExistingParentCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      caseGroupRecords,
      Case.AccountId
    );

    List<Case> newCaseGroups = AccountClosureCaseActionsHelper.setFieldsForNewParentCase(
      cases,
      accountIdToExistingParentCaseMap
    );

    Map<Id, Case> accountIdToNewParentCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      newCaseGroups,
      Case.AccountId
    );

    if (newCaseGroups != null && !newCaseGroups.isEmpty()) {
      DML_REPOSITORY.doInsert(newCaseGroups);
    }

    AccountClosureCaseActionsHelper.assignClosureCasesToParentCase(
      cases,
      accountIdToExistingParentCaseMap,
      accountIdToNewParentCaseMap
    );
  }

  /**
   * @description This Method fetch all the child case records records linked to the case group(Parent case)
   * then set the field value of the child cases same as parent case
   * @param records holds all the case group(Parent case) records whose owner is changed.
   * @param oldMap holds the field values of old record
   */
  public static void updateChildCaseField(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> cases = getCaseGroupRecordTypeForAccountClosure(records);
    if (cases == null || cases.isEmpty()) {
      return;
    }

    Set<Schema.SObjectField> fieldsToMonitor = new Set<Schema.SObjectField>{
      Case.OwnerId,
      Case.Status,
      Case.Circumstance__c
    };
    List<Case> changedParentCases = RecordComparisonUtil.getRecordsWithChangedFields(
      cases,
      oldMap,
      fieldsToMonitor
    );

    if (changedParentCases == null || changedParentCases.isEmpty()) {
      return;
    }

    Map<Id, Case> parentIdAndCaseDetailsMap = new Map<Id, Case>(
      changedParentCases
    );

    List<Case> childCaseRecords = ACCOUNT_CLOSURE_REPOSITORY.queryChildCaseRecords(
      parentIdAndCaseDetailsMap.keySet()
    );

    List<Case> recordsToBeUpdated = AccountClosureCaseActionsHelper.setChildCaseField(
      childCaseRecords,
      oldMap,
      parentIdAndCaseDetailsMap,
      fieldsToMonitor
    );

    if (recordsToBeUpdated == null || recordsToBeUpdated.isEmpty()) {
      return;
    }

    DML_REPOSITORY.doUpdate(recordsToBeUpdated);
  }

  /**
   * @description Change Owner as Account Closure Queue for escalated cases
   * @param records List of Cases with record type as Case Group.
   * @param oldMap Old Map of Cases
   */
  public static void setQueueOwnerToEscalatedCases(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> cases = getCaseGroupRecordTypeForAccountClosure(records);

    if (cases == null || cases.isEmpty()) {
      return;
    }

    List<Case> escalatedCases = ListUtil.filter(cases, oldMap)
      .changedTo(Case.Status, GetHelpConstants.ESCALATED_STATUS)
      .toList();

    if (escalatedCases == null || escalatedCases.isEmpty()) {
      return;
    }

    AccountClosureCaseActionsHelper.assignOwnerAsQueue(escalatedCases);
  }

  /**
   * @description Populate the case Subject
   * @param cases List of Cases.
   * @param oldMap Old Map of Cases
   */
  public static void populateCaseSubject(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    if (oldMap != null) {
      cases = ListUtil.filter(cases, oldMap).changed(Case.AccountId).toList();
    }

    if (cases == null || cases.isEmpty()) {
      return;
    }

    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);

    List<Account> accountInfo = ACCOUNT_CLOSURE_REPOSITORY.queryAccountName(
      accountIds
    );

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      accountInfo
    );

    AccountClosureCaseActionsHelper.assignCaseSubject(
      cases,
      accountIdToAccountInfoMap
    );
  }

  /**
   * @description Prevent Duplicate Case Group Against a Customer (Account)
   * @param records List of Cases
   * @param oldMap Map of old Case values
   */
  public static void validateDuplicateCaseGroupPerAccount(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<Case> cases = getCaseGroupRecordTypeForAccountClosure(records);

    if (oldMap != null) {
      cases = getChangedRecords(cases, oldMap, case.AccountId);
    }

    if (cases == null || cases.isEmpty()) {
      return;
    }

    Map<Id, Case> accountIdAndCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      cases,
      Case.AccountId
    );

    List<Case> existingCaseGroupRecords = ACCOUNT_CLOSURE_REPOSITORY.queryNotClosedCaseGroups(
      accountIdAndCaseMap.keySet()
    );
    for (Case existingCaseGroupRecord : existingCaseGroupRecords) {
      Case caseRecord = accountIdAndCaseMap.get(
        existingCaseGroupRecord.AccountId
      );
      CommonUtil.addErrorToRecordAndLog(
        caseRecord,
        DUPLICATE_CASEGROUP_ERROR + existingCaseGroupRecord.CaseNumber
      );
    }
  }

  /**
   * @description Update button Visibility Flags
   * @param records List of Cases
   * @param oldMap Map of old Case values
   */
  public static void handleButtonVisibiltyFlag(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<Case> cases = (records != null && !records.isEmpty())
      ? getAccountClosureRecords(records)
      : new List<Case>();

    List<Case> filteredCases = new List<Case>();

    if (oldMap != null) {
      filteredCases.addAll(getChangedRecords(cases, oldMap, case.Status));
      filteredCases.addAll(
        getChangedRecords(cases, oldMap, case.Sub_Status__c)
      );
    }

    Set<Id> parentCaseIds = ListUtil.getIds(
      oldMap != null ? filteredCases : cases,
      Case.ParentId
    );

    if (cases == null || cases.isEmpty()) {
      return;
    }

    List<Case> eligibleChildCasesForInitiatingClosure = ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCaseRecords(
      parentCaseIds
    );

    List<Case> eligibleChildCasesForAccountClosure = ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesForClosure(
      parentCaseIds
    );

    Set<Id> parentIdsForInitiatingClosure = ListUtil.getIds(
      eligibleChildCasesForInitiatingClosure,
      Case.ParentId
    );
    Set<Id> parentIdsForAccountClosure = ListUtil.getIds(
      eligibleChildCasesForAccountClosure,
      Case.ParentId
    );

    List<Case> parentCasesToUpdate = AccountClosureCaseActionsHelper.setParentFieldValues(
      parentCaseIds,
      parentIdsForInitiatingClosure,
      parentIdsForAccountClosure
    );

    DML_REPOSITORY.doUpdate(parentCasesToUpdate);
  }

  //Fetch Records with Account Closure record type and no Parent case attached to it
  private static List<Case> getAccountClosureCasesWithoutParent(
    List<Case> records
  ) {
    return ListUtil.filter(records)
      .equals(case.RecordTypeId, RTCase.accountClosure)
      .isNull(Case.ParentId)
      .toList();
  }

  //Fetch records with Case Group record type
  private static List<Case> getCaseGroupRecordTypeForAccountClosure(
    List<Case> records
  ) {
    return ListUtil.filter(records)
      .equals(case.RecordTypeId, RTCase.caseGroup)
      .equals(Case.Type, GetHelpConstants.ACCOUNT_CLOSURE)
      .toList();
  }

  //Fetch records with Account Closure record type
  private static List<Case> getAccountClosureRecords(List<Case> records) {
    return ListUtil.filter(records)
      .equals(Case.RecordTypeId, RTCase.accountClosure)
      .toList();
  }

  //Fetch records if the mentioned field value gets updated
  private static List<Case> getChangedRecords(
    List<Case> records,
    Map<Id, SObject> oldMap,
    Schema.SObjectField fieldName
  ) {
    return ListUtil.filter(records, oldMap).changed(fieldName).toList();
  }
}
