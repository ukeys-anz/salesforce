/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Guarantee Fee Detail external query class
 */
public with sharing class GuaranteeFeeDetailExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Guarantee Fee Model class
   */
  public class GuaranteeFeeModel extends FinancialAccountModelBase {
    public String compositeGuaranteesFeeId;
    public String feeType;
    public Decimal feePercentage;
    public Decimal feeAmount;
    public String feeFrequency;
    public String feeChargeAccount;
    public DateTime nextDueDate;
  }
  /**
   * @description Guarantee Fee API callout response
   */
  public class GuaranteeFeeCalloutResponse extends FinancialAccountCalloutResponse {
    public List<GuaranteeFeeModel> guaranteesFees;
  }
  /**
   * @description class constructor
   */
  public GuaranteeFeeDetailExternalQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'GUARANTEES_FEES';
    this.externalField = 'compositeGuaranteesFeeId';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse transformed response
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isNotBlank(responseBody)) {
      this.calloutResponse = (GuaranteeFeeCalloutResponse) CalloutModel.deserialize(
        responseBody,
        GuaranteeFeeCalloutResponse.class
      );
    }
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Guarantee Fee records
   * @param calloutResponse API response from source system
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    Integer index = 0;
    for (
      GuaranteeFeeModel fee : ((GuaranteeFeeCalloutResponse) this.calloutResponse)
        .guaranteesFees
    ) {
      index++;
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => fee.compositeGuaranteesFeeId,
        'DisplayUrl' => getDisplayUrl(fee.compositeGuaranteesFeeId),
        this.parentField => this.parentId,
        'FeeType' => fee.feeType,
        'FeePercent' => fee.feePercentage,
        'Amount' => fee.feeAmount,
        'Frequency' => fee.feeFrequency,
        'FeeChargeAccount' => fee.feeChargeAccount,
        'NextDueDate' => formatDate(fee.nextDueDate),
        'Seq' => index
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
