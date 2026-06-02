/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description AFAMBITRepayment external query class
 */
public with sharing class AFAMBITRepaymentExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Repayment Model class
   */
  public class AFAMBITRepaymentModel extends FinancialAccountModelBase {
    public String amount;
    public Integer numberOfRepayments;
    public String compositeRepaymentId;
    public String sequence;
    public String externalId;
    public String contractNumber;
  }

  /**
   * @description Repayment Detail callout response
   */
  public class AFAMBITRepaymentCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AFAMBITRepaymentModel> repayments;
  }

  /**
   * @description constructor
   */
  public AFAMBITRepaymentExternalQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'REPAYMENTS';
    this.externalField = 'compositeRepaymentId';
    this.assetFinanceType = 'AMBIT';
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
    this.calloutResponse = (AFAMBITRepaymentCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AFAMBITRepaymentCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to repayment records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    Integer index = 0;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    List<AFAMBITRepaymentModel> repayments = ((AFAMBITRepaymentCalloutResponse) this.calloutResponse)
      .repayments ?? new List<AFAMBITRepaymentModel>();
    for (AFAMBITRepaymentModel repay : repayments) {
      index++;
      String externalId = getExternalId(repay);
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => externalId,
        'DisplayUrl' => getDisplayUrl(externalId),
        'Sequence' => repay.sequence ?? getSequence(index),
        this.parentField => this.parentId,
        'RepaymentAccountNumber' => repay.accountNumber ?? repay.contractNumber,
        'Amount' => repay.amount,
        'TotalNumberOfRepayments' => repay.numberOfRepayments
      };
      result.externalRecords.add(row);
    }
    return result;
  }

  private String getExternalId(AFAMBITRepaymentModel repay) {
    if (String.isNotBlank(this.externalId)) {
      return this.externalId;
    }
    if (String.isNotBlank(repay.compositeRepaymentId)) {
      return this.customerSourceSystem + '_' + repay.compositeRepaymentId;
    }
    return this.parentId + '-' + repay.sequence;
  }
}
