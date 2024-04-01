/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Credit Card Fee Table external query class
 */
public with sharing class CCRMCreditCardFeeQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description FeeTable Model class
   */
  public class FeeTableModel extends CCRMFinancialAccountModelBase {
    public String compositeFeeId;
    public String feeType;
    public Decimal feeAmount;
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
  public CCRMCreditCardFeeQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'FEES';
    this.externalField = 'compositeFeeId';
    this.productCategory = 'credit-card';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (FeeTableCalloutResponse) CalloutModel.deserialize(
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
      row.put('ExternalId', fee.compositeFeeId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fee.compositeFeeId
      );
      row.put(this.parent, this.parentId);
      row.put('FeeType', fee.feeType);
      row.put('FeeAmount', fee.feeAmount);
      result.queryResult.add(row);
    }
    return result;
  }
}
