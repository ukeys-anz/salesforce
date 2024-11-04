/**
 * @author Ayushi Gupta
 * @since  01/2024
 * @group CCRM (Commercial CRM)
 * @description CommercialOpportunityHelper is class to handle all the operations on opp stage changes
 */
public with sharing class CommercialOpportunityHelper {
  private static final CommercialOpportunityRepository COMMERCIALOPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Returns the AFP stages metadata
   */
  static Map<String, Commercial_Stage__mdt> opportunityStagesBySegment {
    get {
      if (opportunityStagesBySegment != null) {
        return opportunityStagesBySegment;
      }
      opportunityStagesBySegment = new Map<String, Commercial_Stage__mdt>();
      for (
        Commercial_Stage__mdt metadata : Commercial_Stage__mdt.getAll().values()
      ) {
        if (
          metadata.Object_Name__c == null ||
          metadata.Object_Name__c.split(';').contains(CCRMConstants.OPPORTUNITY)
        ) {
          String key =
            metadata.Current_Stage__c +
            '-' +
            metadata.Commercial_Segment__c;
          opportunityStagesBySegment.put(key, metadata);
        }
      }
      return opportunityStagesBySegment;
    }
    set;
  }

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
    for (Opportunity oppIterator : oppWrapper.filteredOpps) {
      String errorMessage = '';

      //check if stage is not equal to "New" on creation of lead
      if (isInsert && oppIterator.StageName != CCRMConstants.NEW_STAGE) {
        errorMessage +=
          CCRMConstants.OPP_DEFAULT_STAGE_ERROR + CCRMConstants.NEW_LINE_CHAR;
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
   * @param oppsStageSegmentMap opps stage segment map
   */
  public static void addErrorForSkippedStage(
    List<Opportunity> stageUpdatedOpps,
    Map<Id, Opportunity> oldOppMap,
    Map<Id, String> oppsStageSegmentMap
  ) {
    for (Opportunity oppIterator : stageUpdatedOpps) {
      List<String> nextStage = new List<String>();

      Commercial_Stage__mdt metadata = opportunityStagesBySegment.get(
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
        oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.OPP_LOST ||
        oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.OPP_WON
      ) {
        oppIterator.addError(CCRMConstants.REOPEN_CLOSED_OPP);
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
    List<Map<String, Object>> openTasks = COMMERCIALOPP_REPOSITORY.getOpenTasksOnClosedOpportunity(
      closingOppoIdMap.keySet()
    );
    for (Map<String, Object> iterator : openTasks) {
      closingOppoIdMap.get(String.valueOf(iterator.get('WhatId')))
        .addError(System.Label.CCRM_OpenTasksOnOpportunityCloseError);
    }
  }

  /**
   * @description processUpdate the given records based on the provided configuration
   * @param records The list of records to be processed.
   **/
  public static void processUpdate(List<Opportunity> records) {
    DML.doUpdate(records);
  }
}
