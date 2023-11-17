/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Merchant Facility external query class
 */
public with sharing class CCRMMerchantFacilityQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Merchant facility Model class
   */
  public class CCRMMerchantFacilityModel extends CCRMFinancialAccountModelBase {
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
    public List<CCRMMerchantFacilityModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMMerchantFacilityQuery() {
    this.productCategory = 'merchant-facility';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (MerchantFacilityCalloutResponse) JSON.deserialize(
      responseBody,
      MerchantFacilityCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to MerchantFacility accounts
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMMerchantFacilityModel> accounts = new List<CCRMMerchantFacilityModel>();

    if (this.calloutResponse == null) {
      return result;
    }

    accounts = ((MerchantFacilityCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = this.calloutResponse.nextPageId;

    for (CCRMMerchantFacilityModel fa : accounts) {
      if (String.isBlank(fa.compositeAccountNumber)) {
        return result;
      }
      row = new Map<String, Object>();
      customerId = String.isNotBlank(fa.compositeAccountNumber)
        ? fa.compositeAccountNumber.substringBefore('-')
        : null;
      row.put('CustomerId', 'CAP-CIS_' + customerId);
      row.put('ExternalId', fa.compositeAccountNumber);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fa.compositeAccountNumber
      );
      row.put('AccountStatus', fa.status);
      row.put('TradingName', fa.tradingName);
      row.put('MerchantID', fa.merchantId);
      row.put('NoOfTerminals', fa.merchantTerminals);
      row.put('LegalName', fa.legalName);
      row.put('TurnoverAmountLast6Months', fa.turnOverLast6Months);
      row.put('TurnoverAmountLast3Months', fa.turnOverLast3Months);
      row.put('TurnoverAmountLast12Months', fa.turnOverLast12Months);
      row.put('AccountNumber', fa.accountNumber);
      row.put('CAPCustomerID', fa.capCustomerId);
      result.queryResult.add(row);
    }
    return result;
  }
}
