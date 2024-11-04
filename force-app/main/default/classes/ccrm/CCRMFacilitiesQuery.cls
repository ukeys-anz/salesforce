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
  }

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
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      FacilityModel fac : ((FacilityCalloutResponse) this.calloutResponse)
        .facilities
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', fac.compositeFacilityId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fac.compositeFacilityId
      );
      row.put(this.parent, this.parentId);
      row.put('Sequence', fac.ollSequence);
      row.put('Type', fac.ollType);
      row.put('Amount', fac.ollAmount);
      row.put('ExpiryDate', formatDate(fac.ollExpiryDate));
      row.put('TPMINo', fac.tpmiNumber);
      row.put('TPMISubNo', fac.tpmiSubNumber);
      result.queryResult.add(row);
    }
    return result;
  }
}
