/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Asset Finance AMBIT Credit Line external query class
 */
public with sharing class AFAMBITCreditLineExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description wrapper class for response
   */
  @testVisible
  private class AFAMBITCreditLineModel extends FinancialAccountModelBase {
    public String compositeCreditLineId;
    public Date dateOpened;
    public Date expiryDate;
    public String cpid;
    public Decimal undrawnBalance;
    public String productName;
    public Decimal liabilityLimit;
    public String facilityExpiryType;
  }

  /**
   * @description Asset Finance AMBIT API callout response
   */
  public class AFAMBITCreditLineCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<AFAMBITCreditLineModel> creditLines;
  }

  /**
   * @description Class constructor
   */
  public AFAMBITCreditLineExternalQuery() {
    this.productCategory = 'asset-finance';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.assetFinanceType = 'AMBIT';
    this.externalField = 'compositeCreditLineId';
    this.fieldSet = 'CREDIT_LINES';
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
    this.calloutResponse = (AFAMBITCreditLineCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AFAMBITCreditLineCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to AMBIT accounts
   * @param calloutResponse
   * @return ExternalObjectQueryBase.ExternalQueryResult object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    List<AFAMBITCreditLineModel> accounts = new List<AFAMBITCreditLineModel>();

    if (calloutResponse == null) {
      return result;
    }
    accounts = ((AFAMBITCreditLineCalloutResponse) this.calloutResponse)
      .creditLines;

    //Pass pagination token
    result.queryMoreToken = ((AFAMBITCreditLineCalloutResponse) this.calloutResponse)
      .nextPageId;

    for (AFAMBITCreditLineModel af : accounts) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => af.compositeCreditLineId,
        'DisplayUrl' => getDisplayUrl(af.compositeCreditLineId),
        'AccountStatus' => af.status,
        'AccountName' => af.accountName,
        'AccountNumber' => af.accountNumber,
        'Limit' => af.liabilityLimit,
        'OpenedDate' => af.dateOpened,
        'Expires' => af.expiryDate,
        'SI' => af.cpid,
        'UndrawnBalance' => af.undrawnBalance,
        'FacilityExpiryType' => af.facilityExpiryType,
        'ProductName' => af.productName
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
