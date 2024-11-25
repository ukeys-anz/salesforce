/**
 * @author Ian Huang
 * @since  10/2024
 * @group Platform
 * @description Foreign Exchange Deal external query class
 * @runTests ForeignExchangeDealExternalQueryTest
 */
public with sharing class ForeignExchangeDealExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Foreign Exchange Deal business Model class
   */
  @testVisible
  private class ForeignExchangeDealModel extends FinancialAccountModelBase {
    public String compositeAccountNumber;
    public Decimal askPrice;
    public String askPriceCurrency;
    public Decimal bidPrice;
    public String bidPriceCurrency;
    public DateTime dealDate;
    public String dealNumber;
    public DateTime valueDate;
  }

  /**
   * @description ForeignExchange API callout response
   */
  @testVisible
  private class ForeignExchangeDealCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<ForeignExchangeDealModel> accounts;
  }

  /**
   * @description constructor
   */
  public ForeignExchangeDealExternalQuery() {
    this.productCategory = 'fx-deals';
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
    this.calloutResponse = (ForeignExchangeDealCalloutResponse) CalloutModel.deserialize(
      responseBody,
      ForeignExchangeDealCalloutResponse.class
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
    List<ForeignExchangeDealModel> accounts = new List<ForeignExchangeDealModel>();
    if (calloutResponse == null) {
      return result;
    }

    for (
      ForeignExchangeDealModel fa : ((ForeignExchangeDealCalloutResponse) calloutResponse)
        .accounts
    ) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => fa.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(fa.compositeAccountNumber),
        'AskAmount' => fa.askPrice,
        'AskCurrency' => fa.askPriceCurrency,
        'BidAmount' => fa.bidPrice,
        'BidCurrency' => fa.bidPriceCurrency,
        'DealNumber' => fa.dealNumber,
        'DealDate' => fa.dealDate,
        'ValueDate' => fa.ValueDate
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
