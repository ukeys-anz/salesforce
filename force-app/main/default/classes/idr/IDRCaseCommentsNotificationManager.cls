/**
 *
 * @author Boobalakrishnan Duraisamy
 * @since 12/2020
 * @description Responsible to trigger the Notification when another user adds a case comment
 */
public with sharing class IDRCaseCommentsNotificationManager {
  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records CaseComment records in current trigger context
   */
  public static void manageNotification(List<CaseComment> records) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();

    Map<Id, Case> caseMap = getCaseRecords(records);

    for (CaseComment record : (List<CaseComment>) records) {
      if (caseMap.containsKey(record.ParentId)) {
        if (
          caseMap.get(record.ParentId).OwnerId != record.CreatedById &&
          IDRCaseActions.isIDRComplaintType(caseMap.get(record.ParentId))
        ) {
          wrapperList.add(createNotification(caseMap.get(record.ParentId)));
        }
      }
    }

    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }
  }

  /**
   * @description get case record details associated with the case comments
   * @param records case comment records from the trigger
   * @return getCaseMap case map
   */
  private static Map<Id, Case> getCaseRecords(List<CaseComment> records) {
    Set<Id> caseIds = new Set<Id>();
    Map<Id, Case> getCaseMap = new Map<Id, Case>();

    for (CaseComment record : (List<CaseComment>) records) {
      caseIds.add(record.ParentId);
    }

    for (Case c : [
      SELECT Id, RecordTypeId, CaseNumber, OwnerId
      FROM Case
      WHERE Id IN :caseIds AND Owner.isActive = TRUE
    ]) {
      getCaseMap.put(c.Id, c);
    }
    return getCaseMap;
  }

  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param record case record from the trigger
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  private static IDRBankerNotificationWrapper createNotification(Case record) {
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      record,
      new List<Id>{ record.OwnerId },
      record.CaseNumber,
      'New Case Comment added by ' + UserInfo.getName(),
      record
    );

    return wrapper;
  }
}
