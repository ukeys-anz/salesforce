/**
 * @author Peter Charalambous
 * @since Wed Nov 01 2023
 * @description class for settlement actions
 */
public with sharing class SettlementActions {
  private static final String SETTLEMENTS_QUEUE = 'Settlements_Queue';
  private static final String QUEUE_TYPE = 'Queue';
  private static Group settlementsQueue;
  public static final String EXTERNAL_SETTLEMENT_PLAN = 'External Settlement Action Plan';
  public static final String INTERNAL_SETTLEMENT_PLAN = 'Internal Settlement Action Plan';
  private static final ResidentialLoanApplicationRepository RESIDENTIAL_LOAN_APP_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPO = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );

  @TestVisible
  private static Map<String, ActionPlanTemplateVersion> actionPlansMap {
    get {
      if (actionPlansMap != null) {
        return actionPlansMap;
      }

      actionPlansMap = new Map<String, ActionPlanTemplateVersion>();
      List<ActionPlanTemplateVersion> actionPlanTemplateVersionList = SETTLEMENT_REPO.queryActionPlanTemplateVersion();
      for (ActionPlanTemplateVersion ap : actionPlanTemplateVersionList) {
        actionPlansMap.put(ap.Name, ap);
      }
      return actionPlansMap;
    }
    set;
  }

  /**
   * @description get settlements queue
   * @return Group settlements queue
   */
  public static Group getSettlementQueue() {
    if (settlementsQueue != null) {
      return settlementsQueue;
    }

    settlementsQueue = [
      SELECT Id
      FROM Group
      WHERE developername = :SETTLEMENTS_QUEUE AND Type = :QUEUE_TYPE
    ];
    return settlementsQueue;
  }

  /**
   * @description Assign Settlements Queue as owner
   * @param settlementRecords records to assign owner
   */
  public static void assignSettlementQueue(
    List<Settlement__c> settlementRecords
  ) {
    for (Settlement__c settlement : settlementRecords) {
      settlement.OwnerId = getSettlementQueue().Id;
    }
  }

  /**
   * @description Populate the requested loan amount value
   * @param records records to populate
   */
  public static void populateRequestedAmount(List<Settlement__c> records) {
    List<String> loanAppIds = new List<String>();
    for (Settlement__c settlement : records) {
      if (settlement.Loan_Application_Number__c != null) {
        //Populate loan app ids to query for application financial details
        loanAppIds.add(settlement.Loan_Application_Number__c);
      }
    }

    List<LoanApplicationFinancial> loanAppFinancialList = [
      SELECT LoanApplicationId, LoanExclFinMortInsAmt
      FROM LoanApplicationFinancial
      WHERE LoanApplicationId IN :loanAppIds
    ];

    Map<String, LoanApplicationFinancial> loanAppFinMap = new Map<String, LoanApplicationFinancial>();
    for (LoanApplicationFinancial loanAppFinancial : loanAppFinancialList) {
      loanAppFinMap.put(loanAppFinancial.LoanApplicationId, loanAppFinancial);
    }

    for (Settlement__c settlement : records) {
      //Assign the requested loan amount from the loan app financial
      settlement.Requested_Loan_Amount__c = loanAppFinMap.get(
          settlement.Loan_Application_Number__c
        )
        .LoanExclFinMortInsAmt;
    }
  }

  /**
   * @description Create action plans for settlement
   * @param records records to populate
   * @param oldMap Map of old records used in update context
   */
  public static void createActionPlans(
    List<Settlement__c> records,
    Map<Id, SObject> oldMap
  ) {
    List<Settlement__c> filteredSettlements = new List<Settlement__c>();
    // oldMap only provided in update context
    if (oldMap != null) {
      //only proceed if settlement type has changed
      for (Settlement__c settlement : records) {
        if (
          RecordComparisonUtil.fieldWasChanged(
            settlement,
            oldMap.get(settlement.Id),
            Settlement__c.Type__c
          )
        ) {
          filteredSettlements.add(settlement);
        }
      }
    } else {
      filteredSettlements = records;
    }
    List<ActionPlan> actionPlanList = createActionPlansRecords(
      filteredSettlements
    );

    if (actionPlanList.isEmpty()) {
      return;
    }

    SystemModeActions systemAction = new SystemModeActions(
      'SettlementActions',
      'createActionPlans'
    );
    systemAction.insertRecords(actionPlanList, 'ActionPlan');
  }

  /**
   * @description Create action plans
   * @param settlementRecords settlement records to create action plans for
   * @return List<ActionPlan>
   */
  @TestVisible
  private static List<ActionPlan> createActionPlansRecords(
    List<Settlement__c> settlementRecords
  ) {
    List<Settlement__c> filteredSettlements = filterSettlementExistingActionPlan(
      settlementRecords
    );

    //TYPE_REFINANCE_INTERNAL = Internal | TYPE_REFINANCE_OFI = External
    Map<String, String> settlementNameMap = new Map<String, String>{
      'TYPE_REFINANCE_INTERNAL' => 'Internal Plan',
      'TYPE_REFINANCE_OFI' => 'External Plan'
    };
    Map<String, String> actionPlanTemplateMap = new Map<String, String>{
      'TYPE_REFINANCE_INTERNAL' => INTERNAL_SETTLEMENT_PLAN,
      'TYPE_REFINANCE_OFI' => EXTERNAL_SETTLEMENT_PLAN
    };

    List<ActionPlan> actionPlanList = new List<ActionPlan>();

    for (Settlement__c settlement : filteredSettlements) {
      if (settlement.Type__c == 'TYPE_UNSPECIFIED') {
        continue;
      }
      //Create action plan for record
      ActionPlan ap = new ActionPlan();
      ap.StartDate = System.today();
      ap.TargetId = settlement.Id;
      ap.ActionPlanState = 'In Progress';
      ap.ActionPlanType = 'Industries';
      ap.IsUsingHolidayHours = true;
      ap.Name = settlementNameMap.get(settlement.Type__c);
      ap.ActionPlanTemplateVersionId = actionPlansMap.get(
          actionPlanTemplateMap.get(settlement.Type__c)
        )
        .Id;

      actionPlanList.add(ap);
    }

    return actionPlanList;
  }

  /**
   * @description Filter settlements and remove any that have existing action plans
   * @param records settlement records to filter
   * @return List<Settlement__c>
   */
  private static List<Settlement__c> filterSettlementExistingActionPlan(
    List<Settlement__c> records
  ) {
    List<Id> settlementIds = new List<Id>();
    List<Settlement__c> settlementList = new List<Settlement__c>();
    for (Settlement__c settlement : records) {
      settlementIds.add(settlement.Id);
    }

    if (settlementIds.isEmpty()) {
      return records;
    }

    List<ActionPlan> actionPlanList = [
      SELECT Id, TargetId
      FROM ActionPlan
      WHERE TargetId IN :settlementIds
    ];
    //If no action plans, no need to filter any records
    if (actionPlanList.isEmpty()) {
      return records;
    }

    Map<Id, ActionPlan> actionPlanMap = new Map<Id, ActionPlan>();
    for (ActionPlan ap : actionPlanList) {
      actionPlanMap.put(ap.TargetId, ap);
    }

    //Loop through records and filter out settlements with existing action plans
    for (Settlement__c settlement : records) {
      if (actionPlanMap.get(settlement.Id) == null) {
        settlementList.add(settlement);
      }
    }

    return settlementList;
  }
  /**
   * @description  filter the loanappIds from settlement
   * @param records settlement  records for filtering
   *  @return List<loanapplicationIds>
   */
  @Testvisible
  private static List<Id> getLoanApplicationIdFromSettlements(
    List<Settlement__c> records
  ) {
    List<Id> loanApplicationIds = new List<Id>();
    for (Settlement__c settleRec : records) {
      if (settleRec.IsValidCloudEvent__c == true) {
        loanApplicationIds.add(settleRec.Loan_Application_Number__c);
      }
    }
    return loanApplicationIds;
  }
  /**
   * @description on settlement update/insert publish application event to migrate data to broker org.
   * @param records records to publish the application event
   * @param cloudEventType  add or update event
   */
  public static void publishSettlementCloudEvents(
    List<Settlement__c> records,
    String cloudEventType
  ) {
    List<Id> loanApplicationIds = getLoanApplicationIdFromSettlements(records);
    List<ResidentialLoanApplication> rlaList = RESIDENTIAL_LOAN_APP_REPOSITORY.queryLoanApplicatioins(
      loanApplicationIds
    );
    ResidentialLoanApplicationActions.publishSyncEvents(
      rlaList,
      cloudEventType
    );
  }
}
