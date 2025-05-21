/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description request model for Loan Preference
 * @group Models
 */

public class LoanPreferenceRequestModel {
  public FabricType.FabricMoney loanAmount;
  public Integer repaymentFrequency;
  public Integer termMonths;
  public Integer productType;

  public enum REPAYMENT_FREQUENCY {
    REPAYMENT_FREQUENCY_UNSPECIFIED,
    REPAYMENT_FREQUENCY_WEEKLY,
    REPAYMENT_FREQUENCY_FORTNIGHTLY,
    REPAYMENT_FREQUENCY_MONTHLY,
    REPAYMENT_FREQUENCY_QUARTERLY,
    REPAYMENT_FREQUENCY_BI_ANNUAL,
    REPAYMENT_FREQUENCY_ANNUAL
  }

  public enum PRODUCT_TYPE {
    LOAN_PRODUCT_TYPE_UNSPECIFIED,
    LOAN_PRODUCT_TYPE_OWNER_OCCUPIED,
    LOAN_PRODUCT_TYPE_INVESTOR
  }

  /**
   * @description constructor with 1 parameter
   * @param loanAppFinancial LoanApplicationFinancial
   */
  public LoanPreferenceRequestModel(LoanApplicationFinancial loanAppFinancial) {
    this.loanAmount = new FabricType.FabricMoney(
      'AUD',
      loanAppFinancial.LoanExclFinMortInsAmt
    );
    REPAYMENT_FREQUENCY repayFrequency = REPAYMENT_FREQUENCY.valueOf(
      loanAppFinancial.Loan_Repayment_Frequency__c
    );
    this.repaymentFrequency = repayFrequency.ordinal();
    this.termMonths = Integer.valueOf(loanAppFinancial.Loan_Term_in_Months__c);
    PRODUCT_TYPE productTypeValue = PRODUCT_TYPE.valueOf(
      loanAppFinancial.LoanApplication?.Property_Use__c ??
        'LOAN_PRODUCT_TYPE_OWNER_OCCUPIED'
    );
    this.productType = productTypeValue.ordinal();
  }
}
