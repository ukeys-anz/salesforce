/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Commercial Bill Fee  external query class
 */
public with sharing class CCRMCommercialBillFeeQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description FeeTable Model class
   */
  public class FeeTableModel extends CCRMFinancialAccountModelBase {
    public String compositeAccountFeeId;
    public String name;
    public Decimal amount;
    public Decimal rate;
    public String frequency;
  }

  /**
   * @description Fee Detail callout response
   */
  public class FeeTableCalloutResponse extends FinancialAccountCalloutResponse {
    public List<FeeTableModel> fees;
  }

  /**
   * @description constructor
   */
  public CCRMCommercialBillFeeQuery() {
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'ACCOUNT_FEES';
    this.externalField = 'compositeAccountFeeId';
    this.productCategory = 'commercial-bills';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (FeeTableCalloutResponse) JSON.deserialize(
      responseBody,
      FeeTableCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Fee Table records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      FeeTableModel fee : ((FeeTableCalloutResponse) this.calloutResponse).fees
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', fee.compositeAccountFeeId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fee.compositeAccountFeeId
      );
      row.put(this.parent, this.parentId);
      row.put('FeeName', fee.name);
      row.put('FeeAmount', fee.amount);
      row.put('FeeFrequency', fee.frequency);
      row.put('FeeRate', fee.rate);
      result.queryResult.add(row);
    }
    return result;
  }
}
