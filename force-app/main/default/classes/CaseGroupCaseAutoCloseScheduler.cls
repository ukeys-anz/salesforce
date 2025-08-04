/**
 * @author Shivam Swaraj
 * @since 07/2025
 * @description Mark the parent Case Group case auto closed if all the account closure child cases are in Closed status.
 */
public with sharing class CaseGroupCaseAutoCloseScheduler implements Schedulable {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final AccountClosureRepository ACCOUN_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  /**
   * @description execute method to run logic to auto close case group cases having no open account closure child cases
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    Map<Id, List<Case>> caseGroupCasesToCloseMap = (Map<Id, List<Case>>) ListUtil.groupBy(
      ACCOUN_CLOSURE_REPOSITORY.queryCaseGroupCasesToClose(),
      Case.ParentId
    );
    Map<Id, List<Case>> notClosedAcountClosureCases = (Map<Id, List<Case>>) ListUtil.groupBy(
      ACCOUN_CLOSURE_REPOSITORY.queryNotClosedAccountClosureCases(
        caseGroupCasesToCloseMap.keySet()
      ),
      Case.ParentId
    );

    List<Case> caseGroupCasesToUpdate = new List<Case>();
    for (Id parentCaseId : caseGroupCasesToCloseMap.keyset()) {
      if (notClosedAcountClosureCases.keySet().contains(parentCaseId)) {
        continue;
      }
      Case parentCase = new Case(
        Id = parentCaseId,
        Status = CaseGroupCaseConstants.CLOSED_STATUS
      );
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
