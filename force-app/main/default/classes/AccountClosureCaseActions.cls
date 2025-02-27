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

  public static Group accountClosureQueue = QueryQueue.get(
    'Account_Closure_Queue'
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
      if (childCase.Status != GetHelpConstants.CLOSED_STATUS) {
        childCase.Status = parentCase.Status;
      }
      childCase.Circumstance__c = parentCase.Circumstance__c;
    }

    DML_REPOSITORY.doUpdate(childCaseRecords);
  }

  /**
   * @description Change Owner as Account Closure Queue for escalated cases
   * @param escalatedCases List of Cases with record type as Case Group.
   */
  public static void assignEscalatedCasesToQueue(List<Case> escalatedCases) {
    for (Case escalatedCase : escalatedCases) {
      escalatedCase.OwnerId = accountClosureQueue.Id;
    }
  }

  /**
   * @description Populate the case Subject
   * @param cases List of Cases.
   * @param recordType Name of the record Type
   */
  public static void populateCaseSubject(List<Case> cases, String recordType) {
    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      ACCOUNT_CLOSURE_REPOSITORY.queryAccountName(accountIds)
    );

    for (Case caserecord : cases) {
      caserecord.Subject =
        recordType +
        ' - ' +
        accountIdToAccountInfoMap.get(caserecord.AccountId).Name;
    }
  }

  /**
   * @description Prevent Duplicate Case Group Against a Customer (Account)
   * @param parentCases List of Cases
   */
  public static void validateDuplicateParentCasePerAccount(
    List<Case> parentCases
  ) {
    Map<Id, Case> accountIdAndCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      parentCases,
      Case.AccountId
    );

    for (
      Case existingCaseGroupRecord : ACCOUNT_CLOSURE_REPOSITORY.queryExistingParentCases(
        accountIdAndCaseMap.keySet()
      )
    ) {
      Case caseRecord = accountIdAndCaseMap.get(
        existingCaseGroupRecord.AccountId
      );
      CommonUtil.addInfoToRecordAndLog(
        caseRecord,
        DUPLICATE_CASEGROUP_ERROR + existingCaseGroupRecord.CaseNumber
      );
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

  /**
   * @description Update button Visibility Flags
   * @param childCases List of Cases
   */
  public static void handleButtonVisibiltyFlags(List<Case> childCases) {
    Set<Id> parentCaseIds = ListUtil.getIds(childCases, Case.ParentId);

    if (parentCaseIds.isEmpty()) {
      return;
    }

    Set<Id> parentIdsForInitiatingPrecheck = ListUtil.getIds(
      ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForPrecheck(
        parentCaseIds
      ),
      Case.ParentId
    );
    Set<Id> parentIdsForAccountClosure = ListUtil.getIds(
      ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForClosure(
        parentCaseIds
      ),
      Case.ParentId
    );

    List<Case> parentCasesToUpdate = new List<Case>();
    for (Id parentId : parentCaseIds) {
      parentCasestoUpdate.add(
        new Case(
          Id = parentId,
          Show_Initiate_Account_Closure__c = parentIdsForInitiatingPrecheck.contains(
            parentId
          ),
          Show_Account_Closure__c = parentIdsForAccountClosure.contains(
            parentId
          )
        )
      );
    }
    DML_REPOSITORY.doUpdate(parentCasesToUpdate);
  }

  /**
   * @description This method process account closure cases and find if Case Group (Parent case) exists.
   * If none are found, it creates a new "Case Group" and links the "Account closure" cases to it.
   * @param childCases The list of Case records with record type as Account closure
   */
  public static void linkChildCasesWithParent(List<Case> childCases) {
    Set<Id> accountIds = ListUtil.getIds(childCases, Case.AccountId);

    Map<Id, Case> accountIdToExistingParentCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      ACCOUNT_CLOSURE_REPOSITORY.queryExistingParentCases(accountIds),
      Case.AccountId
    );

    List<Case> newParentCases = createParentCaseIfNotFound(
      childCases,
      accountIdToExistingParentCaseMap
    );

    Map<Id, Case> accountIdToNewParentCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      newParentCases,
      Case.AccountId
    );

    Map<Id, Case> accountIdToAllParentCasesMap = new Map<Id, Case>(
      accountIdToExistingParentCaseMap
    );
    accountIdToAllParentCasesMap.putAll(accountIdToNewParentCaseMap);

    for (Case caseRecord : childCases) {
      Case parentCase = accountIdToAllParentCasesMap.get(caseRecord.AccountId);
      caseRecord.ParentId = parentCase.Id;
      caseRecord.Status = parentCase.Status;
      caseRecord.Circumstance__c = parentCase.Circumstance__c;
      caseRecord.OwnerId = parentCase.OwnerId ?? UserInfo.getUserId();
    }
  }

  @TestVisible
  private static List<Case> createParentCaseIfNotFound(
    List<Case> childCases,
    Map<Id, Case> accountIdToExistingParentCaseMap
  ) {
    List<Case> newParentCases = new List<Case>();
    for (Case closureCase : childCases) {
      if (accountIdToExistingParentCaseMap.containsKey(closureCase.AccountId)) {
        continue;
      }

      Case newParentCase = new Case(
        RecordTypeId = RTCase.caseGroup,
        AccountId = closureCase.AccountId,
        Type = GetHelpConstants.ACCOUNT_CLOSURE
      );
      newParentCases.add(newParentCase);
    }
    DML_REPOSITORY.doInsert(newParentCases);
    return newParentCases;
  }

  /**
   * @description Update Initiate Precheck Button Visibility Flags on parent case on insert operation
   * @param childCases List of Cases
   */
  public static void initiatePrecheckButtonVisibility(List<Case> childCases) {
    List<Case> validCases = ListUtil.filter(childCases)
      .isNotNull(Case.FinServ__FinancialAccount__c)
      .isNotNull(Case.ParentId)
      .equals(Case.Status, GetHelpConstants.ESCALATED_STATUS)
      .toList();

    Set<Id> parentIdsForInitiatingPrecheck = ListUtil.getIds(
      validCases,
      Case.ParentId
    );

    List<Case> parentCasesToUpdate = new List<Case>();
    for (Id parentId : parentIdsForInitiatingPrecheck) {
      parentCasestoUpdate.add(
        new Case(Id = parentId, Show_Initiate_Account_Closure__c = true)
      );
    }
    DML_REPOSITORY.doUpdate(parentCasesToUpdate);
  }
}
