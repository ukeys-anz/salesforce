/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description Loan Account external query class
 * @runTests LoanAccountQueryTest
 * @pmd Used PMD.TooManyFields as we need to have those fields in wrapper LoanAccountModel as response from external system
 */
@SuppressWarnings('PMD.TooManyFields')
public with sharing class LoanAccountExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  @testVisible
  private class LoanAccountModel extends FinancialAccountModelBase {
    private String subProductCode;
    private DateTime startDate;
    private Decimal amountInAdvance;
    private Decimal originalAmountFinanced;
    private String purpose;
    private String purposeCode;
    private String interestType;
    private Integer loanTermYear;
    private Integer loanTermMonth;
    private Boolean fullyDrawn;
    private DateTime progressDrawExpiryDate;
    private String offsetAccountNumber;
    private String anzsicCode;
    private String controllingPostID;
    private DateTime endDate;
    private Boolean anzPlusIdentifier;
    private String accountShortName;
    private DateTime closedDate;
    private DateTime lastRenewalDate;
    private String branchName;
    private Decimal redrawAmount;
    private Integer redrawNumberOfSignatories;
    private DateTime dateLoanIssued;
    private DateTime loanMaturityDate;
    private Boolean redrawRegistration;
    private String referenceIndexType;
    private Decimal referenceIndexRate;
    private Decimal interestRateMargin;
    private Decimal interestRate;
    private String tpmiNumber;
    private String subApprovedOrignation;

    private String repaymentFrequency;
    private String interestRepayments;
    private String interestChargeMethod;
    private String repaymentType;
    private Integer daysDelinquent;
    private Integer timesPastDueG;
    private Integer timesPastDue30;
    private Integer timesPastDue60;
    private Integer timesPastDue90;
    private Integer timesPastDue120;
    private Decimal piRepaymentAmount;
    private DateTime piPrincipalRepaymentStartDate;
    private DateTime piPrincipalRepaymentEndDate;
    private String piInterestFrequency;
    private String ioInterestRepaymentAccountNumber;
    private Integer ioTermYear;
    private Integer ioTermMonth;
    private DateTime ioExpiryDate;
    private DateTime ioNextRepaymentDate;
    private Decimal ioSubsequentInterestRate;
    private Decimal ioSubsequentDiscount;
    private String dlpRepaymentAccountNumber;
    private Decimal piElectedRepaymentAmount;
    private String futureInterestType;
    private String futureReferenceIndexType;
    private Decimal futureReferenceIndexRate;
    private Integer interestRateTermYear;
    private Integer interestRateTermMonths;
    private DateTime interestRateStartDate;
    private DateTime interestRateExpiryDate;
    private String creditRiskGrade;
    private String statementMailingAddress;
    private String lmiIndicator;
    private Decimal amountAdvancedToDate;
    private String sourceSystemStatus;
  }

  private static Map<String, String> mapOfPurposeCode = new Map<String, String>{
    '000' => '000 - Revolving Line Of Credit',
    '100' => '100 - Purchase New Cars and Station Wagons',
    '101' => '101 - Purchase Used Cars and Station Wagons',
    '102' => '102 - Purchase Other Motor Vehicles',
    '103' => '103 - Purchase Motorcycles and Scooters',
    '104' => '104 - Purchase Boats, Caravans and Trailers',
    '120' => '120 - Purchase Residential Land Owner-Occupied',
    '130' => '130 - Unsecured Alteration or Addition to Existing Dwelling Owner-Occupied',
    '131' => '131 - Unsecured Purchase or Construct Dwelling Owner-Occupied',
    '140' => '140 - Purchase Household and Personal Goods',
    '141' => '141 - Ongoing Facility for Temporary Financing',
    '145' => '145 - Education',
    '150' => '150 - Debt Consolidation Non ANZ Loans',
    '155' => '155 - Graduates',
    '160' => '160 - Purchase Travel and Holidays',
    '170' => '170 - Refinance Existing ANZ Non-Business Loan',
    '180' => '180 - Dwellings for Rental or Resale',
    '185' => '185 - Other Shares, Bonds and Investments',
    '190' => '190 - Refinance OFI Investment Loan',
    '199' => '199 - Other Personal Use, Pools, Kitchens etc',
    '200' => '200 - Construct Dwellings for Rental or Resale',
    '201' => '201 - Construct Shops',
    '202' => '202 - Construct Non-Building Structures',
    '203' => '203 - Alteration or Addition to Commercial Buildings',
    '204' => '204 - Construct Offices',
    '205' => '205 - Construct Industrial Buildings',
    '206' => '206 - Construct Other Buildings',
    '210' => '210 - Purchase Dwellings for Rental or Resale',
    '211' => '211 - Purchase Shops',
    '212' => '212 - Purchase Rural Property',
    '213' => '213 - Purchase Land for Residential Block Development',
    '214' => '214 - Purchase Offices',
    '215' => '215 - Purchase Industrial Buildings',
    '216' => '216 - Purchase Other Buildings',
    '219' => '219 - Purchase Other Land',
    '220' => '220 - Purchase Motor Vehicles',
    '225' => '225 - Purchase Other Transport Equipment',
    '229' => '229 - Purchase Other Plant and Equipment',
    '230' => '230 - Factoring',
    '240' => '240 - Refinance Non-ANZ Business Loans',
    '241' => '241 - Refinance ANZ Business Loans',
    '250' => '250 - Wholesale Finance',
    '260' => '260 - Establish Business',
    '261' => '261 - Purchase Business',
    '299' => '299 - Other Commercial Use, Maintenance and Repairs',
    '300' => '300 - Construct House Not First Home-Buyer',
    '301' => '301 - Construct House First Home-Buyer',
    '310' => '310 - Construct Other Dwelling Not First Home-Buyer',
    '311' => '311 - Construct Other Dwelling First Home-Buyer',
    '320' => '320 - Purchase New House Not First Home-Buyer',
    '321' => '321 - Purchase New House First Home-Buyer',
    '330' => '330 - Purchase New Other Dwelling Not First Home-Buyer',
    '331' => '331 - Purchase New Other Dwelling First Home-Buyer',
    '340' => '340 - Purchase Existing House Not First Home-Buyer',
    '341' => '341 - Purchase Existing House First Home-Buyer',
    '350' => '350 - Purchase Existing Other Dwelling Not First Home-Buyer',
    '351' => '351 - Purchase Existing Other Dwelling First Home-Buyer',
    '360' => '360 - Alteration or Addition to Existing Dwellings',
    '370' => '370 - Refinance Non-ANZ Home Loans',
    '371' => '371 - Refinance ANZ Home Loans',
    '407' => '407 - Working Capital Other'
  };

  private static Map<Integer, String> mapOfRedrawNoOfSignatories = new Map<Integer, String>{
    1 => '1-ANY ONE TO SIGN',
    2 => '2-BOTH TO SIGN (CONJOINTLY)',
    3 => '3-REFER TO ACCOUNT SIGNING AUTHORITY'
  };

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    'NON' => 'NON - Non-Accrual',
    'CAN' => 'CAN - Cancelled',
    'RI' => 'RI - Reserved Interest',
    'BNK' => 'BNK - Bankrupt',
    'BYP' => 'BYP - Bypass',
    'C-O' => 'C-O - Charged Off',
    'P-O' => 'P-O - Paid Off'
  };

  /**
   * @description LoanAccount API callout response
   */
  public class LoanAccountCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<LoanAccountModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public LoanAccountExternalQuery() {
    this.productCategory = 'loan';
    this.productTypes = new Set<String>{ 'CAP-CIS:ILS' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (LoanAccountCalloutResponse) CalloutModel.deserialize(
      responseBody,
      LoanAccountCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Loan account records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    if (calloutResponse == null) {
      return result;
    }
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      LoanAccountModel fa : ((LoanAccountCalloutResponse) calloutResponse)
        .accounts
    ) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => getExternalId(fa, this.accountRoleMap),
        'DisplayUrl' => getDisplayUrl(fa.productCode + '-' + fa.accountNumber),
        'Relationship' => getAccountRelationship(fa.accountNumber),
        'AccountName' => fa.accountName,
        'AccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.accountNumber
        ),
        'AccountStatus' => fa.status,
        'Balance' => fa.accountBalance,
        'ProductCode' => fa.productCode,
        'SubProductCode' => fa.subProductCode,
        'LoanTermMonth' => fa.loanTermMonth,
        'LoanTermYear' => fa.loanTermYear,
        'DateLoanIssued' => formatDate(fa.dateLoanIssued),
        'PurposeCode' => mapOfPurposeCode.containsKey(fa.purposeCode)
          ? mapOfPurposeCode.get(fa.purposeCode)
          : fa.purposeCode,
        'FullyDrawn' => fa.fullyDrawn,
        'ProgressDrawExpiryDate' => formatDate(fa.progressDrawExpiryDate),
        'ANZSICCode' => externalQueryHelper.retrieveIndustryCodeAndDescription(
          fa.anzsicCode
        ),
        'CPID' => fa.controllingPostID,
        'Expires' => formatDate(fa.loanMaturityDate),
        'TPMISAO' => String.isBlank(fa.tpmiNumber)
          ? ''
          : fa.tpmiNumber + '-' + fa.subApprovedOrignation,
        'ANZPlusIdentifier' => fa.anzPlusIdentifier,
        'BranchName' => fa.branchName,
        'AmountInAdvance' => fa.amountInAdvance,
        'OriginalAmountFinanced' => fa.originalAmountFinanced,
        'InterestType' => fa.interestType,
        'OffsetAccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.offsetAccountNumber
        ),
        'RedrawAmount' => fa.redrawAmount,
        'RedrawNumberofSignatories' => mapOfRedrawNoOfSignatories.containsKey(
            fa.redrawNumberOfSignatories
          )
          ? mapOfRedrawNoOfSignatories.get(fa.redrawNumberOfSignatories)
          : String.valueof(fa.redrawNumberOfSignatories),
        'RedrawRegistration' => fa.redrawRegistration,
        'IndexCodeCurrent' => fa.referenceIndexType,
        'IndexRateCurrent' => fa.referenceIndexRate,
        'InterestRateMargin' => fa.interestRateMargin,
        'InterestRate' => fa.interestRate,
        'RepaymentFrequency' => fa.repaymentFrequency,
        'InterestRepayments' => fa.interestRepayments,
        'InterestChargeMethod' => fa.interestChargeMethod,
        'RepaymentType' => fa.repaymentType,
        'DaysDelinquent' => fa.daysDelinquent,
        'GraceDays' => fa.timesPastDueG,
        'PastDue30' => fa.timesPastDue30,
        'PastDue60' => fa.timesPastDue60,
        'PastDue90' => fa.timesPastDue90,
        'PastDue120' => fa.timesPastDue120,
        'PIRepaymentAmount' => fa.piRepaymentAmount,
        'PIPrincipalRepaymentStartDate' => formatDate(
          fa.piPrincipalRepaymentStartDate
        ),
        'PIPrincipalRepaymentEndDate' => formatDate(
          fa.piPrincipalRepaymentEndDate
        ),
        'PIInterestFrequency' => fa.piInterestFrequency,
        'IOInterestRepaymentAccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.ioInterestRepaymentAccountNumber
        ),
        'InterestOnlyTermYear' => fa.ioTermYear,
        'InterestOnlyTermMonth' => fa.ioTermMonth,
        'InterestOnlyExpiryDate' => formatDate(fa.ioExpiryDate),
        'IONextRepaymentDate' => formatDate(fa.ioNextRepaymentDate),
        'IOSubsequentInterestRate' => fa.ioSubsequentInterestRate,
        'IOSubsequentDiscount' => fa.ioSubsequentDiscount,
        'DLPRepaymentAccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.dlpRepaymentAccountNumber
        ),
        'PIElectedRepaymentAmount' => fa.piElectedRepaymentAmount,
        'InterestTypeFuture' => fa.futureInterestType,
        'IndexCodeFuture' => fa.futureReferenceIndexType,
        'IndexRateFuture' => fa.futureReferenceIndexRate,
        'InterestRateTermYear' => fa.interestRateTermYear,
        'InterestRateTermMonth' => fa.interestRateTermMonths,
        'InterestRateStartDate' => formatDate(fa.interestRateStartDate),
        'InterestRateExpiryDate' => formatDate(fa.interestRateExpiryDate),
        'ProductName' => getProductName(fa.accountNumber),
        'StatementMailingAddress' => fa.statementMailingAddress,
        'LendersMortgageInsurance' => fa.lmiIndicator,
        'CCR' => fa.creditRiskGrade,
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.containsKey(
            fa.sourceSystemStatus
          )
          ? MAP_SOURCE_SYSTEM_STATUS.get(fa.sourceSystemStatus)
          : fa.sourceSystemStatus,
        'AmountAdvancedToDate' => fa.amountAdvancedToDate
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
