/**
 * @author Ian Huang
 * @since  10/2024
 * @group Platform
 * @description Foreign Exchange external query class
 * @runTests ForeignExchangeExternalQueryTest
 */
public with sharing class ForeignExchangeExternalQuery extends FinancialAccountQueryBase {
  private static Map<String, String> statusMap = new Map<String, String>{
    'Z' => 'Active',
    '*' => 'Closed'
  };

  /**
   * @description Foreign Exchange business Model class
   */
  @testVisible
  private class ForeignExchangeModel extends FinancialAccountModelBase {
    public String compositeAccountNumber;
    public String accountNumber;
    public Decimal balanceAmount;
    public String currencyCode;
    public Decimal interestRate;
    public String midanzCustId;
    public String productCode;
    public String productDescription;
    public String status;
  }

  /**
   * @description ForeignExchange API callout response
   */
  @testVisible
  private class ForeignExchangeCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<ForeignExchangeModel> accounts;
  }

  /**
   * @description constructor
   */
  public ForeignExchangeExternalQuery() {
    this.productCategory = 'foreign-exchange';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
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
    this.calloutResponse = (ForeignExchangeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      ForeignExchangeCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to (ForeignExchange records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    List<ForeignExchangeModel> accounts = new List<ForeignExchangeModel>();
    if (calloutResponse == null) {
      return result;
    }

    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      ForeignExchangeModel fa : ((ForeignExchangeCalloutResponse) calloutResponse)
        .accounts
    ) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => fa.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(fa.productCode + '-' + fa.accountNumber),
        'AccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.accountNumber
        ),
        'Currency' => fa.currencyCode,
        'Balance' => fa.balanceAmount,
        'InterestRate' => fa.interestRate,
        'MidANZCustomer' => fa.midanzCustId,
        'ProductCode' => fa.productCode,
        'ProductName' => fa.productDescription,
        'SourceSystemStatus' => statusMap.get(fa.status) ?? fa.status
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
