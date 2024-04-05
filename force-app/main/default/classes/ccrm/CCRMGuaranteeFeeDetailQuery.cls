/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Guarantee Fee Detail external query class
 */
public with sharing class CCRMGuaranteeFeeDetailQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Guarantee Fee Model class
   */
  public class GuaranteeFeeModel extends CCRMFinancialAccountModelBase {
    public String compositeGuaranteesFeeId;
    public String feeType;
    public Decimal feePercentage;
    public Decimal feeAmount;
    public String feeFrequency;
    public String feeChargeAccount;
    public DateTime nextDueDate;
  }
  /**
   * @description Guarantee Fee API callout response
   */
  public class GuaranteeFeeCalloutResponse extends FinancialAccountCalloutResponse {
    public List<GuaranteeFeeModel> guaranteesFees;
  }
  /**
   * @description class constructor
   */
  public CCRMGuaranteeFeeDetailQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'GUARANTEES_FEES';
    this.externalField = 'compositeGuaranteesFeeId';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (GuaranteeFeeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      GuaranteeFeeCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Guarantee Fee records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      GuaranteeFeeModel fee : ((GuaranteeFeeCalloutResponse) this.calloutResponse)
        .guaranteesFees
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', fee.compositeGuaranteesFeeId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fee.compositeGuaranteesFeeId
      );
      List<String> values = fee.compositeGuaranteesFeeId != null
        ? fee.compositeGuaranteesFeeId.split('-')
        : null;
      String parentId = values != null
        ? values[0] + '-' + values[1] + '-' + values[2]
        : null;
      row.put(this.parent, parentId);
      row.put('FeeType', fee.feeType);
      row.put('FeePercent', fee.feePercentage);
      row.put('Amount', fee.feeAmount);
      row.put('Frequency', fee.feeFrequency);
      row.put('FeeChargeAccount', fee.feeChargeAccount);
      row.put('NextDueDate', adjustUTCDateTime(fee.nextDueDate));
      result.queryResult.add(row);
    }
    return result;
  }
}
