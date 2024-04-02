/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description CB Repayment Detail external query class
 */
public with sharing class CCRMCommercialBillRepaymentDetailQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Repayment Detail Model class
   */
  public class RepaymentDetailModel extends CCRMFinancialAccountModelBase {
    public String compositeAccountNumber;
    public String compositeAccountRepaymentId;
    public Decimal scheduledBillReductionAmount;
    public DateTime scheduledStartDate;
    public DateTime scheduledEndDate;
  }

  /**
   * @description Repayment Detail callout response
   */
  public class RepaymentDetailCalloutResponse extends FinancialAccountCalloutResponse {
    public List<RepaymentDetailModel> repayments;
  }

  /**
   * @description constructor
   */
  public CCRMCommercialBillRepaymentDetailQuery() {
    this.productCategory = 'commercial-bills';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'ACCOUNT_REPAYMENTS';
    this.externalField = 'compositeAccountRepaymentId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (RepaymentDetailCalloutResponse) CalloutModel.deserialize(
      responseBody,
      RepaymentDetailCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Repayment records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      RepaymentDetailModel repay : ((RepaymentDetailCalloutResponse) this.calloutResponse)
        .repayments
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', repay.compositeAccountRepaymentId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        repay.compositeAccountRepaymentId
      );
      List<String> values = repay.compositeAccountRepaymentId != null
        ? repay.compositeAccountRepaymentId.split('-')
        : null;
      String parentId = values != null ? values[0] + '-' + values[1] : null;
      row.put(this.parent, parentId);
      row.put(
        'ScheduledBillReductionAmount',
        repay.scheduledBillReductionAmount
      );
      row.put('ScheduledStartDate', formatDate(repay.scheduledStartDate));
      row.put('ScheduledEndDate', formatDate(repay.scheduledEndDate));
      result.queryResult.add(row);
    }
    return result;
  }
}
