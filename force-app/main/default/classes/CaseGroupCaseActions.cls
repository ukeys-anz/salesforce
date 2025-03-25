/**
 * @author Kopal Goswami
 * @since 11/2024
 * @description CaseGroupCaseActions class is to handle all the Case Group Case Actions
 */
public with sharing class CaseGroupCaseActions {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  public static final String DUPLICATE_CASEGROUP_ERROR = 'Error occurred while creating CaseGroup Case. A CaseGroup Case already exists for this customer. Case number: ';

  public static final String CASEGROUP_CLOSURE_ERROR_MESSAGE = 'Cannot close this Case as all related cases are not in closed status. Please ensure all related cases are closed.';

  /**
   * @description This Method fetch all the child case records records linked to the case group(Parent case)
   * then set the field value of the child cases same as parent case
   * @param parentCases holds all the case group(Parent case) records whose owner is changed.
   */
  public static void cascadeParentFieldChangesToChildCases(
    List<Case> parentCases
  ) {
    Map<Id, Case> parentIdAndCaseDetailsMap = new Map<Id, Case>(parentCases);

    List<Case> childCaseRecords = ACCOUNT_CLOSURE_REPOSITORY.queryRelatedChildCasesPerParent(
      parentIdAndCaseDetailsMap.keySet()
    );

    for (Case childCase : childCaseRecords) {
      Case parentCase = parentIdAndCaseDetailsMap.get(childCase.ParentId);
      childCase.OwnerId = parentCase.OwnerId;
      if (childCase.Status != CaseGroupCaseConstants.CLOSED_STATUS) {
        childCase.Status = parentCase.Status;
      }
      childCase.Circumstance__c = parentCase.Circumstance__c;
      childCase.Type = parentCase.Type;
    }

    DML_REPOSITORY.doUpdate(childCaseRecords);
  }

  /**
   * @description Prevent Duplicate Case Group Against a Customer (Account)
   * @param parentCases List of Cases
   */
  public static void validateDuplicateParentCasePerAccount(
    List<Case> parentCases
  ) {
    Map<String, Case> accountIdAndTypeCaseMap = prepareAccountIdAndTypeCaseMap(
      parentCases
    );
    Set<Id> accountIds = ListUtil.getIds(parentCases, Case.AccountId);

    for (
      Case existingCaseGroupRecord : ACCOUNT_CLOSURE_REPOSITORY.queryExistingParentCasesWithIssueType(
        accountIds
      )
    ) {
      String accountIdAndCaseTypeKey =
        existingCaseGroupRecord.AccountId + existingCaseGroupRecord.Type;
      Case caseRecord = accountIdAndTypeCaseMap.get(accountIdAndCaseTypeKey);
      if (caseRecord == null) {
        continue;
      }
      String errorMessage =
        DUPLICATE_CASEGROUP_ERROR + existingCaseGroupRecord.CaseNumber;
      Logger.info(errorMessage);
      caseRecord.addError(errorMessage);
    }
    Logger.saveLog();
  }

  @TestVisible
  private static Map<String, Case> prepareAccountIdAndTypeCaseMap(
    List<Case> parentCases
  ) {
    Map<String, Case> accountIdAndTypeCaseMap = new Map<String, Case>();

    for (Case parentCaseRecord : parentCases) {
      String accountIdAndCaseTypeKey =
        parentCaseRecord.AccountId + parentCaseRecord.Type;
      accountIdAndTypeCaseMap.put(accountIdAndCaseTypeKey, parentCaseRecord);
    }
    return accountIdAndTypeCaseMap;
  }

  /**
   * @description Populate the case Subject
   * @param cases List of case group/parent cases
   */
  public static void populateParentCaseSubject(List<Case> cases) {
    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      ACCOUNT_CLOSURE_REPOSITORY.queryAccountName(accountIds)
    );
    for (Case caserecord : cases) {
      caserecord.Subject =
        caserecord.Type +
        ' ' +
        CaseGroupCaseConstants.CASE_GROUP +
        ' - ' +
        accountIdToAccountInfoMap.get(caserecord.AccountId).Name;
    }
  }

  /**
   * @description Change Owner as Account Closure Queue for escalated cases
   * @param escalatedCases List of Cases with record type as Case Group.
   */
  public static void assignEscalatedCasesToQueue(List<Case> escalatedCases) {
    for (Case escalatedCase : escalatedCases) {
      if (escalatedCase.Type == CaseGroupCaseConstants.ACCOUNT_CLOSURE) {
        escalatedCase.OwnerId = QueryQueue.accountClosureQueue.Id;
      } else {
        escalatedCase.OwnerId = QueryQueue.copQueue.Id;
      }
    }
  }

  /**
   * @description Validate case group closure . Change status to closed when all related cases are in closed status.
   * @param parentCases List of Cases.
   */
  public static void validateParentClosureIfChildCasesOpen(
    List<Case> parentCases
  ) {
    Set<Id> caseIds = ListUtil.getIds(parentCases, Case.Id);
    List<Case> notClosedChildcases = ACCOUNT_CLOSURE_REPOSITORY.queryNotClosedChildCases(
      caseIds
    );
    Set<Id> parentCaseIdsWithOpenChildCases = ListUtil.getIds(
      notClosedChildcases,
      Case.ParentId
    );

    for (Case caseGroupRecord : parentCases) {
      if (parentCaseIdsWithOpenChildCases.contains(caseGroupRecord.Id)) {
        Logger.info(CASEGROUP_CLOSURE_ERROR_MESSAGE);
        caseGroupRecord.addError(CASEGROUP_CLOSURE_ERROR_MESSAGE);
      }
    }
    Logger.saveLog();
  }
}
