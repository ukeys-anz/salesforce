/** @author Jaya Srivastava
 * @since Nov 2024
 * @description Request model for Update Loan Preference
 * @group Models
 */
public class LoanPreferenceEditModel extends CalloutModel {
  /**
   * @description List of Updated Loan Preference Records
   */
  public String etag;
  public String uid;
  public Decimal termMonths;
  public String repaymentFrequency;
  public Boolean offset;
  public String interestRateType;
  public String repaymentType;
  public List<Funds> funds;

  /**
   * @description blank constructor for parsing
   */
  public LoanPreferenceEditModel() {
  }

  /**
   * @description List of Additional Funds updated in Loan Preference Record
   */
  public class Funds {
    public String purpose;
    public FabricType.FabricMoney amount;
    public String reason;

    /**
     * @description blank constructor for parsing
     */
    public Funds() {
    }

    /**
     * @description constructor with 1 parameter
     * @param updateFunds AdditionalFundsViewModel.AdditionalFunds
     */
    public Funds(AdditionalFundsViewModel.AdditionalFunds updateFunds) {
      this.purpose = updateFunds.purpose;
      this.amount = new FabricType.FabricMoney('AUD', updateFunds.amount);
      this.reason = updateFunds.otherReason;
    }
  }

  /**
   * @description constructor with 2 parameter
   * @param updateLoanPreferenceData LoanPreferenceViewModel
   * @param additionalFundsData AdditionalFundsViewModel
   */
  public LoanPreferenceEditModel(
    LoanPreferenceViewModel updateLoanPreferenceData,
    AdditionalFundsViewModel additionalFundsData
  ) {
    this.etag = updateLoanPreferenceData.etag;
    this.uid = updateLoanPreferenceData.uid;
    this.repaymentFrequency = updateLoanPreferenceData.loanRepaymentFrequency;
    this.offset = updateLoanPreferenceData.offset.toLowerCase() == 'yes';
    this.termMonths = updateLoanPreferenceData.loanTermInMonths;
    this.interestRateType = updateLoanPreferenceData.interestRateType;
    this.repaymentType = updateLoanPreferenceData.loanRepaymentType;
    this.funds = new List<LoanPreferenceEditModel.Funds>();
    if (additionalFundsData?.additionalFunds?.size() > 0) {
      for (
        AdditionalFundsViewModel.AdditionalFunds updateFunds : additionalFundsData.additionalFunds
      ) {
        this.funds.add(new LoanPreferenceEditModel.Funds(updateFunds));
      }
    }
    AdditionalFundsViewModel.AdditionalFunds currentLoanBalance = new AdditionalFundsViewModel.AdditionalFunds();
    currentLoanBalance.purpose = 'LENDING_PURPOSE_REFINANCE';
    currentLoanBalance.amount = updateLoanPreferenceData.currentLoanBalance;
    currentLoanBalance.otherReason = '';
    this.funds.add(new LoanPreferenceEditModel.Funds(currentLoanBalance));
  }
}
