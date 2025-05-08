/**
 * @description view model for loan Preference
 * @author @ram
 * @since 02/12/2024
 */
public class LoanPreferenceViewModel {
  /**
   * @description estimatedRepaymentAmount.
   */
  @AuraEnabled
  public Decimal estimatedRepaymentAmount { get; set; }

  /**
   * @description interestRate.
   */
  @AuraEnabled
  public Integer interestRate { get; set; }

  /**
   * @description name.
   */
  @AuraEnabled
  public String name { get; set; }

  /**
   * @description currentLoanBalance.
   */
  @AuraEnabled
  public Decimal currentLoanBalance { get; set; }

  /**
   * @description requestLoanAmount.
   */
  @AuraEnabled
  public Decimal requestLoanAmount { get; set; }

  /**
   * @description borrowAdditionalFunds.
   */
  @AuraEnabled
  public String borrowAdditionalFunds { get; set; }

  /**
   * @description interestRateType.
   */
  @AuraEnabled
  public String interestRateType { get; set; }

  /**
   * @description lastUpdatedDate.
   */
  @AuraEnabled
  public Datetime lastUpdatedDate { get; set; }

  /**
   * @description loanRepaymentType.
   */
  @AuraEnabled
  public String loanRepaymentType { get; set; }

  /**
   * @description loanRepaymentFrequency.
   */
  @AuraEnabled
  public String loanRepaymentFrequency { get; set; }

  /**
   * @description loanTerm.
   */
  @AuraEnabled
  public String loanTerm { get; set; }

  /**
   * @description loanMargin.
   */
  @AuraEnabled
  public Decimal loanMargin { get; set; }

  /**
   * @description offset.
   */
  @AuraEnabled
  public String offset { get; set; }

  /**
   * @description etag.
   */
  @AuraEnabled
  public String etag { get; set; }

  /**
   * @description uid.
   */
  @AuraEnabled
  public String uid { get; set; }

  /**
   * @description ocvId.
   */
  @AuraEnabled
  public String ocvId { get; set; }

  /**
   * @description loanApplicationNumber.
   */
  @AuraEnabled
  public String loanApplicationNumber { get; set; }

  /**
   * @description loanTermInMonths.
   */
  @AuraEnabled
  public Decimal loanTermInMonths { get; set; }

  /**
   * @description loanId.
   */
  @AuraEnabled
  public String loanId { get; set; }

  /**
   * @description timeZone of current user
   */
  @AuraEnabled
  public String timeZone { get; set; }

  /**
   * @description Property Use
   */
  @AuraEnabled
  public String propertyUse { get; set; }

  /**
   * @description Percentage Deductible
   */
  @AuraEnabled
  public Integer percentDeductible { get; set; }

  /**
   * @description blank constructor for parsing
   */
  public LoanPreferenceViewModel() {
  }
  /**
   * @description Constructor for LoanPreferenceViewModel
   * @param loanApplicationFinancial LoanApplicationFinancial object
   */
  public LoanPreferenceViewModel(
    LoanApplicationFinancial loanApplicationFinancial
  ) {
    this.name = loanApplicationFinancial.Name;
    this.currentLoanBalance = loanApplicationFinancial.current_Loan_Balance__c;
    this.requestLoanAmount = loanApplicationFinancial.LoanExclFinMortInsAmt;
    this.borrowAdditionalFunds = loanApplicationFinancial.borrow_Additional_Funds__c;
    this.interestRateType = loanApplicationFinancial.interest_Rate_Type__c;
    this.lastUpdatedDate = loanApplicationFinancial.last_Updated_Date__c;
    this.loanRepaymentType = loanApplicationFinancial.Loan_Repayment_Type__c;
    this.loanRepaymentFrequency = loanApplicationFinancial.Loan_Repayment_Frequency__c;
    this.loanTerm = loanApplicationFinancial.loan_Term__c;
    this.loanMargin = (loanApplicationFinancial.loan_Margin__c != null)
      ? (loanApplicationFinancial.loan_Margin__c / 100)
      : null;
    this.offset = loanApplicationFinancial.Offset__c;
    this.etag = loanApplicationFinancial.E_Tag__c;
    this.uid = loanApplicationFinancial.FinancialExtIdentifier;
    this.ocvId = loanApplicationFinancial.LoanApplication?.Account?.OCV_ID__c;
    this.loanTermInMonths = loanApplicationFinancial.Loan_Term_in_Months__c;
    this.loanId = loanApplicationFinancial.LoanApplication?.Id;
    this.loanApplicationNumber = loanApplicationFinancial.LoanApplication
      ?.ApplicationExtIdentifier;
    this.timeZone = UserInfo.getTimeZone().getID();
    this.propertyUse = loanApplicationFinancial.LoanApplication
      ?.Property_Use__c;
    this.percentDeductible = (Integer) loanApplicationFinancial.Percentage_Deductible__c;
  }
}
