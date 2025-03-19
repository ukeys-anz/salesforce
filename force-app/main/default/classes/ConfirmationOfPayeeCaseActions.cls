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
   */
  public static void populateChildCaseSubject(List<Case> cases) {
    for (Case caserecord : cases) {
      caserecord.Subject =
        (caserecord.Type ?? '') +
        ' - ' +
        (caserecord.Customer_Account_Number__c ?? '');
    }
  }

  /**
   * @description Update the flag for showing modify cop status button on insert operation
   * @param childCases List of Cases
   */
  public static void modifyCopStatusButtonVisibility(List<Case> childCases) {
    List<Case> validCases = ListUtil.filter(childCases)
      .isNotNull(Case.FinServ__FinancialAccount__c)
      .isNotNull(Case.ParentId)
      .notEquals(Case.Status, GetHelpConstants.CLOSED_STATUS)
      .toList();

    Set<Id> parentIdsForModifyCopStatus = ListUtil.getIds(
      validCases,
      Case.ParentId
    );

    List<Case> parentCasesToUpdate = new List<Case>();
    for (Id parentId : parentIdsForModifyCopStatus) {
      parentCasestoUpdate.add(
        new Case(Id = parentId, Show_Account_Closure__c = true)
      );
    }
    DML_REPOSITORY.doUpdate(parentCasesToUpdate);
  }
}
