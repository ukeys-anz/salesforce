/**
 * @author Peter Charalambous
 * @since 11/2020
 * @description  MilestoneUtils handles marking milestones Completed on cases that match unique criteria
 * Util function is based on https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
 * @group Utils
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class MilestoneUtils {
  /**
   * @description completeMilestone is called before onBeforeUpdate and will mark a milestone as completed
   * based on the params
   * @param caseIds case ids to mark milestone as completed
   * @param milestoneName the name of the milestone to mark as complete
   * @param complDate the date/time the milestone was completed
   */
  public static void completeMilestone(
    List<Id> caseIds,
    String milestoneName,
    DateTime complDate
  ) {
    List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
    for (CaseMilestone cm : [
      SELECT Id, completionDate
      FROM CaseMilestone cm
      WHERE
        caseId IN :caseIds
        AND cm.MilestoneType.Name = :milestoneName
        AND completionDate = NULL
    ]) {
      cm.completionDate = complDate;
      cmsToUpdate.add(cm);
    }
    if (CaseMilestone.SObjectType.getDescribe().isUpdateable()) {
      update cmsToUpdate;
    }
  }

  /**
   * @description completeMilestone the milestones associated with the records based on the params
   * @param caseIds Set of case ids to mark milestone as completed
   * @param milestoneNames list of milestones to mark as complete
   * @param complDate the date/time the milestone is completed
   */
  public static void completeMilestone(
    Set<Id> caseIds,
    List<String> milestoneNames,
    DateTime complDate
  ) {
    List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
    for (CaseMilestone cm : [
      SELECT Id, CompletionDate
      FROM CaseMilestone cm
      WHERE
        caseId IN :caseIds
        AND cm.MilestoneType.Name IN :milestoneNames
        AND CompletionDate = NULL
    ]) {
      cm.CompletionDate = complDate;
      cmsToUpdate.add(cm);
    }
    if (
      CaseMilestone.SObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.CaseMilestone.fields.CompletionDate.isUpdateable()
    ) {
      update cmsToUpdate;
    } else {
      CommonUtil.logAndThrowIAE(
        'MilestoneUtils',
        'completeMilestone',
        'Not enough permissions to update CaseMilestone.'
      );
    }
  }
}
