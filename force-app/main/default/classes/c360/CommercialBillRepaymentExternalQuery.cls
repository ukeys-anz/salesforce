/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description CB Repayment Detail external query class
 * @runTests CommercialBillRepaymentExternalQueryTest
 */
public with sharing class CommercialBillRepaymentExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Repayment Detail Model class
   */
  public class RepaymentDetailModel extends FinancialAccountModelBase {
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
  public CommercialBillRepaymentExternalQuery() {
    this.productCategory = 'commercial-bills';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'ACCOUNT_REPAYMENTS';
    this.externalField = 'compositeAccountRepaymentId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse transformed response
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isNotBlank(responseBody)) {
      this.calloutResponse = (RepaymentDetailCalloutResponse) CalloutModel.deserialize(
        responseBody,
        RepaymentDetailCalloutResponse.class
      );
    }
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Repayment records
   * @param calloutResponse API response from source system
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    Integer index = 1;
    for (
      RepaymentDetailModel repay : ((RepaymentDetailCalloutResponse) this.calloutResponse)
        .repayments
    ) {
      Map<String, Object> row = new Map<String, Object>{
        this.externalField => repay.compositeAccountRepaymentId,
        'DisplayUrl' => getDisplayUrl(repay.compositeAccountRepaymentId),
        this.parentField => this.parentId,
        'ScheduledBillReductionAmount' => repay.scheduledBillReductionAmount,
        'ScheduledStartDate' => formatDate(repay.scheduledStartDate),
        'ScheduledEndDate' => formatDate(repay.scheduledEndDate),
        'Seq' => index
      };
      index++;
      result.externalRecords.add(row);
    }
    return result;
  }
}
