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

  private static final Integer DEFAULT_BATCH_SIZE = 200;

  private Integer batchSize;

  /**
   * @description No-arg constructor required by the platform when instantiating scheduled Apex.
   */
  public CaseGroupCaseAutoCloseScheduler() {
    this.batchSize = DEFAULT_BATCH_SIZE;
  }

  /**
   * @description Constructor for processing a list of SObjects
   * @param batchSize Number of records to process per execution
   */
  public CaseGroupCaseAutoCloseScheduler(Integer batchSize) {
    this.batchSize = (batchSize == null ||
      batchSize <= 0)
      ? DEFAULT_BATCH_SIZE
      : batchSize;
  }

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

    if (caseGroupCasesToUpdate.isEmpty()) {
      return;
    }

    System.enqueueJob(
      new ProcessRecordsInChunksQueueable(
        caseGroupCasesToUpdate,
        batchSize,
        ProcessRecordsInChunksQueueable.DMLOperation.DML_UPDATE
      )
    );
  }
}
