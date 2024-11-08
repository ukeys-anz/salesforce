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
    public String compositeAssetRepaymentId;
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
    this.externalField = 'compositeAssetRepaymentId';
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
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    for (
      AFAMBITRepaymentModel repay : ((AFAMBITRepaymentCalloutResponse) this.calloutResponse)
        .repayments
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => repay.compositeAssetRepaymentId,
        'DisplayUrl' => getDisplayUrl(repay.compositeAssetRepaymentId),
        this.parentField => this.parentId,
        'RepaymentAccountNumber' => repay.accountNumber,
        'Amount' => repay.amount,
        'TotalNumberOfRepayments' => repay.numberOfRepayments
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
