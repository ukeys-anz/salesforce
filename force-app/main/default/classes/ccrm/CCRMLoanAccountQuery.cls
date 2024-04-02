/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Loan Account external query class
 * @runTests CCRMLoanAccountQueryTest
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.NcssMethodCount'
)
public with sharing class CCRMLoanAccountQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  private class CCRMLoanAccountModel extends CCRMFinancialAccountModelBase {
    public String subProductCode;
    public DateTime startDate;
    public Decimal amountInAdvance;
    public Decimal originalAmountFinanced;
    public String purpose;
    public String purposeCode;
    public String interestType;
    public Integer loanTermYear;
    public Integer loanTermMonth;
    public Boolean fullyDrawn;
    public DateTime progressDrawExpiryDate;
    public String offsetAccountNumber;
    public String anzsicCode;
    public String controllingPostID;
    public DateTime endDate;
    public String tpmiNumber;
    public String subApprovedOrignation;
    public Boolean anzPlusIdentifier;
    public String accountShortName;
    public DateTime closedDate;
    public DateTime lastRenewalDate;
    public String branchName;
    public Decimal redrawAmount;
    public Integer redrawNumberOfSignatories;
    public DateTime dateLoanIssued;
    public DateTime loanMaturityDate;
    public Boolean redrawRegistration;
    public String referenceIndexType;
    public Decimal referenceIndexRate;
    public Decimal interestRateMargin;
    public Decimal interestRate;
    public Integer fixedRateTermYear;
    public Integer fixedRateTermMonth;
    public DateTime fixedRateStartDate;
    public DateTime fixedRateEndDate;
    public String repaymentFrequency;
    public String interestRepayments;
    public String interestChargeMethod;
    public String repaymentType;
    public Integer daysDelinquent;
    public Integer timesPastDueG;
    public Integer timesPastDue30;
    public Integer timesPastDue60;
    public Integer timesPastDue90;
    public Integer timesPastDue120;
    public Decimal piRepaymentAmount;
    public DateTime piPrincipalRepaymentStartDate;
    public DateTime piPrincipalRepaymentEndDate;
    public String piInterestFrequency;
    public Decimal ioRepaymentAmount;
    public String ioInterestRepaymentAccountNumber;
    public Integer ioTermYear;
    public Integer ioTermMonth;
    public DateTime ioStartDate;
    public DateTime ioExpiryDate;
    public DateTime ioNextRepaymentDate;
    public String ioInterestFrequency;
    public Decimal ioInitialInterestRate;
    public Decimal ioInitialDiscount;
    public Decimal ioSubsequentInterestRate;
    public Decimal ioSubsequentDiscount;
    public Integer piInitialRepaymentCycleDay;
    public String dlpRepaymentAccountNumber;
    public Decimal piElectedRepaymentAmount;
  }

  /**
   * @description LoanAccount API callout response
   */
  public class LoanAccountCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMLoanAccountModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMLoanAccountQuery() {
    this.productCategory = 'loan';
    this.productTypes = new Set<String>{ 'CAP-CIS:ILS' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }

    this.calloutResponse = (LoanAccountCalloutResponse) CalloutModel.deserialize(
      responseBody,
      LoanAccountCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Loan account records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    String customerId;
    Map<String, Object> row;
    List<CCRMLoanAccountModel> accounts = new List<CCRMLoanAccountModel>();

    if (this.calloutResponse != null) {
      accounts = ((LoanAccountCalloutResponse) this.calloutResponse).accounts;
    }

    for (CCRMLoanAccountModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      row.put('CustomerId', customerId);
      row.put('ExternalId', getExternalId(fa));
      row.put('DisplayUrl', getDisplayUrl(fa));
      row.put('Relationship', getAccountRelationship(fa.accountNumber));

      row.put('AccountName', fa.accountName);
      row.put('AccountNumber', formatAccountNumber(fa.accountNumber));
      row.put('AccountStatus', fa.status);
      row.put('Balance', fa.accountBalance);
      row.put('ProductCode', fa.productCode);
      // Detail fields
      row.put('SubProductCode', fa.subProductCode);
      row.put('LoanTermMonth', fa.loanTermMonth);
      row.put('LoanTermYear', fa.loanTermYear);
      row.put('DateLoanIssued', formatDate(fa.dateLoanIssued));
      row.put('PurposeCode', fa.purposeCode);
      row.put('FullyDrawn', fa.fullyDrawn);
      row.put('ProgressDrawExpiryDate', formatDate(fa.progressDrawExpiryDate));
      row.put('ANZSICCode', fa.anzsicCode);
      row.put('CPID', fa.controllingPostID);
      row.put('Expires', formatDate(fa.loanMaturityDate));
      row.put('TPMI', fa.tpmiNumber);
      row.put('SAO', fa.subApprovedOrignation);
      row.put('ANZPlusIdentifier', fa.anzPlusIdentifier);
      row.put('BranchName', fa.branchName);
      row.put('AmountInAdvance', fa.amountInAdvance);
      row.put('OriginalAmountFinanced', fa.originalAmountFinanced);
      row.put('InterestType', fa.interestType);
      row.put('OffsetAccountNumber', fa.offsetAccountNumber);
      row.put('RedrawAmount', fa.redrawAmount);
      row.put('RedrawNumberofSignatories', fa.redrawNumberOfSignatories);
      row.put('RedrawRegistration', fa.redrawRegistration);
      row.put('ReferenceIndexType', fa.referenceIndexType);
      row.put('ReferenceIndexRate', fa.referenceIndexRate);
      row.put('InterestRateMargin', fa.interestRateMargin);
      row.put('InterestRate', fa.interestRate);
      row.put('FixedRateTermYear', fa.fixedRateTermYear);
      row.put('FixedRateTermMonth', fa.fixedRateTermMonth);
      row.put('FixedRateStartDate', formatDate(fa.fixedRateStartDate));
      row.put('FixedRateExpiryDate', formatDate(fa.fixedRateEndDate));
      row.put('RepaymentFrequency', fa.repaymentFrequency);
      row.put('InterestRepayments', fa.interestRepayments);
      row.put('InterestChargeMethod', fa.interestChargeMethod);
      row.put('RepaymentType', fa.repaymentType);
      row.put('DaysDelinquent', fa.daysDelinquent);
      row.put('GraceDays', fa.timesPastDueG);
      row.put('PastDue30', fa.timesPastDue30);
      row.put('PastDue60', fa.timesPastDue60);
      row.put('PastDue90', fa.timesPastDue90);
      row.put('PastDue120', fa.timesPastDue120);
      row.put('PIRepaymentAmount', fa.piRepaymentAmount);
      row.put(
        'PIPrincipalRepaymentStartDate',
        formatDate(fa.piPrincipalRepaymentStartDate)
      );
      row.put(
        'PIPrincipalRepaymentEndDate',
        formatDate(fa.piPrincipalRepaymentEndDate)
      );
      row.put('PIInterestFrequency', fa.piInterestFrequency);
      row.put('InterestOnlyRepaymentAmount', fa.ioRepaymentAmount);
      row.put(
        'IOInterestRepaymentAccountNumber',
        fa.ioInterestRepaymentAccountNumber
      );
      row.put('InterestOnlyTermYear', fa.ioTermYear);
      row.put('InterestOnlyTermMonth', fa.ioTermMonth);

      row.put('InterestOnlyStartDate', formatDate(fa.ioStartDate));
      row.put('InterestOnlyExpiryDate', formatDate(fa.ioExpiryDate));
      row.put('IONextRepaymentDate', formatDate(fa.ioNextRepaymentDate));
      row.put('IOInterestFrequency', fa.ioInterestFrequency);
      row.put('IOInitialInterestRate', fa.ioInitialInterestRate);
      row.put('IOInitialDiscount', fa.ioInitialDiscount);
      row.put('IOSubsequentInterestRate', fa.ioSubsequentInterestRate);
      row.put('IOSubsequentDiscount', fa.ioSubsequentDiscount);
      row.put('PIInitialRepaymentCycleDay', fa.piInitialRepaymentCycleDay);
      row.put('DLPRepaymentAccountNumber', fa.dlpRepaymentAccountNumber);
      row.put('PIElectedRepaymentAmount', fa.piElectedRepaymentAmount);
      result.queryResult.add(row);
    }
    return result;
  }
}
