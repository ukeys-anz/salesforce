/**
 * @author Ankita Kumari
 * @since 12/2023
 * @description CCRM Task Actions consists of all the Task related methods, this is a without sha.
 *              Class is declared as without sharing to allow status update from backend on ActionPlan object,
 *              the access provided org wide for ActionPlan and ActionaPlanTemplate is Public Read Only
 */
public without sharing class CCRMActionplanActions {
  @testvisible
  private static List<SObject> mockResults {
    get;
    set {
      mockResults = value;
    }
  }

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
   * If(Opportunity Stage = 'Needs Analysis' OR 'Customer Acceptance'){
   *  get all CCRM_Commercial_Stage_Action_Plan__mdt
   *  create Map<String(Opportunity Record Type+Segment+Stage Name), ActionPlanTemplateName>
   *  get all published ActionPlanTemplates
   *  create ActionPlan records for each opportunity
   * }
   * @name validateAndInsertActionPlans
   * @param oppWrapper CCRMOpportunityWrapper
   * @param oldOppMap map of old records
   */
  public static void validateAndInsertActionPlans(
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper,
    Map<Id, Opportunity> oldOppMap
  ) {
    try {
      Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping = new Map<String, CCRM_Commercial_Stage_Action_Plan__mdt>();

      stageActionPlanMapping = CCRMOpportunityActions.getStageActionPlanMetadata(
        oppWrapper.filteredOpps
      );

      oppWrapper = CCRMOpportunityActions.getStageSegmentOrTemplateMap(
        oppWrapper,
        oldOppMap,
        stageActionPlanMapping
      );

      //Check for existing action plans
      Map<Id, List<String>> oppsWithActionPlans = checkForExistingActionPlans(
        oppWrapper.oppIdToTemplateNameMap
      );

      //Get opps with No Action Plans
      CCRMActionPlanWrapper planWrapper = getOppsWithNoActionPlans(
        oppsWithActionPlans,
        oppWrapper
      );

      List<ActionPlan> actionPlans = insertActionPlans(planWrapper, oppWrapper);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }

  /**
   * @description check for existing action plans for a particular stage
   * @name checkForExistingActionPlans
   * @param oppIdToTemplateNameMap Map of opp Id and Template Names
   * @return templateMap Map<Id, String>
   */
  @testVisible
  private static Map<Id, List<String>> checkForExistingActionPlans(
    Map<Id, String> oppIdToTemplateNameMap
  ) {
    Map<Id, List<String>> oppsWithActionPlans = new Map<Id, List<String>>();
    List<ActionPlan> actionPlansList = new List<ActionPlan>();

    if (oppIdToTemplateNameMap.keySet().isEmpty()) {
      return oppsWithActionPlans;
    }

    if (!Schema.sObjectType.ActionPlan.isQueryable()) {
      CommonUtil.logAndThrowIAE(
        'CCRMActionplanActions',
        'checkForExistingActionPlans',
        'Not enough permissions to query ActionPlan.'
      );
    }

    actionPlansList = getActionPlans(oppIdToTemplateNameMap);

    for (ActionPlan actionPlan : actionPlansList) {
      getOppsWithActionPlans(
        actionPlan,
        oppsWithActionPlans,
        oppIdToTemplateNameMap
      );
    }
    return oppsWithActionPlans;
  }

  private static List<ActionPlan> getActionPlans(
    Map<Id, String> oppIdToTemplateNameMap
  ) {
    if (mockResults != null) {
      return mockResults;
    }
    return [
      SELECT
        Id,
        TargetId,
        ActionPlanTemplateVersion.Status,
        ActionPlanTemplateVersion.ActionPlanTemplate.Name
      FROM ActionPlan
      WHERE
        TargetId IN :oppIdToTemplateNameMap.keySet()
        AND ActionPlanTemplateVersion.Status = :CCRMConstants.PUBLISHED_TEMPLATE_STATUS
      WITH SECURITY_ENFORCED
    ];
  }

  private static Map<Id, List<String>> getOppsWithActionPlans(
    ActionPlan actionPlan,
    Map<Id, List<String>> oppsWithActionPlans,
    Map<Id, String> oppIdToTemplateNameMap
  ) {
    String templateName = oppIdToTemplateNameMap.get(actionPlan.TargetId);
    if (
      templateName.split(';')
        .contains(actionPlan.ActionPlanTemplateVersion.ActionPlanTemplate.Name)
    ) {
      if (!oppsWithActionPlans.containsKey(actionPlan.TargetId)) {
        oppsWithActionPlans.put(actionPlan.TargetId, new List<String>());
      }
      oppsWithActionPlans.get(actionPlan.TargetId)
        .add(actionPlan.ActionPlanTemplateVersion.ActionPlanTemplate.Name);

      return oppsWithActionPlans;
    }
    return new Map<Id, List<String>>();
  }

  @testVisible
  private static CCRMActionPlanWrapper getOppsWithNoActionPlans(
    Map<Id, List<String>> oppsWithActionPlans,
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper
  ) {
    Set<String> templates = new Set<String>();
    Map<Id, List<String>> filteredOppIdToTemplateNameMap = new Map<Id, List<String>>();
    Set<Id> oppIdsWithNoActionPlansSet = new Set<Id>();

    if (oppWrapper.oppIdToTemplateNameMap.keySet().isEmpty()) {
      return null;
    }

    oppIdsWithNoActionPlansSet = oppWrapper.oppIdToTemplateNameMap.keySet();
    oppIdsWithNoActionPlansSet.removeAll(oppsWithActionPlans.keySet());

    if (oppIdsWithNoActionPlansSet.isEmpty()) {
      return null;
    }

    for (Id oppId : oppIdsWithNoActionPlansSet) {
      List<String> templateNames = oppWrapper.oppIdToTemplateNameMap.get(oppId)
        .split(';');

      filteredOppIdToTemplateNameMap.put(oppId, templateNames);
      templates.addAll(templateNames);
    }

    CCRMActionPlanWrapper planWrapper = new CCRMActionPlanWrapper();
    planWrapper.oppsWithNoActionPlansToTemplateNameMap = filteredOppIdToTemplateNameMap;
    planWrapper.templates = templates;
    return planWrapper;
  }

  @testVisible
  private static List<ActionPlan> insertActionPlans(
    CCRMActionPlanWrapper planWrapper,
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper
  ) {
    List<ActionPlan> actionPlanToInsert = new List<ActionPlan>();
    Map<String, String> apTempMap = new Map<String, String>();
    List<ActionPlanTemplateVersion> actionTemplateVersionList = new List<ActionPlanTemplateVersion>();

    if (planWrapper.oppsWithNoActionPlansToTemplateNameMap.keySet().isEmpty()) {
      return null;
    }

    if (!Schema.sObjectType.ActionPlanTemplateVersion.isQueryable()) {
      CommonUtil.logAndThrowIAE(
        'CCRMActionplanActions',
        'insertActionPlans',
        'Not enough permissions to query ActionPlanTemplateVersion.'
      );
    }

    actionTemplateVersionList = getActionPlanTemplateVersionList(planWrapper);

    for (ActionPlanTemplateVersion apIterator : actionTemplateVersionList) {
      apTempMap.put(apIterator.ActionPlanTemplate.Name, apIterator.Id);
    }

    for (
      Id oppId : planWrapper.oppsWithNoActionPlansToTemplateNameMap.keySet()
    ) {
      List<String> templateNames = planWrapper.oppsWithNoActionPlansToTemplateNameMap.get(
        oppId
      );
      for (String name : templateNames) {
        if (apTempMap.containsKey(name)) {
          actionPlanToInsert.add(
            createActionPlan(
              oppId,
              name,
              apTempMap.get(name),
              oppWrapper.oppIdToOwnerIdMap.get(oppId)
            )
          );
        }
      }
    }

    if (!actionPlanToInsert.isEmpty()) {
      insert actionPlanToInsert;
    }
    return actionPlanToInsert;
  }

  private static List<ActionPlanTemplateVersion> getActionPlanTemplateVersionList(
    CCRMActionPlanWrapper planWrapper
  ) {
    if (mockResults != null) {
      return mockResults;
    }
    return [
      SELECT Id, Name, ActionPlanTemplate.Name
      FROM ActionPlanTemplateVersion
      WHERE ActionPlanTemplate.Name IN :planWrapper.templates
      WITH SECURITY_ENFORCED
    ];
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

  /**
   * @description wrapper class for Action Plans
   */
  public class CCRMActionPlanWrapper {
    public Map<Id, List<String>> oppsWithNoActionPlansToTemplateNameMap = new Map<Id, List<String>>();
    public Set<String> templates = new Set<String>();
  }
}
