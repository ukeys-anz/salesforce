/**
 * @description view model for statement of position
 * @author @fangl6
 * @since 12/08/2024
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class SOPGetConsolidatedViewModel {
  public static final List<String> SAVING_TYPES = new List<String>{
    'ASSET_TYPE_CASH',
    'ASSET_TYPE_BANK_ACCOUNT'
  };

  public static final List<String> ASSET_TYPES = new List<String>{
    'ASSET_TYPE_SUPER',
    'ASSET_TYPE_VEHICLE',
    'ASSET_TYPE_OTHER',
    'ASSET_TYPE_HOME_CONTENTS',
    'ASSET_TYPE_SHARES'
  };

  public static final Set<String> CLOSED_UNSPECIFIED = new Set<String>{
    'ACCOUNT_STATUS_CLOSED',
    'ACCOUNT_STATUS_UNSPECIFIED'
  };

  @AuraEnabled
  public Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup = new Map<String, SOPGetConsolidatedModel.Assets>();
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
  public Map<String, SOPGetConsolidatedModel.Property> partyPropertyLookup = new Map<String, SOPGetConsolidatedModel.Property>();

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
    List<SOPGetConsolidatedModel.Assets> savingsList = new List<SOPGetConsolidatedModel.Assets>();
    List<SOPGetConsolidatedModel.Assets> assetsList = new List<SOPGetConsolidatedModel.Assets>();

    categoriseAssets(
      apiModel,
      savingsList,
      assetsList,
      this.assetPropertyLookup
    );

    setPartyCurrentAddress(apiModel, this.partyPropertyLookup);

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

    this.sopSummaryViewModel = new SOPSummaryViewModel(
      apiModel.sop,
      partyIdToFirstNameMap,
      getSummariesTotalAmount(apiModel)
    );

    this.incomesSummaryViewModel = new SOPIncomesSummaryViewModel(
      apiModel.incomesSummary,
      partyIdToFirstNameMap,
      apiModel.sop.name,
      this.assetPropertyLookup
    );

    this.expenseSummaryViewModel = new SOPExpenseSummaryViewModel(
      apiModel.monthlyExpensesSummary,
      apiModel.sop.expenseConfigVersion,
      this.assetPropertyLookup,
      this.partyPropertyLookup
    );

    this.debtsSummaryViewModel = new SOPDebtsSummaryViewModel(
      apiModel.liabilitiesSummary,
      partyIdToFirstNameMap,
      loanId,
      this.assetPropertyLookup
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

  /**
   * @description Categorises party from the given API model into to get the related property address.
   * @param apiModel The API model containing the assets to be categorized.
   * @param partyPropertyLookup The map to store party's property by their address.
   */
  private void setPartyCurrentAddress(
    SOPGetConsolidatedModel apiModel,
    Map<String, SOPGetConsolidatedModel.Property> partyPropertyLookup
  ) {
    for (SOPGetConsolidatedModel.Parties partyProperty : apiModel.sop.parties) {
      if (String.isBlank(partyProperty.currentResidence?.propertyId)) {
        continue;
      }
      partyPropertyLookup.put(
        partyProperty.currentResidence.propertyId,
        partyProperty.currentResidence
      );
    }
  }

  /**
   * @description Categorises assets from the given API model into savings, assets, and properties.
   * @param apiModel The API model containing the assets to be categorized.
   * @param savingsList The list to store categorized savings assets.
   * @param assetsList The list to store categorized general assets.
   * @param assetPropertyLookup The map to store property assets by their address.
   *
   */
  private void categoriseAssets(
    SOPGetConsolidatedModel apiModel,
    List<SOPGetConsolidatedModel.Assets> savingsList,
    List<SOPGetConsolidatedModel.Assets> assetsList,
    Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup
  ) {
    for (SOPGetConsolidatedModel.Assets asset : apiModel.assetsSummary.assets) {
      if (
        SOPGetConsolidatedViewModel.CLOSED_UNSPECIFIED.contains(
          asset.account?.status
        )
      ) {
        continue;
      }

      if (SAVING_TYPES.contains(asset.type)) {
        savingsList.add(asset);
      }

      if (ASSET_TYPES.contains(asset.type)) {
        assetsList.add(asset);
      }

      if (asset.type == 'ASSET_TYPE_PROPERTY') {
        assetsList.add(asset);
        assetPropertyLookup.put(asset.name, asset);

        if (String.isNotBlank(asset.propertyId)) {
          assetPropertyLookup.put(asset.propertyId, asset);
        }
      }
    }
  }
}
