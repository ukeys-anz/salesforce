/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Active Indemnity Guarantee external query class
 */
public with sharing class ActiveIndemnityGuaranteeExternalQuery extends FinancialAccountQueryBase {
  public static Map<String, String> typeMap = new Map<String, String>{
    'STD' => 'Std',
    'NON_STD' => 'Non-Std'
  };
  /**
   * @description  IG Model class
   */
  public class ActiveIndemnityGuaranteeModel extends FinancialAccountModelBase {
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
    public String customerId;
    public List<ActiveIndemnityGuaranteeModel> indemnityGuarantees;
  }
  /**
   * @description class constructor
   */
  public ActiveIndemnityGuaranteeExternalQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'ACTIVE_GUARANTEES';
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
   * @description Transform API response to active  IG records
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
    List<ActiveIndemnityGuaranteeModel> indemnityGuarantees = ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
      .indemnityGuarantees;

    for (ActiveIndemnityGuaranteeModel guarantee : indemnityGuarantees) {
      if (String.isBlank(guarantee.compositeGuaranteesId)) {
        return result;
      }
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
        'Type' => typeMap.get(guarantee.bankGuaranteeType) ??
          guarantee.bankGuaranteeType
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
