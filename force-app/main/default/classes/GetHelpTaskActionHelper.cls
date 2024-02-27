/**
 * @author Arpit Pittie
 * @since  02/2024
 * @description GetHelpTaskActionHelper is to handle all the GetHelp specific Task action helper methods
 */
public with sharing class GetHelpTaskActionHelper {
  /**
   * @description to filter out the coach nudge tasks
   * @param records All the tasks records
   * @return List<Task> list of coach nudge tasks
   */
  public static List<Task> filterCoachNudgeTasks(List<Task> records) {
    List<Task> coachNudgeTasks = new List<Task>();
    for (Task record : records) {
      if (record.RecordTypeId == GetHelpConstants.COACH_NUDGE_RT_ID) {
        coachNudgeTasks.add(record);
      }
    }
    return coachNudgeTasks;
  }

  /**
   * @description to get the set of Who Ids from task
   * @param records list of tasks to get the Who Id s from
   * @return Set<Id> a set of all the who ids
   */
  public static Set<Id> getWhoIdFromTask(List<Task> records) {
    Set<Id> accountIdSet = new Set<Id>();
    for (Task record : records) {
      if (record.whoId != null) {
        accountIdSet.add(record.whoId);
      }
    }
    return accountIdSet;
  }

  /**
   * @description to get the account details in a map
   * @param accountIdSet set of account Ids to be fetched
   * @return Map<Id, Account> a map containing Id to Account details
   */
  public static Map<Id, Account> getAccountMap(Set<Id> accountIdSet) {
    return new Map<ID, Account>(
      [
        SELECT Id, Source_System_Name__c, Source_System_ID__c
        FROM Account
        WHERE Id IN :accountIdSet
        WITH SECURITY_ENFORCED
      ]
    );
  }

  /**
   * @description To create the cloud events to be published for Coach Nudge tasks
   * @param records new task records
   * @param oldMap old Map of task records
   * @param accountMap map of account details
   * @return List<CloudEventModel> list of all the cloud event models to be published
   */
  public static List<CloudEventModel> getCloudEventModelForCoachNudge(
    List<Task> records,
    Map<Id, Task> oldMap,
    Map<Id, Account> accountMap
  ) {
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    for (Task record : records) {
      Task oldRec = (oldMap != null && oldMap.containsKey(record.Id))
        ? oldMap.get(record.Id)
        : null;
      if (
        (record.Status == 'Actioned' &&
        (oldRec == null ||
        oldRec.Status != 'Actioned')) ||
        (record.Status == 'Expired' &&
        (oldRec == null ||
        oldRec.Status != 'Expired'))
      ) {
        cloudEventModels.add(
          new NudgeTaskCloudEventModel(record, accountMap.get(record.whoId))
        );
      }
    }
    return cloudEventModels;
  }
}
