/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Facility Query external query class
 */
public with sharing class CCRMFacilitiesQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Facility Model class
   */
  public class FacilityModel extends CCRMFinancialAccountModelBase {
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
  public CCRMFacilitiesQuery() {
    this.productCategory = 'oll';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'FACILITIES';
    this.externalField = 'compositeFacilityId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  @testVisible
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (FacilityCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FacilityCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Facility records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      FacilityModel fac : ((FacilityCalloutResponse) this.calloutResponse)
        .facilities
    ) {
      row = new Map<String, Object>{
        'ExternalId' => fac.compositeFacilityId,
        'DisplayUrl' => getDisplayUrl(fac),
        this.parent => this.parentId,
        'Sequence' => fac.ollSequence,
        'Type' => fac.ollType,
        'Amount' => fac.ollAmount,
        'ExpiryDate' => formatDate(fac.ollExpiryDate),
        'Account_Name' => fac.accountName,
        'Account_Number' => formatAccountNumber(fac.accountNumber),
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
      result.queryResult.add(row);
    }
    return result;
  }
}
