/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Inactive Indemnity Guarantee external query class
 */
public with sharing class CCRMInactiveIndemnityGuaranteeQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description IG Model class
   */
  public class CCRMInactiveIndemnityGuaranteeModel extends CCRMFinancialAccountModelBase {
    public String compositeGuaranteesId;
    public String id;
    public String status;
    public DateTime startDate;
    public DateTime expiryDate;
    public Decimal remainingFaceValue;
    public String purpose;
    public String bankGuaranteeType;
  }
  /**
   * @description IG API callout response
   */
  public class IndemnityGuaranteeCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMInactiveIndemnityGuaranteeModel> indemnityGuarantees;
  }
  /**
   * @description class constructor
   */
  public CCRMInactiveIndemnityGuaranteeQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'INACTIVE_GUARANTEES';
    this.externalField = 'compositeGuaranteesId';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (IndemnityGuaranteeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      IndemnityGuaranteeCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to inactive IG records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      CCRMInactiveIndemnityGuaranteeModel guarantee : ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
        .indemnityGuarantees
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', guarantee.compositeGuaranteesId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        guarantee.compositeGuaranteesId
      );
      List<String> values = guarantee.compositeGuaranteesId != null
        ? guarantee.compositeGuaranteesId.split('-')
        : null;
      String parentId = values != null ? values[0] + '-' + values[1] : null;
      row.put(this.parent, parentId);
      row.put('SerialNumber', guarantee.id);
      row.put('Status', guarantee.status);
      row.put('Amount', guarantee.remainingFaceValue);
      row.put('PurposeCode', guarantee.purpose);
      row.put('StartDate', adjustUTCDateTime(guarantee.startDate));
      row.put('ExpiryDate', adjustUTCDateTime(guarantee.expiryDate));
      row.put('Type', guarantee.bankGuaranteeType);
      result.queryResult.add(row);
    }
    return result;
  }
}
