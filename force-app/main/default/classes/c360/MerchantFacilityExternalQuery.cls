/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Merchant Facility external query class
 * @runTests MerchantFacilityExternalQueryTest
 */
public with sharing class MerchantFacilityExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Merchant facility Model class
   */
  public class MerchantFacilityModel extends FinancialAccountModelBase {
    public String tradingName;
    public String merchantId;
    public String merchantTerminals;
    public String legalName;
    public String compositeAccountNumber;
    public Integer turnOverLast3Months;
    public Integer turnOverLast6Months;
    public Integer turnOverLast12Months;
    public String accountNumber;
    public String capCustomerId;
  }

  /**
   * @description MerchantFacility API callout response
   */
  public class MerchantFacilityCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<MerchantFacilityModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public MerchantFacilityExternalQuery() {
    this.productCategory = 'merchant-facility';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
    this.enableServerPagination = true;
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
    this.calloutResponse = (MerchantFacilityCalloutResponse) CalloutModel.deserialize(
      responseBody,
      MerchantFacilityCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to DepositAccount records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (this.calloutResponse == null) {
      return result;
    }
    List<MerchantFacilityModel> accounts = ((MerchantFacilityCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = ((MerchantFacilityCalloutResponse) this.calloutResponse)
      .nextPageId;

    for (MerchantFacilityModel fa : accounts) {
      if (String.isBlank(fa.compositeAccountNumber)) {
        return result;
      }

      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => fa.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(fa.compositeAccountNumber),
        'AccountStatus' => fa.status,
        'TradingName' => fa.tradingName,
        'MerchantID' => fa.merchantId,
        'NoOfTerminals' => fa.merchantTerminals,
        'LegalName' => fa.legalName,
        'TurnoverAmountLast6Months' => fa.turnOverLast6Months,
        'TurnoverAmountLast3Months' => fa.turnOverLast3Months,
        'TurnoverAmountLast12Months' => fa.turnOverLast12Months,
        'AccountNumber' => fa.accountNumber,
        'CAPCustomerID' => fa.capCustomerId
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
