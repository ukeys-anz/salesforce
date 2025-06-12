/**
 * @author cruzb
 * @since Oct 2024
 * @description SOP Expense Summary View model
 */
public with sharing class SOPExpenseSummaryViewModel {
  private static final ResidentialLoanApplicationRepository RLA_SOQL_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  @AuraEnabled
  public String sop;

  @AuraEnabled
  public Decimal totalSpending;

  @AuraEnabled
  public Boolean isLegacyExpenseConfigVersion;

  @AuraEnabled
  public List<SOPExpenseViewModel> monthlyExpenses;

  /**
   * @description constructor to map from sop expense api model to expenseSummary view model
   * @param sourceData expenseSummary api model
   * @param expenseConfigVersion version of expense config from sourceData sop
   * @param assetPropertyLookup map of address lookup
   * @param partyPropertyLookup map of address lookup
   */
  public SOPExpenseSummaryViewModel(
    SOPGetConsolidatedModel.MonthlyExpensesSummary sourceData,
    String expenseConfigVersion,
    Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup,
    Map<String, SOPGetConsolidatedModel.Property> partyPropertyLookup
  ) {
    this.sop = sourceData.sop;
    this.isLegacyExpenseConfigVersion = new Set<String>(
        System.Label.SOP_Expense_Config.split(',')
      )
      .contains(expenseConfigVersion);
    this.totalSpending = SOPHelper.convertAmountToDecimal(
      sourceData.expensesTotalAmount
    );
    //injected to SOPExpenseViewModel for reason mapping instead of mapping in the below loop for sepration of concern
    Map<String, Expense_Control__c> mapCodeToReason = initialiseMapCodeToReason(
      sourceData.monthlyExpenses
    );

    this.monthlyExpenses = new List<SOPExpenseViewModel>();
    for (
      SOPGetConsolidatedModel.MonthlyExpenses expense : sourceData.monthlyExpenses
    ) {
      this.monthlyExpenses.add(
        new SOPExpenseViewModel(
          expense,
          mapCodeToReason,
          assetPropertyLookup,
          partyPropertyLookup
        )
      );
    }
  }

  /**
   * @description builds a map for justification code to reason
   * @param monthlyExpenses from sourceData
   * @return Map<String, Expense_Control__c>
   */
  public static Map<String, Expense_Control__c> initialiseMapCodeToReason(
    List<SOPGetConsolidatedModel.MonthlyExpenses> monthlyExpenses
  ) {
    //initialise set of justificationCodes taken from an expense item to build mapCodeToReason
    Set<String> justificationCodeSet = new Set<String>();
    for (SOPGetConsolidatedModel.MonthlyExpenses expense : monthlyExpenses) {
      justificationCodeSet.add(expense.justificationCode);
    }
    return (Map<String, Expense_Control__c>) ListUtil.mapBy(
      RLA_SOQL_REPOSITORY.getExpenseControl(justificationCodeSet),
      Expense_Control__c.Justification_Code__c
    );
  }
}
