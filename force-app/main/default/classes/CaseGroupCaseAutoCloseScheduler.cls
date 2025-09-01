/**
 * @author Shivam Swaraj
 * @since 07/2025
 * @description Mark the parent Case Group case auto closed if all the account closure child cases are in Closed status.
 */
public with sharing class CaseGroupCaseAutoCloseScheduler implements Schedulable {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  /**
   * @description execute method to run logic to auto close case group cases having no open account closure child cases
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    Set<Id> caseGroupCasesToCloseIds = ListUtil.getIds(
      ACCOUNT_CLOSURE_REPOSITORY.queryCaseGroupCasesToClose(),
      Case.ParentId
    );

    List<Case> caseGroupCasesWithChild = ACCOUNT_CLOSURE_REPOSITORY.queryCaseGroupCasesWithChild(
      caseGroupCasesToCloseIds
    );

    List<Case> caseGroupCasesToUpdate = new List<Case>();
    for (Case parentCase : caseGroupCasesWithChild) {
      if (!parentCase.Cases.isEmpty()) {
        continue;
      }
      parentCase.Status = CaseGroupCaseConstants.CLOSED_STATUS;
      caseGroupCasesToUpdate.add(parentCase);
    }

    DML_REPOSITORY.doUpdate(
      caseGroupCasesToUpdate,
      new DmlConfig()
        .allowPartial()
        .errorLog(
          'Case Group Case Auto Close Scheduler: One or more case updates failed during execution. See database results for more details'
        )
    );
  }
}
