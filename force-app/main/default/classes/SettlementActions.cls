/**
 * @author Peter Charalambous
 * @since Wed Nov 01 2023
 * @description class for settlement actions
 */
public with sharing class SettlementActions {
  private static final String SETTLEMENTS_QUEUE = 'Settlements_Queue';
  private static final String QUEUE_TYPE = 'Queue';
  private static Group settlementsQueue;
  private static final String EXTERNAL_SETTLEMENT_PLAN = 'External Settlement Action Plan';
  private static final String INTERNAL_SETTLEMENT_PLAN = 'Internal Settlement Action Plan';

  @TestVisible
  private static List<ActionPlanTemplateVersion> actionPlanTemplateVersionList {
    get {
      if (actionPlanTemplateVersionList != null) {
        return actionPlanTemplateVersionList;
      }
      actionPlanTemplateVersionList = [
        SELECT Id, Name
        FROM ActionPlanTemplateVersion
        WHERE
          Name IN (:EXTERNAL_SETTLEMENT_PLAN, :INTERNAL_SETTLEMENT_PLAN)
          AND Status = 'Final'
      ];
      return actionPlanTemplateVersionList;
    }
    set;
  }

  @TestVisible
  private static Map<String, ActionPlanTemplateVersion> actionPlansMap {
    get {
      if (actionPlansMap != null) {
        return actionPlansMap;
      }

      actionPlansMap = new Map<String, ActionPlanTemplateVersion>();
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
   */
  public static void createActionPlans(List<Settlement__c> records) {
    List<ActionPlan> actionPlanList = createActionPlansRecords(records);
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
    for (Settlement__c settlement : settlementRecords) {
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
}
