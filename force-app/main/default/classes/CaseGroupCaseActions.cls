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

  public static Group accountClosureQueue = QueryQueue.get(
    'Account_Closure_Queue'
  );
  public static Group copQueue = QueryQueue.get('Confirmation_of_Payee_Queue');

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
      if (childCase.Status != GetHelpConstants.CLOSED_STATUS) {
        childCase.Status = parentCase.Status;
      }
      childCase.Circumstance__c = parentCase.Circumstance__c;
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
      Case caseRecord = accountIdAndTypeCaseMap.containsKey(
          accountIdAndCaseTypeKey
        )
        ? accountIdAndTypeCaseMap.get(accountIdAndCaseTypeKey)
        : null;
      if (caseRecord == null) {
        continue;
      }
      CommonUtil.addInfoToRecordAndLog(
        caseRecord,
        DUPLICATE_CASEGROUP_ERROR + existingCaseGroupRecord.CaseNumber
      );
    }
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
   * @param recordType Name of the record Type
   */
  public static void populateParentCaseSubject(
    List<Case> cases,
    String recordType
  ) {
    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      ACCOUNT_CLOSURE_REPOSITORY.queryAccountName(accountIds)
    );
    for (Case caserecord : cases) {
      caserecord.Subject =
        recordType +
        ' - ' +
        caserecord.Type +
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
      escalatedCase.OwnerId = (escalatedCase.Type ==
        GetHelpConstants.ACCOUNT_CLOSURE)
        ? accountClosureQueue.Id
        : copQueue.Id;
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

    Set<Id> parentCaseIdsWithOpenChildCases = fetchParentCaseIdOfOpenChildCases(
      caseIds
    );

    for (Case caseGroupRecord : parentCases) {
      if (parentCaseIdsWithOpenChildCases.contains(caseGroupRecord.Id)) {
        CommonUtil.addInfoToRecordAndLog(
          caseGroupRecord,
          CASEGROUP_CLOSURE_ERROR_MESSAGE
        );
      }
    }
  }

  @TestVisible
  private static Set<Id> fetchParentCaseIdOfOpenChildCases(Set<Id> caseIds) {
    Set<Id> parentCaseIdsWithOpenChildCases = new Set<Id>();
    for (
      Case childCaseRecord : ACCOUNT_CLOSURE_REPOSITORY.queryNotClosedChildCases(
        caseIds
      )
    ) {
      parentCaseIdsWithOpenChildCases.add(childCaseRecord.ParentId);
    }
    return parentCaseIdsWithOpenChildCases;
  }
}
