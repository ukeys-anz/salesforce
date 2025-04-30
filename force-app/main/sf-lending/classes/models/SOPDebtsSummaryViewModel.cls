/**
 * @author Peter Charalambous
 * @since Thu Oct 03 2024
 * @description View model for debts finance section of getConsolidatedSOP API call
 */
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

  /**
   * @description Constructor for Debts view model
   * @param sourceData liabilitiesSummary api data
   * @param partyIdToFirstNameMap party id to first name map
   * @param loanId loan id
   */
  public SOPDebtsSummaryViewModel(
    SOPGetConsolidatedModel.liabilitiesSummary sourceData,
    Map<String, String> partyIdToFirstNameMap,
    String loanId
  ) {
    this.currencyCode = 'AUD';
    this.debtsTotalAmount = SOPHelper.convertAmountToDecimal(
      sourceData.liabilitiesTotalAmount
    );

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

    this.debts = new List<SOPDebtsViewModel>();
    this.sourcesSize = sourceData.sources?.size();

    for (
      SOPGetConsolidatedModel.liabilities liability : sourceData.liabilities
    ) {
      if (HIDE_STATUSES.contains(liability.account?.status)) {
        continue;
      }
      this.debts.add(
        new SOPDebtsViewModel(liability, partyIdToFirstNameMap, refinanceSet)
      );
    }
  }
}
