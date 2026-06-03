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
  private class AFAMBITCreditLineModel extends FinancialAccountEntities.FinancialAccountCalloutResponse {
    public String compositeCreditLineId;
    public Date dateOpened;
    public Date expiryDate;
    public String cpid;
    public Decimal undrawnBalance;
    public String productName;
    public Decimal liabilityLimit;
    public String facilityExpiryType;
    public String creditLineId;
  }

  /**
   * @description Asset Finance AMBIT API callout response
   */
  public class AFAMBITCreditLineCalloutResponse extends FinancialAccountEntities.FinancialAccountCalloutResponse {
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
    if (
      this.queryMode == QueryModeEnum.RECORD_DETAIL && this.isCACHECustomer()
    ) {
      this.calloutResponse = (AFAMBITCreditLineModel) CalloutModel.deserialize(
        responseBody,
        AFAMBITCreditLineModel.class
      );
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

    if (calloutResponse == null) {
      return result;
    }

    if (
      this.queryMode == QueryModeEnum.RECORD_DETAIL && this.isCACHECustomer()
    ) {
      AFAMBITCreditLineModel creditLine = ((AFAMBITCreditLineModel) calloutResponse);
      result.externalRecords.add(createExternalRec(creditLine));
    } else {
      //Pass pagination token
      result.queryMoreToken = ((AFAMBITCreditLineCalloutResponse) this.calloutResponse)
        .nextPageId;
      List<AFAMBITCreditLineModel> creditLines = ((AFAMBITCreditLineCalloutResponse) calloutResponse)
        .creditLines ?? new List<AFAMBITCreditLineModel>();
      for (AFAMBITCreditLineModel creditLine : creditLines) {
        result.externalRecords.add(createExternalRec(creditLine));
      }
    }
    return result;
  }
  private Map<String, Object> createExternalRec(
    AFAMBITCreditLineModel creditLine
  ) {
    String externalId = getExternalId(creditLine);
    Map<String, Object> row = new Map<String, Object>{
      this.parentField => this.parentId,
      'ExternalId' => externalId,
      'DisplayUrl' => getDisplayUrl(externalId),
      'AccountStatus' => creditLine.status,
      'AccountName' => creditLine.accountName,
      'AccountNumber' => creditLine.accountNumber ?? creditLine.creditLineId,
      'Limit' => creditLine.liabilityLimit,
      'OpenedDate' => creditLine.dateOpened,
      'Expires' => creditLine.expiryDate,
      'SI' => creditLine.cpid,
      'UndrawnBalance' => creditLine.undrawnBalance,
      'FacilityExpiryType' => creditLine.facilityExpiryType,
      'ProductName' => creditLine.productName
    };
    return row;
  }
  private String getExternalId(AFAMBITCreditLineModel creditLine) {
    if (String.isNotBlank(this.externalId)) {
      return this.externalId;
    }
    if (String.isNotBlank(creditLine.compositeCreditLineId)) {
      return this.customerSourceSystem + '_' + creditLine.compositeCreditLineId;
    }
    return this.parentId + '-' + creditLine.creditLineId;
  }
}
