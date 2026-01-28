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
  public static final String ACCOUNT_ID_FIELD_NAME = 'AccountId';
  public static final String LEAD_PROCESS_FOR_PROSPECT_ERROR = 'Error Message - Lead process to be followed for prospect opportunity creation';
  @testVisible
  private static final String LAUNCH_APP_ERROR = 'Please LAUNCH APPLICATION and mark the Application form product as WON or LOST before closing the opportunity. Please select Internal Application if none of the Origination systems are involved.';
  @testVisible
  private static final String CLOSE_AFP_FIRST_ERROR = 'Please mark all application form products as WON or LOST before closing the opportunity.';
  private static final String OPP_WON = 'Opportunity Won';
  private static final String OPP_LOST = 'Opportunity Lost';
  private static final String OPP_CANCELLED = 'Cancelled';
  private static final String OPPORTUNITY_LABEL = 'Opportunity';
  private static final String SKIP_STAGE = 'Unfortunately, you are not allowed to skip stages or re-open a closed stage.';
  private static final String REOPEN_CLOSED_OPP = 'You cannot reopen a closed stage.';
  private static final String COMMERCIAL_ADMIN_ROLE = 'Commercial_Admin';
  @testVisible
  private static final String SELECT_RELATED_CLG_ERROR = 'Customer is not related to this CLG, please select the correct CLG';
  @testVisible
  private static final String SELECT_ANY_CLG_ERROR = 'Please select a related CLG';
  @testVisible
  private static final String NO_CLG_FOR_CUSTOMER_ERROR = 'No CLG available for this customer,please leave CLG blank';

  @testVisible
  private static final Set<String> SET_CLOSED_STAGES = new Set<String>{
    OPP_WON,
    OPP_LOST,
    OPP_CANCELLED
  };

  private static final CommercialOpportunityRepository OPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  /**
   * @description This method will Loop through Accounts mapped with Opportunity and determine if Account is a Prospect
   * @name checkAccountIsProspect
   * @param accounts List of Accounts used by Opportunities
   * @param records List of Opportunities in transaction
   */
  public static void checkAccountIsProspect(
    Map<Id, Account> accounts,
    List<Opportunity> records
  ) {
    List<Opportunity> prospectOppRecords = ListUtil.filter(records)
      .equals(Opportunity.AccountId, accounts.keySet())
      .equals(Opportunity.Lead_Converted__c, false)
      .toList();
    ListUtil.addError(prospectOppRecords, LEAD_PROCESS_FOR_PROSPECT_ERROR);
  }

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
          metadata.Object_Name__c.split(';').contains(OPPORTUNITY_LABEL)
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
    if (USER_REPO.checkRole(COMMERCIAL_ADMIN_ROLE)) {
      return;
    }
    for (Opportunity oppIterator : stageUpdatedOpps) {
      List<String> nextStage = new List<String>();
      String oldStage = oldOppMap.get(oppIterator.Id).StageName;

      if (SET_CLOSED_STAGES.contains(oldStage)) {
        oppIterator.addError(REOPEN_CLOSED_OPP);
        return;
      }

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
        oppIterator.addError(SKIP_STAGE);
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
    List<Map<String, Object>> openTasks = OPP_REPOSITORY.getOpenTasksOnClosedOpportunity(
      closingOppoIdMap.keySet()
    );
    for (Map<String, Object> iterator : openTasks) {
      closingOppoIdMap.get(String.valueOf(iterator.get('WhatId')))
        .addError(System.Label.CCRM_OpenTasksOnOpportunityCloseError);
    }
  }

  /**
   * @description updates opportunity list on insert
   * @name updateOpportunityListOnInsert
   * @param filteredOpps list of opportunity
   * @param updatedOppsNameMap map of oppId to updated opp name
   */
  @testVisible
  public static void updateOpportunityListOnInsert(
    List<Opportunity> filteredOpps,
    Map<Id, String> updatedOppsNameMap
  ) {
    List<Opportunity> updatedOpps = new List<Opportunity>();
    for (Opportunity opps : filteredOpps) {
      Opportunity opp = new Opportunity(Id = opps.Id);
      opp.Name = updatedOppsNameMap.containsKey(opps.Id)
        ? updatedOppsNameMap.get(opps.Id)
        : '';
      updatedOpps.add(opp);
    }
    CommercialOpportunityActions.insertOpportunityContext = true;
    DML.doUpdate(updatedOpps);
  }

  /**
   * @description updates opportunity list on update
   * @name updateOpportunityListOnUpdate
   * @param filteredOpps list of opportunity
   * @param updatedOppsNameMap map of oppId to updated opp name
   * @return List<Opportunity> opportunity list
   */
  public static List<Opportunity> updateOpportunityListOnUpdate(
    List<Opportunity> filteredOpps,
    Map<Id, String> updatedOppsNameMap
  ) {
    for (Opportunity opp : filteredOpps) {
      opp.Name = updatedOppsNameMap.containsKey(opp.Id)
        ? updatedOppsNameMap.get(opp.Id)
        : '';
    }
    return filteredOpps;
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
        afp.Stage == OPP_LOST &&
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
    List<OpportunityLineItem> oppProducts = OPP_REPOSITORY.getOppProductsForOpportunity(
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
      oppIdToAllAFPIdMap.get(oppId).add(afpRecord.Opportunity_Product__c);
    }
    return oppIdToAllAFPIdMap;
  }

  /**
   * @description This method give filtered opportunities based on Customer/Name change
   * @name getFilteredOpportunities
   * @param filteredOpps List of Opportunities
   * @param oldMap List of old Opportunities
   * @return List<Opportunity> opportunity list
   */
  public static List<Opportunity> getFilteredOpportunities(
    List<Opportunity> filteredOpps,
    Map<Id, Opportunity> oldMap
  ) {
    Set<SObjectField> oppFieldsSet = new Set<SObjectField>{
      Opportunity.Customer_Needs__c,
      Opportunity.Secondary_Customer_Needs__c,
      Opportunity.Name
    };
    return ListUtil.filter(filteredOpps, oldMap)
      .anyChanged(oppFieldsSet)
      .toList();
  }

  /**
   * @description This method will get CLG account associated to accounts
   * @name getMapOfAccountWithClgAccount
   * @param accountIds Account Ids
   * @return Map<Id,Id> Account Ids with associated CLG Account Ids
   */
  public static Map<Id, Id> getMapOfAccountWithClgAccount(Set<Id> accountIds) {
    Map<Id, Id> mapOfAccountWithClgAccount = new Map<Id, Id>();
    List<FinServ__AccountAccountRelation__c> aarList = OPP_REPOSITORY.getAccountAccountRelationsForCLG(
      accountIds
    );

    for (FinServ__AccountAccountRelation__c relatedaccount : aarList) {
      mapOfAccountWithClgAccount.put(
        relatedaccount.FinServ__Account__c,
        relatedaccount.FinServ__RelatedAccount__c
      );
    }
    return mapOfAccountWithClgAccount;
  }

  /**
   * @description : This is used to populate the CLG Info on Lead
   * @param filteredLeadsList Lead records
   * @param accMap Map of Account
   * @param accIdToClgIdAARMap Map of account Id to related CLG Id map
   */
  @TestVisible
  public static void populateClgCpidInfoOnOpp(
    List<Opportunity> filteredLeadsList,
    Map<Id, Account> accMap,
    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdAARMap
  ) {
    for (Opportunity oppRecord : filteredLeadsList) {
      Account accRec = accMap.get(oppRecord.AccountId);
      Boolean isClgAccount = accRec?.RecordTypeId == RTAccount.clgAccount;
      Boolean isAccountInMap = accIdToClgIdAARMap.containsKey(
        oppRecord.AccountId
      );

      if (isClgAccount) {
        setValueFromAccount(oppRecord, isAccountInMap ? null : accRec);
        continue;
      }
      if (!isAccountInMap) {
        //when customer = org and no related CLG present then nullify CLG fields
        setValueFromAccount(oppRecord, null);
        continue;
      }
      Map<Id, FinServ__AccountAccountRelation__c> clgIdToAARMap = accIdToClgIdAARMap.get(
        oppRecord.AccountId
      );
      if (clgIdToAARMap.size() != 1) {
        setValueFromAccount(oppRecord, null);
        continue;
      }
      FinServ__AccountAccountRelation__c aar = clgIdToAARMap.values()[0];
      setValueFromAccount(oppRecord, aar.FinServ__RelatedAccount__r);
    }
  }

  /**
   * @description : This is used to validate the CLG association on Lead
   * @param filteredOppList Lead records
   * @param accMap Map of Account
   * @param accIdToClgIdsMap Map of account Id to related CLG Id map
   */
  public static void validateAndPopulateCLGInfo(
    List<Opportunity> filteredOppList,
    Map<Id, Account> accMap,
    Map<Id, Set<Id>> accIdToClgIdsMap
  ) {
    for (Opportunity oppRecord : filteredOppList) {
      Set<Id> clgIdsSet = accIdToClgIdsMap.get(oppRecord.AccountId) ??
        new Set<Id>();

      if (oppRecord.CLG__c == null) {
        if (!clgIdsSet.isEmpty()) {
          oppRecord.CLG__c.addError(SELECT_ANY_CLG_ERROR);
        }
        continue;
      }
      if (clgIdsSet.isEmpty()) {
        oppRecord.CLG__c.addError(NO_CLG_FOR_CUSTOMER_ERROR);
        continue;
      }
      if (!clgIdsSet.contains(oppRecord.CLG__c)) {
        oppRecord.CLG__c.addError(SELECT_RELATED_CLG_ERROR);
        continue;
      }
      setValueFromAccount(oppRecord, accMap.get(oppRecord.CLG__c));
    }
  }

  /**
   * @description : This is used to populate the CLG Info on Lead from Account
   * @param oppRecord Lead record
   * @param accRecord Account record
   */
  @TestVisible
  private static void setValueFromAccount(
    Opportunity oppRecord,
    Account accRecord
  ) {
    oppRecord.CLG__c = accRecord?.Id;
    oppRecord.CLG_ID__c = accRecord?.CLG__c;
  }

  /**
   * @description : This is used to generate Opp name
   * @param oppId oppId
   * @param customerNeeds customerNeeds
   * @param oppName oppName
   * @param oldMap oldMap
   * @return String opportunity name
   */
  @testVisible
  public static String generateOpportunityName(
    String oppId,
    String customerNeeds,
    String oppName,
    Map<Id, Opportunity> oldMap
  ) {
    String opportunityName;

    opportunityName = oppId + ' ';
    if (String.isNotBlank(customerNeeds)) {
      opportunityName += customerNeeds + ' ';
    }
    oppName = String.isNotBlank(oppName) ? oppName.left(30) : oppName;
    if (String.isNotBlank(oppName)) {
      opportunityName += oppName;
    }
    return opportunityName;
  }
}
