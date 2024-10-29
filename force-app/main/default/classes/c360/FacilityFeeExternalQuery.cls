/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Facility Fee external query class
 */
public with sharing class FacilityFeeExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Facility Fee class
   */
  public class FacilityFeeModel extends FinancialAccountModelBase {
    public String feeType;
    public String feeFrequency;
    public String feeChargeAccount;
    public Decimal feePercentage;
    public Decimal feeAmount;
    public String compositeFacilityFeeId;
    public DateTime nextDueDate;
  }

  /**
   * @description Facility Fee callout response
   */
  public class FacilityFeeCalloutResponse extends FinancialAccountCalloutResponse {
    public List<FacilityFeeModel> facilityFees;
  }

  /**
   * @description constructor
   */
  public FacilityFeeExternalQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'FACILITY_FEES';
    this.externalField = 'compositeFacilityFeeId';
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

    this.calloutResponse = (FacilityFeeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FacilityFeeCalloutResponse.class
    );

    return this.calloutResponse;
  }

  /**
   * @description Transform API response to facility fee records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (this.calloutResponse == null) {
      return result;
    }
    Integer index = 0;
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      FacilityFeeModel fee : ((FacilityFeeCalloutResponse) this.calloutResponse)
        .facilityFees
    ) {
      index++;

      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => fee.compositeFacilityFeeId,
        'DisplayUrl' => getDisplayUrl(fee.compositeFacilityFeeId),
        this.parentField => this.parentId,
        'FeeType' => fee.feeType,
        'Frequency' => fee.feeFrequency,
        'FeeChargeAccount' => externalQueryHelper.formatAccountNumber(
          fee.feeChargeAccount
        ),
        'FacilityLimitFee' => fee.feePercentage,
        'FacilityLimitFeeAmount' => fee.feeAmount,
        'NextDueDate' => formatDate(fee.nextDueDate),
        'Seq' => index
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
