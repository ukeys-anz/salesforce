/**
 * @author Ayushi Gupta
 * @since  01/2024
 * @group CCRM (Commercial CRM)
 * @description CCRMOpportunityActionsSkipStageHelper is class to handle all the operations on stage changes
 */
public with sharing class CCRMOpportunityActionsSkipStageHelper {
  /**
   * @description validate CCRM opportunities
   * @name validateCCRMOpportunity
   * @param oppWrapper CCRMOpportunity Wrapper
   * @param isInsert if the operation is insert
   */
  public static void validateCCRMOpportunity(
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper,
    Boolean isInsert
  ) {
    if (oppWrapper.filteredOpps.isEmpty()) {
      return;
    }

    for (Opportunity oppIterator : oppWrapper.filteredOpps) {
      String errorMessage = '';

      //check if stage is not equal to "Opportunity Identified" on creation of lead
      if (isInsert && oppIterator.StageName != CCRMConstants.OPP_IDENTIFIED) {
        errorMessage +=
          CCRMConstants.STAGE_CAN_BE_OPP_IDENTIFIED +
          CCRMConstants.NEW_LINE_CHAR;
      }
      //check if other source detail is provided if leadsource is other
      if (
        oppIterator.LeadSource == CCRMConstants.OTHER &&
        String.isBlank(oppIterator.Other_Source_Detail__c)
      ) {
        errorMessage +=
          CCRMConstants.OTHER_SOURCE_DETAIL_MANDATORY +
          CCRMConstants.NEW_LINE_CHAR;
      }
      //check if Lost reason and Lost reason details are provided if Opportunity is lost
      if (
        oppWrapper.stageUpdatedOpps.values().contains(oppIterator) &&
        oppIterator.StageName == CCRMConstants.OPP_LOST &&
        (String.isBlank(oppIterator.Lost_Reason__c) ||
        String.isBlank(oppIterator.Lost_Reason_Detail__c))
      ) {
        errorMessage +=
          CCRMConstants.LOST_REASON_DETAIL_MISSING +
          CCRMConstants.NEW_LINE_CHAR;
      }
      //check if Won from lost is provided for Won/Lost opportunity
      if (
        (oppWrapper.stageUpdatedOpps.values().contains(oppIterator) &&
        (oppIterator.StageName == CCRMConstants.OPP_LOST ||
        oppIterator.StageName == CCRMConstants.OPP_WON) &&
        String.isBlank(oppIterator.Won_from_Lost_to__c))
      ) {
        errorMessage +=
          CCRMConstants.WON_LOST_MANDATORY + CCRMConstants.NEW_LINE_CHAR;
      }

      //add error message
      if (String.isNotBlank(errorMessage)) {
        oppIterator.addError(
          errorMessage.removeEnd(CCRMConstants.NEW_LINE_CHAR)
        );
      }
    }
  }

  /**
   * @description Adds error if stage is skipped
   * @name addErrorForSkippedStage
   * @param stageUpdatedOpps list of opps having stage changes
   * @param oldOppMap map of id and old stage change opportunity
   * @param stageActionPlanMapping custom metadata map
   * @param oppsStageSegmentMap opps stage segment map
   */
  public static void addErrorForSkippedStage(
    List<Opportunity> stageUpdatedOpps,
    Map<Id, Opportunity> oldOppMap,
    Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping,
    Map<Id, String> oppsStageSegmentMap
  ) {
    for (Opportunity oppIterator : stageUpdatedOpps) {
      List<String> nextStage = new List<String>();

      CCRM_Commercial_Stage_Action_Plan__mdt metadata = stageActionPlanMapping.get(
        oppsStageSegmentMap.get(oppIterator.Id)
      );

      if (metadata != null && metadata.Next_Stage__c != null) {
        nextStage = metadata.Next_Stage__c.split(';');
      }

      if (
        oldOppMap.get(oppIterator.Id).StageName == metadata.Current_Stage__c &&
        oppIterator.StageName != metadata.Previous_Stage__c &&
        !nextStage.contains(oppIterator.StageName)
      ) {
        oppIterator.addError(CCRMConstants.SKIP_STAGE);
      }

      if (
        (oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.OPP_LOST ||
        oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.OPP_WON) &&
        String.isNotBlank(oppIterator.StageName)
      ) {
        oppIterator.addError(CCRMConstants.REOPEN_CLOSED_OPP);
      }
    }
  }

  /**
   * @description Display error for open task
   * @name displayErrorForMandatoryTask
   * @param oppIdToTemplateMap map of opportunity id and template name
   * @param oppsWithMandatoryTaskMap map of id and stage change opportunity
   */
  public static void displayErrorForMandatoryTask(
    Map<Id, String> oppIdToTemplateMap,
    Map<Id, Opportunity> oppsWithMandatoryTaskMap
  ) {
    if (oppIdToTemplateMap.keySet().isEmpty()) {
      return;
    }

    //get mandatory tasks on opportunity stage change
    for (AggregateResult iterator : [
      SELECT
        ActionPlan.TargetId oppId,
        Count(Id) itemCount,
        ActionPlan.ActionPlanTemplateVersion.ActionPlanTemplate.Name templateName
      FROM ActionPlanItem
      WHERE
        (ItemState = 'Pending'
        OR ItemState = 'InProgress')
        AND ActionPlan.ActionPlanTemplateVersion.Status = :CCRMConstants.PUBLISHED_TEMPLATE_STATUS
        AND ActionPlanTemplateItem.IsRequired = TRUE
        AND ActionPlan.TargetId IN :oppIdToTemplateMap.keySet()
      WITH SECURITY_ENFORCED
      GROUP BY
        ActionPlan.TargetId,
        ActionPlan.ActionPlanTemplateVersion.ActionPlanTemplate.Name
    ]) {
      Object oppId = iterator.get('oppId');
      Object templateName = iterator.get('templateName');
      Object itemCount = iterator.get('itemCount');
      List<String> actionPlanTemplates = oppIdToTemplateMap.get((Id) oppId)
        ?.split(';');

      if (
        actionPlanTemplates?.contains((String) templateName) &&
        (Integer) itemCount > 0
      ) {
        oppsWithMandatoryTaskMap.get(String.valueOf(oppId))
          .addError(System.Label.CCRM_OpenTasksOnOpportunityError);
      }
    }
  }

  /**
   * @description Validate open task when moving to closed stage.
   * @name checkOpenTaskForClosedOpportunities
   * @param closingOppoIdMap map of id and closing opportunity id
   */
  public static void checkOpenTaskForClosedOpportunities(
    Map<Id, Opportunity> closingOppoIdMap
  ) {
    if (closingOppoIdMap.isEmpty()) {
      return;
    }

    //get open tasks on opportunity being closed
    for (AggregateResult iterator : [
      SELECT WhatId
      FROM Task
      WHERE
        WhatId IN :closingOppoIdMap.keySet()
        AND Status != :CCRMConstants.STATUS_COMPLETED
        AND Status != :CCRMConstants.STATUS_NOT_REQUIRED
      WITH SECURITY_ENFORCED
      GROUP BY WhatId
    ]) {
      closingOppoIdMap.get(String.valueOf(iterator.get('WhatId')))
        .addError(System.Label.CCRM_OpenTasksOnOpportunityCloseError);
    }
  }
}
