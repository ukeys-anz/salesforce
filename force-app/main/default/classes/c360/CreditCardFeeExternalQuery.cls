/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group Platform
 * @description Credit Card Fee Table external query class
 */
public with sharing class CreditCardFeeExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description FeeTable Model class
   */
  @testVisible
  private class FeeTableModel extends FinancialAccountModelBase {
    private String compositeFeeId;
    private String feeType;
    private Decimal feeAmount;
  }

  /**
   * @description Fee Detail callout response
   */
  @testVisible
  private class FeeTableCalloutResponse extends FinancialAccountCalloutResponse {
    @testVisible
    private List<FeeTableModel> fees;
  }

  /**
   * @description constructor
   */
  public CreditCardFeeExternalQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'FEES';
    this.externalField = 'compositeFeeId';
    this.productCategory = 'credit-card';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (FeeTableCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FeeTableCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Fee Table records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse ExternalObjectCalloutResponse
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    for (FeeTableModel fee : ((FeeTableCalloutResponse) calloutResponse).fees) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => fee.compositeFeeId,
        'DisplayUrl' => getDisplayUrl(fee.compositeFeeId),
        this.parentField => this.parentId,
        'FeeType' => fee.feeType,
        'FeeAmount' => fee.feeAmount
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
