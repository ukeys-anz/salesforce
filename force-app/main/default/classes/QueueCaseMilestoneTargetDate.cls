/**
 * @author Hannah Sainumkheaw
 * @since 09/2023
 * @description Queueable apex class to update Case.Terget_SLA_Date__c while CaseMilestone being calculated asynchronously
 */
public with sharing class QueueCaseMilestoneTargetDate implements Queueable {
  List<Case> records;
  /**
   * @description setTargetDateOnCase update SLA Target Date once the case is created,
   * & update Case record with System Mode Context for Queueable Job
   * @param records The Case records passed from trigger
   */
  public QueueCaseMilestoneTargetDate(List<Case> records) {
    this.records = records;
  }

  /**
   * @description execute method
   * @param context QueueableContext to setTargetDate on ANZx Cases
   */
  public void execute(QueueableContext context) {
    List<Case> casesToUpdate = new List<Case>();
    Set<Id> caseIds = new Set<Id>();

    //ANZx caseIds filtering
    for (Case c : (List<Case>) records) {
      if (CheckCaseRecordType.isANZPlusCaseType(c)) {
        caseIds.add(c.Id);
      }
    }

    for (CaseMilestone cm : [
      SELECT Id, CaseId, TargetDate, MilestoneType.Name, Case.Target_SLA_Date__c
      FROM CaseMilestone
      WHERE
        MilestoneType.Name = :MilestoneHandler.RESOLUTION_TIME_MILESTONE
        AND caseId IN :caseIds
    ]) {
      if (
        cm.Case.Target_SLA_Date__c == null ||
        cm.Case.Target_SLA_Date__c != cm.TargetDate
      ) {
        casesToUpdate.add(
          new Case(Id = cm.CaseId, Target_SLA_Date__c = cm.TargetDate)
        );
      }
    }
    DMLUtil.updateRecords(
      casesToUpdate,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
  }
}
