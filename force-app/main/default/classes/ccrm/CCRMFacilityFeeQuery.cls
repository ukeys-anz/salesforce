/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Facility Fee external query class
 */
public with sharing class CCRMFacilityFeeQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Facility Fee class
   */
  public class FacilityFeeModel extends CCRMFinancialAccountModelBase {
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
  public CCRMFacilityFeeQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'FACILITY_FEES';
    this.externalField = 'compositeFacilityFeeId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  @testVisible
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (FacilityFeeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FacilityFeeCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Asset records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    Integer index = 0;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      FacilityFeeModel fee : ((FacilityFeeCalloutResponse) this.calloutResponse)
        .facilityFees
    ) {
      index++;
      row = new Map<String, Object>();
      row.put('ExternalId', fee.compositeFacilityFeeId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          fee.compositeFacilityFeeId
      );
      List<String> values = fee.compositeFacilityFeeId != null
        ? fee.compositeFacilityFeeId.split('-')
        : null;
      String parentId = values != null ? values[0] + '-' + values[1] : null;
      row.put(this.parent, parentId);
      row.put('FeeType', fee.feeType);
      row.put('Frequency', fee.feeFrequency);
      row.put('FeeChargeAccount', formatAccountNumber(fee.feeChargeAccount));
      row.put('FacilityLimitFee', fee.feePercentage);
      row.put('FacilityLimitFeeAmount', fee.feeAmount);
      row.put('NextDueDate', formatDate(fee.nextDueDate));
      row.put('Seq', index);
      result.queryResult.add(row);
    }
    return result;
  }
}
