public with sharing class IDRPendCaseTaskReminderWrapper {
  public Id taskId { get; set; }
  public Id caseId { get; set; }
  public Task taskRecord { get; set; }
  public Case caseRecord { get; set; }
  public Integer daysBetweenTaskDueDate { get; set; }
  public IDRPendCaseTaskReminderWrapper() {
  }
}
