/**
 * @author Hitesh
 * @since  09/2024
 * @group Platform
 * @description Facility Query external query class
 */
public with sharing class FacilitiesExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Facility Model class
   */
  public class FacilityModel extends FinancialAccountModelBase {
    public String compositeFacilityId;
    public Integer ollSequence;
    public String ollType;
    public Integer ollAmount;
    public DateTime ollExpiryDate;
    public Integer tpmiNumber;
    public Integer tpmiSubNumber;
    public String productName;
    public String sourceSystemStatus;
  }

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    'ACT' => 'ACT - Active',
    'DEL' => 'DEL - Deleted',
    'INA' => 'INA - Inactive'
  };

  /**
   * @description Facility callout response
   */
  public class FacilityCalloutResponse extends FinancialAccountCalloutResponse {
    public List<FacilityModel> facilities;
  }

  /**
   * @description constructor
   */
  public FacilitiesExternalQuery() {
    this.productCategory = 'oll';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'FACILITIES';
    this.externalField = 'compositeFacilityId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse transformed api response
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (FacilityCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FacilityCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Facility records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      FacilityModel fac : ((FacilityCalloutResponse) this.calloutResponse)
        .facilities
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => fac.compositeFacilityId,
        'DisplayUrl' => getDisplayUrl(
          fac.productCode + '-' + fac.accountNumber
        ),
        this.parentField => this.parentId,
        'Sequence' => fac.ollSequence,
        'Type' => fac.ollType,
        'Amount' => fac.ollAmount,
        'ExpiryDate' => formatDate(fac.ollExpiryDate),
        'Account_Name' => fac.accountName,
        'Account_Number' => externalQueryHelper.formatAccountNumber(
          fac.accountNumber
        ),
        'Source_System_Status' => MAP_SOURCE_SYSTEM_STATUS.containsKey(
            fac.sourceSystemStatus
          )
          ? MAP_SOURCE_SYSTEM_STATUS.get(fac.sourceSystemStatus)
          : fac.sourceSystemStatus,
        'Product_Name' => fac.productName,
        'TPMI_SAO' => fac.tpmiNumber +
        '-' +
        fac.tpmiSubNumber
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
