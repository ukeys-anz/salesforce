/**
 * @author Kopal Goswami
 * @since 03/2025
 * @description ConfirmationOfPayeeCaseAction class is to handle all the ConfirmationOfPayee Case Actions
 */
public with sharing class ConfirmationOfPayeeCaseActions {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Update field on parent case for showing Modify COP status button
   * @param childCases List of Cases
   */
  public static void handleModifyCopAction(List<Case> childCases) {
    Set<Id> parentCaseIds = ListUtil.getIds(childCases, Case.ParentId);

    if (parentCaseIds.isEmpty()) {
      return;
    }

    Set<Id> parentIdsForModifyCopStatus = ListUtil.getIds(
      ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForCop(parentCaseIds),
      Case.ParentId
    );

    List<Case> parentCasesToUpdate = new List<Case>();
    for (Id parentId : parentCaseIds) {
      parentCasestoUpdate.add(
        new Case(
          Id = parentId,
          Show_Account_Closure__c = parentIdsForModifyCopStatus.contains(
            parentId
          )
        )
      );
    }

    DML_REPOSITORY.doUpdate(parentCasesToUpdate);
  }

  /**
   * @description Populate the case Subject
   * @param cases List of Cases.
   * @param recordType Name of the record Type
   */
  public static void populateChildCaseSubject(
    List<Case> cases,
    String recordType
  ) {
    Set<Id> financialAccountIds = ListUtil.getIds(
      cases,
      Case.FinServ__FinancialAccount__c
    );

    Map<Id, FinServ__FinancialAccount__c> finAccountIdToFinAccountDetailsMap = new Map<Id, FinServ__FinancialAccount__c>(
      ACCOUNT_CLOSURE_REPOSITORY.queryFinancialAccountNumber(
        financialAccountIds
      )
    );
    for (Case caserecord : cases) {
      String finAccountNumber = finAccountIdToFinAccountDetailsMap.containsKey(
          caserecord.FinServ__FinancialAccount__c
        )
        ? finAccountIdToFinAccountDetailsMap.get(
              caserecord.FinServ__FinancialAccount__c
            )
            .FinServ__FinancialAccountNumber__c
        : '';

      caserecord.Subject = recordType + ' - ' + finAccountNumber;
    }
  }
}
