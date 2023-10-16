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

  /**
   * @description Add Action plan to Opportunity when Opportunity moved to 'Need Analysis' stage.
   * @name insertActionPlans
   * @param newOppList list of new records
   * @param oldOppMap map of old records
   */
  public static void insertActionPlans(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    Map<String, List<String>> actionPlanTemplateMap = new Map<String, List<String>>();
    List<ActionPlan> actionPlanToInsert = new List<ActionPlan>();
    Set<String> oppIdsList = new Set<String>();
    Set<String> actionPlanTempSet = new Set<String>();
    String actionPlanName = '';

    for (Opportunity opp : newOppList) {
      if (
        opp.recordTypeId == CCRMConstants.CCRM_OPP_RT_ID &&
        opp.StageName != oldOppMap.get(opp.Id).StageName &&
        (opp.StageName.equalsIgnoreCase(CCRMConstants.NEED_ANALYSIS) ||
        opp.StageName.equalsIgnoreCase(CCRMConstants.CUST_ACCEPT))
      ) {
        oppIdsList.add(opp.Id);
      }
    }

    if (oppIdsList.isEmpty()) {
      return;
    }

    for (
      CCRM_Action_Plan_Template_Selection__mdt iterator : CCRM_Action_Plan_Template_Selection__mdt.getAll()
        .values()
    ) {
      if (iterator.Template_Name__c.contains(';')) {
        actionPlanTemplateMap.put(
          (iterator.Opportunity_Record_Type__c +
            iterator.Commercial_Segment__c +
            iterator.Opportunity_Stage_Name__c)
            .deleteWhitespace()
            .toLowerCase(),
          new List<String>(iterator.Template_Name__c.split(';'))
        );
        actionPlanTempSet.addAll(iterator.Template_Name__c.split(';'));
      } else {
        actionPlanTemplateMap.put(
          (iterator.Opportunity_Record_Type__c +
            iterator.Commercial_Segment__c +
            iterator.Opportunity_Stage_Name__c)
            .deleteWhitespace()
            .toLowerCase(),
          new List<String>{ iterator.Template_Name__c }
        );
        actionPlanTempSet.add(iterator.Template_Name__c);
      }
    }

    Map<String, String> apTempMap = new Map<String, String>();
    for (ActionPlanTemplateVersion apIterator : [
      SELECT Id, Name
      FROM ActionPlanTemplateVersion
      WHERE
        Name IN :actionPlanTempSet
        AND Status = :CCRMConstants.PUBLISHED_TEMPLATE_STATUS
    ]) {
      apTempMap.put(apIterator.Name, apIterator.Id);
    }

    for (Opportunity oppIter : [
      SELECT
        Id,
        Owner.Commercial_Segment__c,
        StageName,
        OwnerId,
        RecordType.DeveloperName
      FROM Opportunity
      WHERE Id IN :oppIdsList
    ]) {
      actionPlanName = (oppIter.RecordType.DeveloperName +
        oppIter.Owner.Commercial_Segment__c +
        oppIter.StageName)
        .deleteWhitespace()
        .toLowerCase();
      if (
        actionPlanTemplateMap.containsKey(actionPlanName) &&
        !actionPlanTemplateMap.get(actionPlanName).isEmpty()
      ) {
        for (
          String tempNameIterator : actionPlanTemplateMap.get(actionPlanName)
        ) {
          if (apTempMap.containsKey(tempNameIterator)) {
            actionPlanToInsert.add(
              createActionPlan(
                oppIter.Id,
                tempNameIterator,
                apTempMap.get(tempNameIterator),
                oppIter.OwnerId
              )
            );
          }
        }
      }
    }
    if (!actionPlanToInsert.isEmpty()) {
      insert actionPlanToInsert;
    }
  }

  /**
   * @description create action Plan
   * @name createActionPlan
   * @param oppId Id of opportunity to link action plan with
   * @param actionPlanName name of the action plan
   * @param actionPlanTempId Id of Action Plan Template Version
   * @param ownerId opportunity owner id
   * @return ActionPlan instance
   */
  public static ActionPlan createActionPlan(
    Id oppId,
    String actionPlanName,
    String actionPlanTempId,
    String ownerId
  ) {
    ActionPlan apRec = new ActionPlan();
    apRec.ActionPlanType = CCRMConstants.PLAN_TYPE;
    apRec.TargetId = oppId;
    apRec.ActionPlanState = CCRMConstants.NOT_STARTED;
    apRec.StartDate = System.today();
    apRec.OwnerId = ownerId;
    apRec.Name = actionPlanName;
    apRec.ActionPlanTemplateVersionId = actionPlanTempId;
    return apRec;
  }
}
