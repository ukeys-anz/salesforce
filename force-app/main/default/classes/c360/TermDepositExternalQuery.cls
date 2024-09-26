/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description Term Deposit external query class
 * @runTests TermDepositExternalQueryTest
 */
public with sharing class TermDepositExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description TermDeposit Model class
   */
  @SuppressWarnings('PMD.TooManyFields')
  @testVisible
  private class TermDepositModel extends FinancialAccountModelBase {
    private String subProductCode;
    private Boolean restrainsHardHold;
    private Boolean pledge;
    private Decimal pledgeAmount;
    private DateTime openDate;
    private DateTime closeDate;
    private String bsbCode;
    private String anzsicCode;
    private String controllingPostId;
    private String noOfSignatures;
    private DateTime cdaIssueDate;
    private DateTime maturityDate;
    private Integer termYear;
    private Integer termMonth;
    private List<Decimal> creditInterestRateArray;
    private List<Integer> creditInterestLimitsArray;
    private Decimal availableBalance;
    private string address;
    private string tpmiNumber;
    private string tpmiSAO;
    private String sourceSystemStatus;
  }

  /**
   * @description TermDeposit API callout response
   */
  @testVisible
  private class TermAccountCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<TermDepositModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public TermDepositExternalQuery() {
    this.productCategory = 'deposit';
    this.productTypes = new Set<String>{ 'CAP-CIS:CDA' };
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
    this.calloutResponse = (TermAccountCalloutResponse) CalloutModel.deserialize(
      responseBody,
      TermAccountCalloutResponse.class
    );
    return this.calloutResponse;
  }

  private static final Map<String, String> MAP_NO_OF_SIGNATURES = new Map<String, String>{
    '1' => '1 - ANY ONE TO SIGN',
    '2' => '2 - BOTH TO SIGN (CONJOINTLY)',
    '3' => '3 - REFER TO ACCOUNT SIGNING AUTHORITY'
  };

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    '99' => '99 - Active',
    '01' => '01 - New',
    '03' => '03 - Inactive',
    '05' => '05 - Dormant',
    '06' => '06 - Unclaimed',
    '07' => '07 - Closed',
    '08' => '08 - Purgeable',
    '11' => '11 - Matured'
  };

  /**
   * @description Transform API response to TermDeposit records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */

  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    String customerId;
    String accNumber;
    Map<String, Object> row;
    List<TermDepositModel> accounts = new List<TermDepositModel>();
    if (this.calloutResponse == null) {
      return result;
    }
    for (
      TermDepositModel fa : ((TermAccountCalloutResponse) this.calloutResponse)
        .accounts
    ) {
      customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      accNumber = this.sourceSystem == SourceSystemEnum.CAP
        ? getAccountNumberwithFormat(fa.accountNumber)
        : formatAccountNumber(fa.accountNumber);

      row = new Map<String, Object>{
        'CustomerId' => customerId,
        'ExternalId' => getExternalId(fa, this.accountRoleMap),
        'DisplayUrl' => getDisplayUrl(fa),
        'AccountName' => fa.accountName,
        'AccountNumber' => accNumber,
        'Balance' => fa.accountBalance,
        'SubProductCode' => fa.subProductCode,
        'RestraintsHold' => fa.restrainsHardHold,
        'Pledge' => fa.pledge,
        'PledgeAmount' => fa.pledgeAmount,
        'DateOpened' => formatDate(fa.openDate),
        'DateClosed' => formatDate(fa.closeDate),
        'BSB' => fa.bsbCode,
        'ANZSICCode' => retrieveIndustryCodeAndDescription(fa.anzsicCode),
        'CPID' => fa.controllingPostId,
        'NumberOfSignatures' => MAP_NO_OF_SIGNATURES.get(fa.noOfSignatures),
        'IssueDate' => formatDate(fa.cdaIssueDate),
        'MaturityDate' => formatDate(fa.maturityDate),
        'TermYear' => fa.termYear,
        'TermMonth' => fa.termMonth,
        'BalanceAvailable' => fa.availableBalance,
        'ProductCode' => getProductCode(fa.accountNumber),
        'ProductName' => getProductName(fa.accountNumber),
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.containsKey(
            fa.sourceSystemStatus
          )
          ? MAP_SOURCE_SYSTEM_STATUS.get(fa.sourceSystemStatus)
          : fa.sourceSystemStatus,
        'AccountStatus' => fa.status,
        'StatementMailingAddress' => fa.address,
        'TPMISAO' => '',
        'Relationship' => getAccountRelationship(fa.accountNumber)
      };
      populateInterestRate(row, fa);
      result.externalRecords.add(row);
    }
    return result;
  }
  /**
   * @description This is used to populate the seasonal limits
   * @param row Map<String, Object>
   * @param fa TermDepositModel
   **/
  @testVisible
  private static void populateInterestRate(
    Map<String, Object> row,
    TermDepositModel fa
  ) {
    List<Decimal> creditInterestRateArray = new List<Decimal>(
      fa.creditInterestRateArray
    );
    List<Integer> creditInterestLimitsArray = new List<Integer>(
      fa.creditInterestLimitsArray
    );
    for (Integer i = 0; i < creditInterestLimitsArray.size() - 1; i++) {
      if (
        fa.accountBalance >= creditInterestLimitsArray[i] &&
        (fa.accountBalance <= creditInterestLimitsArray[i + 1] ||
        (creditInterestLimitsArray[i + 1] == 0 &&
        fa.accountBalance != 0))
      ) {
        row.put('InterestRate', creditInterestRateArray[i]);
        break;
      }
    }
  }
}
