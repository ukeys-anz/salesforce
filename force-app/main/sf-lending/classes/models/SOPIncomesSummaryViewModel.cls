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

  /**
   * @description constructor for SOPIncomesSummaryViewModel
   * @param sourceData source data
   * @param partyIdToFirstNameMap party id to first name map
   * @param sopId the sop component name
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public SOPIncomesSummaryViewModel(
    SOPGetConsolidatedModel.IncomesSummary sourceData,
    Map<String, String> partyIdToFirstNameMap,
    String sopId
  ) {
    this.incomes = new List<SOPIncomeViewModel>();
    this.currencyCode = sourceData?.incomesTotalAmount?.currencyCode ?? 'AUD';
    this.totalAmount = SOPHelper.convertAmountToDecimal(
      sourceData.incomesTotalAmount
    );
    for (SOPGetConsolidatedModel.Incomes income : sourceData.incomes) {
      this.incomes.add(
        new SOPIncomeViewModel(income, partyIdToFirstNameMap, sopId)
      );
    }
  }
}
