/**
 * @author Peter Charalambous
 * @since Tue Sep 24 2024
 * @description Summary view model for assets finance section of getConsolidatedSOP API call
 */

public with sharing class SOPAssetsSummaryViewModel {
  private static final ResidentialLoanApplicationRepository RLA_SOQL_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  @AuraEnabled
  public Decimal assetsTotalAmount;
  @AuraEnabled
  public String currencyCode;
  @AuraEnabled
  public List<SOPAssetsViewModel> assets;

  /**
   * @description map from sop consolidated api model to consolidated view model
   * @param sourceData assets summary api data
   * @param totalAmount assets total amount
   * @param partyIdToFirstNameMap party id to first name map
   * @param loanId the RLA id
   */
  public SOPAssetsSummaryViewModel(
    List<SOPGetConsolidatedModel.Assets> sourceData,
    Decimal totalAmount,
    Map<String, String> partyIdToFirstNameMap,
    Id loanId
  ) {
    this.currencyCode = 'AUD';
    this.assetsTotalAmount = totalAmount;
    this.assets = new List<SOPAssetsViewModel>();

    Set<String> propertyIdSet = SOPHelper.getPropertyIdSet(sourceData);
    List<LoanApplicationProperty> properties = RLA_SOQL_REPOSITORY.queryRelatedProperties(
      loanId,
      propertyIdSet
    );

    for (SOPGetConsolidatedModel.Assets asset : sourceData) {
      this.assets.add(
        new SOPAssetsViewModel(asset, partyIdToFirstNameMap, properties)
      );
    }
  }
}
