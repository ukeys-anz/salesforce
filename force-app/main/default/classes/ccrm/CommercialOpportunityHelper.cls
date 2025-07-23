/**
 * @author Ayushi Gupta
 * @since  01/2024
 * @group CCRM (Commercial CRM)
 * @description CommercialOpportunityHelper is class to handle all the operations on opp stage changes
 */
public with sharing class CommercialOpportunityHelper {
  @testVisible
  private static final String LOST_REASON_DETAIL_MISSING_AFP = 'please provide valid Lost Reason/Lost Reason Detail.';
  @testVisible
  private static final String WON_LOST_MANDATORY_AFP = 'please provide valid Won From/Lost To.';
  @testVisible
  private static final String LAUNCH_APP_ERROR = 'Please LAUNCH APPLICATION and mark the Application form product as WON or LOST before closing the opportunity. Please select Internal Application if none of the Origination systems are involved.';
  @testVisible
  private static final String CLOSE_AFP_FIRST_ERROR = 'Please mark all application form products as WON or LOST before closing the opportunity.';
  private static final String OPP_WON = 'Opportunity Won';
  private static final String OPP_LOST = 'Opportunity Lost';
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
      List<String> errors = new List<String>();

      //check if stage is not equal to "New" on creation of lead
      if (isInsert && oppIterator.StageName != CCRMConstants.NEW_STAGE) {
        errors.add(CCRMConstants.OPP_DEFAULT_STAGE_ERROR);
      }
      //check if other source detail is provided if leadsource is other
      if (
        oppIterator.LeadSource == CCRMConstants.OTHER &&
        String.isBlank(oppIterator.Other_Source_Detail__c)
      ) {
        errors.add(CCRMConstants.OTHER_SOURCE_DETAIL_MANDATORY);
      }

      String errorMessage = String.join(errors, '\n');

      //add error message
      if (String.isNotBlank(errorMessage)) {
        oppIterator.addError(errorMessage);
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
      String oldStage = oldOppMap.get(oppIterator.Id).StageName;

      Commercial_Stage__mdt metadata = opportunityStagesBySegment.get(
        oppsStageSegmentMap.get(oppIterator.Id)
      );

      if (metadata != null && metadata.Next_Stage__c != null) {
        nextStage = metadata.Next_Stage__c.split(';');
      }

      if (
        oldStage == metadata.Current_Stage__c &&
        oppIterator.StageName != metadata.Previous_Stage__c &&
        !nextStage.contains(oppIterator.StageName)
      ) {
        oppIterator.addError(CCRMConstants.SKIP_STAGE);
      }

      if (
        oldStage == CCRMConstants.OPP_LOST ||
        oldStage == CCRMConstants.OPP_WON
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
   * @description add error on opportunity when missing fields on AFP.
   * @name addErrorOnOppForMissingFieldsOnClosedAFP
   * @param appFormProducts list of app form products
   * @param closedOppsMap map of closed won/lost opps
   */
  public static void addErrorOnOppForMissingFieldsOnClosedAFP(
    List<ApplicationFormProduct> appFormProducts,
    Map<Id, Opportunity> closedOppsMap
  ) {
    for (ApplicationFormProduct afp : appFormProducts) {
      List<String> errors = new List<String>();

      //check if Lost reason and Lost reason details are provided if AFP is lost
      if (
        afp.Stage == CCRMConstants.OPP_LOST &&
        (String.isBlank(afp.Lost_Reason__c) ||
        String.isBlank(afp.Lost_Reason_Detail__c))
      ) {
        errors.add('For ' + afp.Name + ', ' + LOST_REASON_DETAIL_MISSING_AFP);
      }

      //check if Won from lost is provided for Won/Lost AFP
      if (String.isBlank(afp.Won_from_Lost_to__c)) {
        errors.add('For ' + afp.Name + ', ' + WON_LOST_MANDATORY_AFP);
      }

      if (errors.isEmpty()) {
        continue;
      }

      //add error message
      String error = String.join(errors, '\n');
      closedOppsMap.get(afp.ApplicationForm.OpportunityId).addError(error);
    }
  }

  /**
   * @description add error on opportunity when AFP/Product are not closed
   * @name addErrorOnOppForOpenAFP
   * @param closedOppsMap map of closed won/lost opps
   * @param oppIdToOpenAFPMap map of oppID to open AFP Ids
   * @param oppIdToAllAFPIdMap map of oppID to all AFP Ids
   */
  public static void addErrorOnOppForOpenAFP(
    Map<Id, Opportunity> closedOppsMap,
    Map<Id, Set<Id>> oppIdToOpenAFPMap,
    Map<Id, Set<Id>> oppIdToAllAFPIdMap
  ) {
    //get Opp products related to Opportunities
    List<OpportunityLineItem> oppProducts = COMMERCIALOPP_REPOSITORY.getOppProductsForOpportunity(
      closedOppsMap.keySet()
    );
    //create OppId -> Opp Product map
    Map<Id, List<OpportunityLineItem>> oppIdToOppProductMap = (Map<Id, List<OpportunityLineItem>>) ListUtil.groupBy(
      oppProducts,
      OpportunityLineItem.OpportunityId
    );

    for (Opportunity oppRecord : closedOppsMap.values()) {
      Integer afpRelatedToOppSize = oppIdToAllAFPIdMap.get(oppRecord.Id)
        ?.size();
      Integer oliRelatedToOppSize = oppIdToOppProductMap.get(oppRecord.Id)
        ?.size();
      if (afpRelatedToOppSize != oliRelatedToOppSize) {
        oppRecord.addError(LAUNCH_APP_ERROR);
        continue;
      }
      Integer openAfpRelatedToOppSize = oppIdToOpenAFPMap.get(oppRecord.Id)
        ?.size();
      if (openAfpRelatedToOppSize > 0) {
        oppRecord.addError(CLOSE_AFP_FIRST_ERROR);
      }
    }
  }

  /**
   * @description This method returns map of opportunity ID To only existing open AFP ID
   * @name formOppIdToOpenAFPMap
   * @param appFormProductList list of AFPs
   * @return Map<Id,Set<Id>> map of opportunity ID To all existing AFP ID
   */
  public static Map<Id, Set<Id>> formOppIdToOpenAFPMap(
    List<ApplicationFormProduct> appFormProductList
  ) {
    Map<Id, Set<Id>> oppIdToOpenAFPMap = new Map<Id, Set<Id>>();
    List<ApplicationFormProduct> openAFPList = ListUtil.filter(
        appFormProductList
      )
      .notEquals(ApplicationFormProduct.Stage, OPP_LOST)
      .notEquals(ApplicationFormProduct.Stage, OPP_WON)
      .toList();

    for (ApplicationFormProduct afpRecord : openAFPList) {
      Id oppId = afpRecord.ApplicationForm.OpportunityId;
      if (!oppIdToOpenAFPMap.containsKey(oppId)) {
        oppIdToOpenAFPMap.put(oppId, new Set<Id>());
      }
      oppIdToOpenAFPMap.get(oppId).add(afpRecord.Id);
    }
    return oppIdToOpenAFPMap;
  }

  /**
   * @description This method returns map of opportunity ID To all existing AFP ID
   * @name formOppIdToAllAFPIdMap
   * @param appFormProducts list of AFPs
   * @return Map<Id,Set<Id>> map of opportunity ID To all existing AFP ID
   */
  public static Map<Id, Set<Id>> formOppIdToAllAFPIdMap(
    List<ApplicationFormProduct> appFormProducts
  ) {
    Map<Id, Set<Id>> oppIdToAllAFPIdMap = new Map<Id, Set<Id>>();
    for (ApplicationFormProduct afpRecord : appFormProducts) {
      Id oppId = afpRecord.ApplicationForm.OpportunityId;
      if (!oppIdToAllAFPIdMap.containsKey(oppId)) {
        oppIdToAllAFPIdMap.put(oppId, new Set<Id>());
      }
      oppIdToAllAFPIdMap.get(oppId).add(afpRecord.ProductId);
    }
    return oppIdToAllAFPIdMap;
  }
}
