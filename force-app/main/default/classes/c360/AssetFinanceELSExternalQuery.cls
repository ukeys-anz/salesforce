/**
 * @author Nabia Nadir
 * @since  09/2024
 * @group Platform
 * @description Asset Finance ELS external query class
 * @runTests AssetFinanceELSExternalQueryTest
 */
public with sharing class AssetFinanceELSExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  @testVisible
  private class AssetFinanceELSModel extends FinancialAccountModelBase {
    public String compositeAccountNumber;
    public String tradingName;
    public String merchantId;
    public String merchantTerminals;
    public String legalName;
    public Decimal interestRate;
    public Decimal accountBalance;
    public Decimal arrearsAmount;
    public DateTime expiryDate;
    public Decimal balloonAmount;
    public Decimal repaymentAmount;
    public String loanRepaymentFrequency;
    public String interestType;
    public string description;
    public String loanTermYear;
    public String loanTermMonth;
  }

  /**
   * @description CreditCard API callout response
   */
  @testVisible
  private class AssetFinanceELSCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<AssetFinanceELSModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public AssetFinanceELSExternalQuery() {
    this.productCategory = 'asset-finance';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.assetFinanceType = 'ELS';
    this.externalField = 'compositeAccountNumber';
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
    this.calloutResponse = (AssetFinanceELSCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetFinanceELSCalloutResponse.class
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
    List<AssetFinanceELSModel> accounts = new List<AssetFinanceELSModel>();
    String customerId;
    Set<String> customerIdSet = new Set<String>();
    Map<String, String> customerNameMap = new Map<String, String>();

    if (calloutResponse == null) {
      return result;
    }
    accounts = ((AssetFinanceELSCalloutResponse) this.calloutResponse).accounts;
    for (AssetFinanceELSModel fa : accounts) {
      customerIdSet.add(
        getCustomerId(this.parentId, fa.compositeAccountNumber)
      );
    }
    customerNameMap = getCustomerName(customerIdSet);
    for (AssetFinanceELSModel fa : accounts) {
      customerId = getCustomerId(this.parentId, fa.compositeAccountNumber);
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => fa.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(fa.compositeAccountNumber),
        'AccountStatus' => fa.status,
        'AccountName' => customerNameMap.get(customerId) ?? null,
        'ProductCode' => fa.productCode,
        'AccountNumber' => fa.accountNumber,
        'Balance' => fa.accountBalance,
        'AmountInArrears' => fa.arrearsAmount,
        'Expires' => formatDate(fa.expiryDate),
        'BalloonAmount' => fa.balloonAmount,
        'Amount' => fa.repaymentAmount,
        'LoanTermMonth' => fa.loanTermMonth,
        'LoanTerm' => fa.loanTermYear,
        'IntRate' => fa.interestRate,
        'Limit' => fa.accountLimit,
        'ProductName' => fa.description,
        'TotalNumberOfRepayments' => fa.loanRepaymentFrequency
      };
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description get the customer Id
   * @param parentId of the customer
   * @param compositeAccountNumber External id of account
   * @return String Customer Id
   */
  @testVisible
  private String getCustomerId(String parentId, String compositeAccountNumber) {
    return String.isBlank(parentId)
      ? 'CAP-CIS_' + compositeAccountNumber.substringBefore('-')
      : parentId;
  }
}
