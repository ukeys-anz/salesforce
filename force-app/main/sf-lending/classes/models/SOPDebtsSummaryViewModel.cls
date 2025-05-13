/**
 * @author Peter Charalambous
 * @since Thu Oct 03 2024
 * @description View model for debts finance section of getConsolidatedSOP API call
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class SOPDebtsSummaryViewModel {
  //List of statuses to hide from front end
  private static final List<String> HIDE_STATUSES = new List<String>{
    'ACCOUNT_STATE_CLOSED'
  };
  private static final ResidentialLoanApplicationRepository RLA_SOQL_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  @AuraEnabled
  public Decimal debtsTotalAmount;
  @AuraEnabled
  public String currencyCode;
  @AuraEnabled
  public List<SOPDebtsViewModel> debts;
  @AuraEnabled
  public Integer sourcesSize = 0;
  @AuraEnabled
  public List<String> refinancedAssets;
  @AuraEnabled
  public Map<String, SOPGetConsolidatedModel.Assets> propertyAssets;

  /**
   * @description Constructor for Debts view model
   * @param sourceData liabilitiesSummary api data
   * @param partyIdToFirstNameMap party id to first name map
   * @param loanId loan id
   * @param assetPropertyLookup map of address lookup
   */
  //Suppress warning as params needed for model data
  public SOPDebtsSummaryViewModel(
    SOPGetConsolidatedModel.liabilitiesSummary sourceData,
    Map<String, String> partyIdToFirstNameMap,
    String loanId,
    Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup
  ) {
    this.currencyCode = 'AUD';
    this.debtsTotalAmount = SOPHelper.convertAmountToDecimal(
      sourceData.liabilitiesTotalAmount
    );
    this.propertyAssets = assetPropertyLookup;

    Set<String> refinanceSet = handleRefinance(loanId);

    this.debts = new List<SOPDebtsViewModel>();
    //Create set to avoid duplicate assets, Set not supported for AuraEnabled attribute
    Set<String> refinancedAssetsSet = new Set<String>();
    this.sourcesSize = sourceData.sources?.size();
    for (
      SOPGetConsolidatedModel.liabilities liability : sourceData.liabilities
    ) {
      if (HIDE_STATUSES.contains(liability.account?.status)) {
        continue;
      }

      if (
        refinanceSet.contains(liability.name) &&
        liability.assets != null &&
        !liability.assets.isEmpty()
      ) {
        refinancedAssetsSet.addAll(liability.assets);
      }
      this.debts.add(
        new SOPDebtsViewModel(
          liability,
          partyIdToFirstNameMap,
          refinanceSet,
          assetPropertyLookup
        )
      );
    }

    //Assign assets being refinanced
    this.refinancedAssets = new List<String>(refinancedAssetsSet);
  }

  /**
   * @description Handle refinance assets
   * @param loanId the RLA id
   * @return Set<String> set of refinance assets
   */
  private static Set<String> handleRefinance(String loanId) {
    Set<String> refinanceSet = new Set<String>();
    for (
      LoanApplicationLiability lal : RLA_SOQL_REPOSITORY.getLoanApplicationLiability(
        loanId
      )
    ) {
      if (lal?.Name != null) {
        refinanceSet.add(lal.Name);
      }
    }

    return refinanceSet;
  }
}
