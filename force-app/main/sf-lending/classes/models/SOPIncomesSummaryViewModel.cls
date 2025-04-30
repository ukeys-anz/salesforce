/**
 * @description view model for SOPIncomesSummary
 * @author @fangl6
 * @since 18/08/2024
 */
public with sharing class SOPIncomesSummaryViewModel {
  @AuraEnabled
  public List<SOPIncomeViewModel> incomes;
  @AuraEnabled
  public String currencyCode;
  @AuraEnabled
  public Decimal totalAmount;
  @AuraEnabled
  public Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup;
  @AuraEnabled
  public Map<String, String> propertyOwnerShipMap = new Map<String, String>();

  /**
   * @description constructor for SOPIncomesSummaryViewModel
   * @param sourceData source data
   * @param partyIdToFirstNameMap party id to first name map
   * @param sopId the sop component name
   * @param assetPropertyLookup map of address lookup
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public SOPIncomesSummaryViewModel(
    SOPGetConsolidatedModel.IncomesSummary sourceData,
    Map<String, String> partyIdToFirstNameMap,
    String sopId,
    Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup
  ) {
    this.incomes = new List<SOPIncomeViewModel>();
    this.currencyCode = sourceData?.incomesTotalAmount?.currencyCode ?? 'AUD';
    this.totalAmount = SOPHelper.convertAmountToDecimal(
      sourceData.incomesTotalAmount
    );

    this.assetPropertyLookup = assetPropertyLookup;
    for (SOPGetConsolidatedModel.Assets asset : assetPropertyLookup.values()) {
      Map<String, String> ownershipMap = SOPHelper.buildOwnershipStrings(
        asset.ownership,
        partyIdToFirstNameMap
      );
      String ownerName = ownershipMap.get('belongs-to');
      this.propertyOwnerShipMap.put(asset.name, ownerName);
    }
    for (SOPGetConsolidatedModel.Incomes income : sourceData.incomes) {
      this.incomes.add(
        new SOPIncomeViewModel(
          income,
          partyIdToFirstNameMap,
          sopId,
          assetPropertyLookup
        )
      );
    }
  }
}
