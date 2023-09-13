/**
 * @author Ankita Kumari
 * @since 12/2023
 * @description CCRM Task Actions consists of all the Task related methods, this is a without sha.
 *              Class is declared as without sharing to allow status update from backend on ActionPlan object,
 *              the access provided org wide for ActionPlan and ActionaPlanTemplate is Public Read Only
 */
public without sharing class CCRMActionplanActions {
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }
  /**
   * @description update action plan status on task completion
   * @name updateActionPlanStatus
   * @param records updated task list
   * @param oldMap contains the map which holds the previous values of task records
   */
  public static void updateActionPlanStatus(
    List<Task> records,
    Map<Id, Task> oldMap
  ) {
    Set<Id> oppoIdSet = new Set<Id>();
    Set<Id> taskIdSet = new Set<Id>();
    Set<Id> actionPlanIdSet = new Set<Id>();
    Map<Id, ActionPlan> actionPlanMap = new Map<Id, ActionPlan>();
    String actionPlanStatus = '';
    try {
      for (Task iterator : records) {
        if (
          iterator.RecordTypeId == CCRMConstants.CCRM_TASK_RT_ID &&
          iterator.Status != oldMap.get(iterator.Id).Status &&
          String.valueOf(iterator.WhatId)
            .startsWith(CCRMConstants.OPPORTUNITY_OBJ_PREFIX)
        ) {
          oppoIdSet.add(iterator.WhatId);
          taskIdSet.add(iterator.Id);
        }
      }
      if (taskIdSet.isEmpty()) {
        return;
      }

      for (AggregateResult iterator : [
        SELECT ActionPlanId whatId
        FROM ActionPlanItem
        WHERE ItemId IN :taskIdSet
        GROUP BY ActionPlanId
      ]) {
        actionPlanIdSet.add(String.valueOf(iterator.get('WhatId')));
      }

      if (actionPlanIdSet.isEmpty()) {
        return;
      }

      for (ActionPlanItem iterator : [
        SELECT
          ActionPlan.TargetId,
          ActionPlan.Target.RecordTypeId,
          ActionPlan.ActionPlanState,
          Item.Status,
          ActionPlanId
        FROM ActionPlanItem
        WHERE
          ActionPlan.TargetId IN :oppoIdSet
          AND ActionPlanId IN :actionPlanIdSet
          AND ActionPlan.Target.RecordTypeId = :CCRMConstants.CCRM_OPP_RT_ID
          AND ActionPlan.ActionPlanState != :CCRMConstants.STATUS_COMPLETED
      ]) {
        actionPlanStatus = iterator.Item.Status.equalsIgnoreCase(
            CCRMConstants.STATUS_COMPLETED
          ) ||
          iterator.Item.Status.equalsIgnoreCase(
            CCRMConstants.STATUS_NOT_REQUIRED
          )
          ? CCRMConstants.STATUS_COMPLETED
          : CCRMConstants.STATUS_IN_PROGRESS;
        if (actionPlanStatus == iterator.ActionPlan.ActionPlanState) {
          continue;
        }
        if (
          actionPlanMap.containsKey(iterator.ActionPlanId) &&
          !iterator.Item.Status.equalsIgnoreCase(
            CCRMConstants.STATUS_COMPLETED
          ) &&
          !iterator.Item.Status.equalsIgnoreCase(
            CCRMConstants.STATUS_NOT_REQUIRED
          ) &&
          actionPlanMap.get(iterator.ActionPlanId).ActionPlanState !=
          CCRMConstants.STATUS_IN_PROGRESS
        ) {
          actionPlanMap.get(iterator.ActionPlanId)
            .ActionPlanState = CCRMConstants.STATUS_IN_PROGRESS;
        } else {
          actionPlanMap.put(
            iterator.ActionPlanId,
            new ActionPlan(
              Id = iterator.ActionPlanId,
              ActionPlanState = actionPlanStatus
            )
          );
        }
      }
      if (!actionPlanMap.isEmpty()) {
        List<Database.saveResult> result = Database.update(
          actionPlanMap.values(),
          true,
          AccessLevel.SYSTEM_MODE
        );
      }
    } catch (Exception ex) {
      Logger.error('Error in Action Plan Status update ', ex);
      Logger.saveLog();
      throw new CustomException(ex.getMessage());
    }
  }

  /**
   * @description update action plan status on task completion
   * @name updateTaskRecordType
   * @param newActionPlanMap new trigger map of Action Plan
   */
  public static void updateTaskRecordType(
    Map<Id, ActionPlan> newActionPlanMap
  ) {
    try {
      List<Task> taskList = new List<Task>();
      for (ActionPlanItem iterator : [
        SELECT
          ActionPlan.TargetId,
          ActionPlan.Target.RecordTypeId,
          ItemId,
          Item.RecordTypeId
        FROM ActionPlanItem
        WHERE
          ActionPlanId IN :newActionPlanMap.keySet()
          AND ActionPlan.Target.RecordTypeId = :CCRMConstants.CCRM_OPP_RT_ID
      ]) {
        taskList.add(
          new Task(
            Id = iterator.ItemId,
            RecordTypeId = CCRMConstants.CCRM_TASK_RT_ID,
            Status = CCRMConstants.STATUS_OPEN
          )
        );
      }
      if (!taskList.isEmpty()) {
        List<Database.saveResult> result = Database.update(
          taskList,
          true,
          AccessLevel.SYSTEM_MODE
        );
      }
    } catch (Exception ex) {
      Logger.error(
        'Error on setting record type of ActionPlan related task ',
        ex
      );
      Logger.saveLog();
      throw new CustomException(ex.getMessage());
    }
  }
}
