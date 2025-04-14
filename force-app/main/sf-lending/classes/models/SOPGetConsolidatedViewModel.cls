/**
 * @description view model for statement of position
 * @author @fangl6
 * @since 12/08/2024
 */
public with sharing class SOPGetConsolidatedViewModel {
  public static final List<String> SAVING_TYPES = new List<String>{
    'ASSET_TYPE_CASH',
    'ASSET_TYPE_BANK_ACCOUNT'
  };

  public static final List<String> ASSET_TYPES = new List<String>{
    'ASSET_TYPE_PROPERTY',
    'ASSET_TYPE_SUPER',
    'ASSET_TYPE_VEHICLE',
    'ASSET_TYPE_OTHER',
    'ASSET_TYPE_HOME_CONTENTS',
    'ASSET_TYPE_SHARES'
  };

  @AuraEnabled
  public SOPSummaryViewModel sopSummaryViewModel;
  @AuraEnabled
  public SOPIncomesSummaryViewModel incomesSummaryViewModel;
  @AuraEnabled
  public SOPAssetsSummaryViewModel assetsSummaryViewModel;
  @AuraEnabled
  public SOPSavingsSummaryViewModel savingsSummaryViewModel;
  @AuraEnabled
  public SOPExpenseSummaryViewModel expenseSummaryViewModel;
  @AuraEnabled
  public SOPDebtsSummaryViewModel debtsSummaryViewModel;
  @AuraEnabled
  public SOPCreditBureauSummaryViewModel creditBureauSummaryViewModel;

  /**
   * @description constructor for SOPGetConsolidatedViewModel
   * @param apiModel api model
   * @param partyIdToFirstNameMap party id to first name map
   * @param loanId the RLA id
   */
  public SOPGetConsolidatedViewModel(
    SOPGetConsolidatedModel apiModel,
    Map<String, String> partyIdToFirstNameMap,
    Id loanId
  ) {
    this.sopSummaryViewModel = new SOPSummaryViewModel(
      apiModel.sop,
      partyIdToFirstNameMap,
      getSummariesTotalAmount(apiModel)
    );

    this.incomesSummaryViewModel = new SOPIncomesSummaryViewModel(
      apiModel.incomesSummary,
      partyIdToFirstNameMap,
      apiModel.sop.name
    );

    this.expenseSummaryViewModel = new SOPExpenseSummaryViewModel(
      apiModel.monthlyExpensesSummary,
      apiModel.sop.expenseConfigVersion
    );

    this.debtsSummaryViewModel = new SOPDebtsSummaryViewModel(
      apiModel.liabilitiesSummary,
      partyIdToFirstNameMap,
      loanId
    );

    List<SOPGetConsolidatedModel.Assets> savingsList = new List<SOPGetConsolidatedModel.Assets>();
    List<SOPGetConsolidatedModel.Assets> assetsList = new List<SOPGetConsolidatedModel.Assets>();
    for (SOPGetConsolidatedModel.Assets asset : apiModel.assetsSummary.assets) {
      Boolean isClosedAndUnspecified =
        asset.account?.status == 'ACCOUNT_STATE_CLOSED';

      if (isClosedAndUnspecified) {
        continue;
      }

      if (SAVING_TYPES.contains(asset.type)) {
        savingsList.add(asset);
      } else if (ASSET_TYPES.contains(asset.type)) {
        assetsList.add(asset);
      }
    }

    this.assetsSummaryViewModel = new SOPAssetsSummaryViewModel(
      assetsList,
      SOPHelper.convertAmountToDecimal(
        apiModel.assetsSummary.assetsTotalAmount
      ),
      partyIdToFirstNameMap,
      loanId
    );

    this.savingsSummaryViewModel = new SOPSavingsSummaryViewModel(
      savingsList,
      SOPHelper.convertAmountToDecimal(
        apiModel.assetsSummary.savingsTotalAmount
      ),
      partyIdToFirstNameMap
    );

    this.creditBureauSummaryViewModel = new SOPCreditBureauSummaryViewModel(
      apiModel.liabilitiesSummary.sources,
      partyIdToFirstNameMap
    );
  }

  /**
   * @description return the amount summaries
   * @param apiModel SOP getconlidated gapiapi model
   * @return  `Map<String, Decimal>` A map where the key is a string and the value is a decimal representing the total amount summaries.
   */
  public Map<String, Decimal> getSummariesTotalAmount(
    SOPGetConsolidatedModel apiModel
  ) {
    return new Map<String, Decimal>{
      'COMPONENT_TYPE_INCOMES' => SOPHelper.convertAmountToDecimal(
        apiModel.incomesSummary.incomesTotalAmount
      ),
      'COMPONENT_TYPE_EXPENSES' => SOPHelper.convertAmountToDecimal(
        apiModel.monthlyExpensesSummary.expensesTotalAmount
      ),
      'COMPONENT_TYPE_ASSETS' => SOPHelper.convertAmountToDecimal(
        apiModel.assetsSummary.assetsTotalAmount
      ),
      'COMPONENT_TYPE_SAVINGS' => SOPHelper.convertAmountToDecimal(
        apiModel.assetsSummary.savingsTotalAmount
      ),
      'COMPONENT_TYPE_LIABILITIES' => SOPHelper.convertAmountToDecimal(
          apiModel.liabilitiesSummary.liabilitiesTotalAmount
        ) > 0
        ? -SOPHelper.convertAmountToDecimal(
            apiModel.liabilitiesSummary.liabilitiesTotalAmount
          )
        : SOPHelper.convertAmountToDecimal(
            apiModel.liabilitiesSummary.liabilitiesTotalAmount
          )
    };
  }
}
