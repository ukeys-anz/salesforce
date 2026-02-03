/**
 * @author Ayushi Gupta
 * @since 02/2026
 * @description CommercialAFPActionsExtended is the extended class for commercial app form product actions class.
 */
public with sharing class CommercialAFPActionsExtended {
  @testVisible
  private static final String TASKS_ERROR_MSG = 'Please close all open tasks before closing the Opportunity.';
  @testVisible
  private static final String OPP_WON = 'Opportunity Won';
  private static final CommercialOpportunityRepository COMMERCIALOPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );

  /**
   * @description This check for open tasks on opportunity
   * @name checkForOpenTasks
   * @param appFormProducts app forms
   * @param filteredAfpList afp list
   * @param oppsToUpdate opps
   */
  public static void checkForOpenTasks(
    List<ApplicationFormProduct> appFormProducts,
    List<ApplicationFormProduct> filteredAfpList,
    Map<Id, Opportunity> oppsToUpdate
  ) {
    Set<Id> oppIds = new Set<Id>();
    Set<Id> oppIdsWithTasks = new Set<Id>();
    for (ApplicationFormProduct afp : appFormProducts) {
      oppIds.add(afp.ApplicationForm.OpportunityId);
    }
    if (oppIds.isEmpty()) {
      return;
    }
    //get open tasks on opportunity being closed
    List<Map<String, Object>> openTasks = COMMERCIALOPP_REPOSITORY.getOpenTasksOnClosedOpportunity(
      oppIds
    );
    for (Map<String, Object> iterator : openTasks) {
      oppIdsWithTasks.add(String.valueOf(iterator.get('WhatId')));
    }
    List<ApplicationFormProduct> afpWithTasks = getAFPsWithTasks(
      appFormProducts,
      oppIdsWithTasks,
      oppsToUpdate
    );
    Map<Id, ApplicationFormProduct> afpWithTasksMap = new Map<Id, ApplicationFormProduct>(
      afpWithTasks
    );
    for (ApplicationFormProduct afp : filteredAfpList) {
      if (afpWithTasksMap.containsKey(afp.Id)) {
        afp.addError(TASKS_ERROR_MSG);
      }
    }
  }

  /**
   * @description returns AFPs having opps with tasks
   * @name getAFPsWithTasks
   * @param appFormProducts app form products
   * @param oppIdsWithTasks opp ids with tasks map
   * @param oppsToUpdate opps to update
   * @return List<ApplicationFormProduct> afp records
   */
  private static List<ApplicationFormProduct> getAFPsWithTasks(
    List<ApplicationFormProduct> appFormProducts,
    Set<Id> oppIdsWithTasks,
    Map<Id, Opportunity> oppsToUpdate
  ) {
    List<ApplicationFormProduct> afpWithTasks = new List<ApplicationFormProduct>();
    for (ApplicationFormProduct afp : appFormProducts) {
      if (
        oppIdsWithTasks.contains(afp.ApplicationForm.OpportunityId) &&
        oppsToUpdate.containsKey(afp.ApplicationForm.OpportunityId) &&
        oppsToUpdate.get(afp.ApplicationForm.OpportunityId).StageName == OPP_WON
      ) {
        afpWithTasks.add(afp);
      }
    }
    return afpWithTasks;
  }
}
