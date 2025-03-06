/**
 * @author Peter Charalambous
 * @since Tue Sep 24 2024
 * @description Summary view model for savings finance section of getConsolidatedSOP API call
 */

public with sharing class SOPSavingsSummaryViewModel {
  @AuraEnabled
  public Decimal savingsTotalAmount;
  @AuraEnabled
  public String currencyCode;
  @AuraEnabled
  public List<SOPSavingsViewModel> savings;

  /**
   * @description map from sop consolidated api model to consolidated view model
   * @param sourceData savings summary api data
   * @param totalAmount savings total amount
   * @param partyIdToFirstNameMap party id to first name map
   */
  public SOPSavingsSummaryViewModel(
    List<SOPGetConsolidatedModel.Assets> sourceData,
    Decimal totalAmount,
    Map<String, String> partyIdToFirstNameMap
  ) {
    this.currencyCode = 'AUD';
    this.savingsTotalAmount = totalAmount;
    this.savings = new List<SOPSavingsViewModel>();
    for (SOPGetConsolidatedModel.Assets saving : sourceData) {
      this.savings.add(new SOPSavingsViewModel(saving, partyIdToFirstNameMap));
    }
  }
}
