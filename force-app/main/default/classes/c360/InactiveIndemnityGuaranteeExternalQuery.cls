/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Inactive Indemnity Guarantee external query class
 */
public with sharing class InactiveIndemnityGuaranteeExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description IG Model class
   */
  public class InactiveIndemnityGuaranteeModel extends FinancialAccountModelBase {
    public String compositeGuaranteesId;
    public String id;
    public String status;
    public DateTime startDate;
    public DateTime expiryDate;
    public Decimal amount;
    public String purpose;
    public String bankGuaranteeType;
  }
  /**
   * @description IG API callout response
   */
  public class IndemnityGuaranteeCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<InactiveIndemnityGuaranteeModel> indemnityGuarantees;
  }
  /**
   * @description class constructor
   */
  public InactiveIndemnityGuaranteeExternalQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'INACTIVE_GUARANTEES';
    this.externalField = 'compositeGuaranteesId';
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

    this.calloutResponse = (IndemnityGuaranteeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      IndemnityGuaranteeCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to inactive IG records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    if (this.calloutResponse == null) {
      return result;
    }

    for (
      InactiveIndemnityGuaranteeModel guarantee : ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
        .indemnityGuarantees
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => guarantee.compositeGuaranteesId,
        'DisplayUrl' => getDisplayUrl(guarantee.compositeGuaranteesId),
        this.parentField => this.parentId,
        'SerialNumber' => guarantee.id,
        'Status' => guarantee.status,
        'Amount' => guarantee.amount,
        'PurposeCode' => guarantee.purpose,
        'StartDate' => formatDate(guarantee.startDate),
        'ExpiryDate' => formatDate(guarantee.expiryDate),
        'Type' => guarantee.bankGuaranteeType
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
