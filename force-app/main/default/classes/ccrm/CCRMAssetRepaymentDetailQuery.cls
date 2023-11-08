/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Repayment Detail external query class
 */
public with sharing class CCRMAssetRepaymentDetailQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Repayment Detail Model class
   */
  public class RepaymentDetailModel extends CCRMFinancialAccountModelBase {
    public String accountNumber;
    public String type;
    public String frequency;
    public String amount;
    public DateTime startDate;
    public Integer numberOfRepayments;
    public String compositeAssetRepaymentId;
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
  public CCRMAssetRepaymentDetailQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'REPAYMENTS';
    this.externalField = 'compositeAssetRepaymentId';
    this.assetFinanceType = 'AMBIT';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (RepaymentDetailCalloutResponse) JSON.deserialize(
      responseBody,
      RepaymentDetailCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Asset Detail records
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
      row.put('ExternalId', repay.compositeAssetRepaymentId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        repay.compositeAssetRepaymentId
      );
      List<String> values = repay.compositeAssetRepaymentId != null
        ? repay.compositeAssetRepaymentId.split('-')
        : null;
      String parentId = values != null
        ? values[0] + '-' + values[1] + '-' + values[2]
        : null;
      row.put(this.parent, parentId);
      row.put('RepaymentAccountNumber', repay.accountNumber);
      row.put('RepaymentType', repay.type);
      row.put('Frequency', repay.frequency);
      row.put('Amount', repay.amount);
      row.put('TotalNumberOfRepayments', repay.numberOfRepayments);
      row.put('StartDate', adjustUTCDateTime(repay.startDate));
      result.queryResult.add(row);
    }
    return result;
  }
}
