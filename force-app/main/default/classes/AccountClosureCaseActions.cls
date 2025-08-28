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

  public static final String ANZ_PLUS_APP_ORIGIN = 'ANZ Plus App';

  private static final Set<SObjectField> CASE_FIELDS = new Set<SObjectField>{
    Case.Status,
    Case.Sub_Status__c
  };

  /**
   * @description Populate the case Subject
   * @param cases List of Cases.
   */
  public static void populateCaseSubject(List<Case> cases) {
    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      ACCOUNT_CLOSURE_REPOSITORY.queryAccountName(accountIds)
    );

    for (Case caserecord : cases) {
      caserecord.Subject =
        CaseGroupCaseConstants.ACCOUNT_CLOSURE +
        ' - ' +
        accountIdToAccountInfoMap.get(caserecord.AccountId).Name;
    }
  }

  /**
   * @description Update button Visibility Flags
   * @param childCases List of Cases
   */
  public static void handleButtonVisibiltyFlags(List<Case> childCases) {
    Set<Id> parentCaseIds = ListUtil.getIds(childCases, Case.ParentId);

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
      caseRecord.Circumstance__c = parentCase.Circumstance__c;
      caseRecord.OwnerId = parentCase.OwnerId ?? UserInfo.getUserId();
      if (caseRecord.Origin != ANZ_PLUS_APP_ORIGIN) {
        caseRecord.Status = parentCase.Status;
      }
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
        Type = CaseGroupCaseConstants.ACCOUNT_CLOSURE
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
      .equals(Case.Status, CaseGroupCaseConstants.ESCALATED_STATUS)
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

  /**
   * @description This method set the field value of the child cases same as parent case
   * @param childCases holds all the child case records that are inserted
   */
  public static void cascadeParentFieldsToChildCases(List<Case> childCases) {
    Set<Id> parentIds = ListUtil.getIds(childCases, Case.ParentId);

    Map<Id, Case> parentIdAndCaseDetailsMap = new Map<Id, Case>(
      ACCOUNT_CLOSURE_REPOSITORY.queryParentCaseDetails(parentIds)
    );

    for (Case childCase : childCases) {
      Case parentCase = parentIdAndCaseDetailsMap.get(childCase.ParentId);
      childCase.OwnerId = parentCase.OwnerId;
      childCase.Circumstance__c = parentCase.Circumstance__c;
      childCase.Type = parentCase.Type;
      if (childCase.Origin != ANZ_PLUS_APP_ORIGIN) {
        childCase.Status = parentCase.Status;
      }
    }
  }
  /**
   * @description This method set the parent field status as escalated when any one of the child case has failed status
   * @param childCases holds all the child case records that are inserted/updated
   */
  public static void setParentCaseStatusAsEscalated(List<Case> childCases) {
    List<Case> validEscalatedCases = ListUtil.filter(childCases)
      .equals(Case.Status, CaseGroupCaseConstants.ESCALATED_STATUS)
      .equals(
        Case.Sub_Status__c,
        new Set<String>{
          CaseGroupCaseConstants.FAILED,
          CaseGroupCaseConstants.SUCCESS
        }
      )
      .equals(Case.Origin, ANZ_PLUS_APP_ORIGIN)
      .isNotNull(Case.FinServ__FinancialAccount__c)
      .isNotNull(Case.ParentId)
      .toList();

    List<Case> parentCasesToUpdate = new List<Case>();

    Set<Id> parentIds = ListUtil.getIds(validEscalatedCases, Case.ParentId);

    Map<Id, Case> parentIdAndCaseDetailsMap = new Map<Id, Case>(
      ACCOUNT_CLOSURE_REPOSITORY.queryNotEscalatedParentCaseDetails(parentIds)
    );

    for (Case childCase : validEscalatedCases) {
      Case parentCase = parentIdAndCaseDetailsMap.get(childCase.ParentId);
      parentCase.Status = CaseGroupCaseConstants.ESCALATED_STATUS;
      parentCasesToUpdate.add(parentCase);
    }

    DML_REPOSITORY.doUpdate(parentCasesToUpdate);
  }

  /**
   * @description This method filters the cases which are updated to withdrawn status and has a valid Financial Account and parent case
   * @param records List of Cases that are updated
   * @param oldMap Map of old cases
   */
  public static void setAccountDetailsAsEmpty(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> validWithdrawnCases = ListUtil.filter(records, oldMap)
      .anyChanged(CASE_FIELDS)
      .equals(Case.Status, CaseGroupCaseConstants.WITHDRAWN_STATUS)
      .isNotNull(Case.FinServ__FinancialAccount__c)
      .isNotNull(Case.ParentId)
      .toList();

    ListUtil.setField(
      validWithdrawnCases,
      new Map<SObjectField, Object>{
        Case.FinServ__FinancialAccount__c => null,
        Case.ProductId => null,
        Case.Process_Id__c => null
      }
    );
  }
}
