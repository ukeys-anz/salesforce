/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description Credit Card external query class
 */
public with sharing class CreditCardExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  @testVisible
  private class CreditCardModel extends FinancialAccountModelBase {
    private Decimal interestRate;
    private String controllingPostId;
    private DateTime openDate;
    private Decimal cashAdvanceRate;
    private Integer interestFreeDays;
    private List<String> blockCodes;
    private Datetime accountClosedDate;
    private String branchId;
    private Decimal currentDueAmount;
    private Decimal availableBalance;
    private String rewardsNumber;
    private Decimal delinquentAmount;
    public Integer totalDelinquentDays;
    private String address;
    private String subProductCode;
    private String sourceSystemStatus;
  }

  private static final Map<String, String> MAP_OF_BLOCK_CODES = new Map<String, String>{
    'A' => 'A - Agent',
    'B' => 'B - Bankrupt',
    'C' => 'C - Closed by Customer',
    'D' => 'D - Deceased',
    'F' => 'F - Fraud',
    'G' => 'G - Revoked by Collections',
    'H' => 'H - Suspended',
    'I' => 'I - Moratorium',
    'K' => 'K - Divorced or Separated',
    'L' => 'L - Lost',
    'M' => 'M - Mail Returned',
    'N' => 'N - Non Reissue',
    'P' => 'P - Past Due',
    'Q' => 'Q - Cycle Past Due',
    'R' => 'R - Arrangement',
    'S' => 'S - Stolen',
    'T' => 'T - Fraud Temporary Close',
    'W' => 'W - Default',
    'X' => 'X - Transfer',
    'Y' => 'Y - Sold Accounts',
    'Z' => 'Z - Charge Off'
  };

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    'A' => 'A - Active',
    'D' => 'D - Dormant',
    'F' => 'F - Fraud Transfer',
    'N' => 'N - New Account',
    'P' => 'P - Account To Purge',
    'Q' => 'Q - Lost/Stolen Transfer in',
    'R' => 'R - Lost/Stolen Transfer out',
    'T' => 'T - Lost/Stolen Transfer',
    'U' => 'U - IPT/Consolidation',
    'W' => 'W - IPT/Consolidation Transfer',
    'Y' => 'Y - IPT/Consolidation Transfer Out',
    'Z' => 'Z - Charged-off',
    '8' => '8 - Closed (12 months with zero balance and activity)',
    '9' => '9 - Purged'
  };

  /**
   * @description CreditCard API callout response
   */
  @testVisible
  private class CreditCardCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    private List<CreditCardModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CreditCardExternalQuery() {
    this.productCategory = 'credit-card';
    this.productTypes = new Set<String>{ 'CAP-CIS:PCA' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
    this.useProductCodeFromFinancialAccount = true;
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (CreditCardCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CreditCardCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to CreditCard records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse ExternalObjectCalloutResponse calloutResponse
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      CreditCardModel fa : ((CreditCardCalloutResponse) calloutResponse)
        .accounts
    ) {
      String blockCode1 = '';
      String blockCode2 = '';
      if (fa.blockCodes != null) {
        Integer blockCodeSize = fa.blockCodes.size();
        if (blockCodeSize > 0) {
          blockCode1 = MAP_OF_BLOCK_CODES.containsKey(fa.blockCodes[0])
            ? MAP_OF_BLOCK_CODES.get(fa.blockCodes[0])
            : fa.blockCodes[0];
        }
        if (blockCodeSize > 1) {
          blockCode2 = MAP_OF_BLOCK_CODES.containsKey(fa.blockCodes[1])
            ? MAP_OF_BLOCK_CODES.get(fa.blockCodes[1])
            : fa.blockCodes[1];
        }
      }
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
        'ProductCode' => getProductCode(fa.accountNumber),
        'OpenedDate' => formatDate(fa.openDate),
        'InterestRate' => fa.interestRate,
        'CreditLimit' => fa.accountLimit,
        'CashAdvanceRate' => fa.cashAdvanceRate,
        'InterestFreeDays' => fa.interestFreeDays,
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.get(
          fa.sourceSystemStatus
        ) ?? fa.sourceSystemStatus,
        'SubProductCode' => getSubProductCode(fa.accountNumber),
        'ProductName' => getProductName(fa.accountNumber),
        'BlockCode1' => blockCode1,
        'BlockCode2' => blockCode2,
        'DateClosed' => formatDate(fa.accountClosedDate),
        'Branch' => fa.branchId,
        'MinimumMonthlyPayment' => fa.currentDueAmount,
        'AvailableFunds' => fa.availableBalance,
        'RewardsNumber' => fa.rewardsNumber,
        'DelinquentAmount' => fa.delinquentAmount,
        'DaysDelinquent' => fa.totalDelinquentDays,
        'StatementMailingAddress' => fa.address
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
