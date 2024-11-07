/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Commercial Bill Fee  external query class
 * @runTests CommercialBillFeeExternalQueryTest
 */
public with sharing class CommercialBillFeeExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description FeeTable Model class
   */
  public class FeeTableModel extends FinancialAccountModelBase {
    public String compositeAccountFeeId;
    public String name;
    public Decimal amount;
    public Decimal rate;
    public String frequency;
  }

  /**
   * @description Fee Detail callout response
   */
  public class FeeTableCalloutResponse extends FinancialAccountCalloutResponse {
    public List<FeeTableModel> fees;
  }

  /**
   * @description constructor
   */
  public CommercialBillFeeExternalQuery() {
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'ACCOUNT_FEES';
    this.externalField = 'compositeAccountFeeId';
    this.productCategory = 'commercial-bills';
  }
  final Map<String, String> feeFreqMap = new Map<String, String>{
    'MONTH1' => 'Monthly',
    'MONTH3' => 'Quarterly',
    'MONTH6' => 'Half Yearly',
    'YEAR1' => 'Yearly',
    '1M' => 'Monthly',
    '1Y' => 'Yearly',
    '2M' => 'Bi-Monthly',
    '3M' => 'Quarterly',
    '4M' => 'Four Monthly',
    '5M' => 'Five Monthly',
    '6M' => 'Half Yearly',
    'At Rollover' => 'At Rollover'
  };
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
      this.calloutResponse = (FeeTableCalloutResponse) CalloutModel.deserialize(
        responseBody,
        FeeTableCalloutResponse.class
      );
    }
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Fee Table records
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
      FeeTableModel fee : ((FeeTableCalloutResponse) this.calloutResponse).fees
    ) {
      index++;
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => fee.compositeAccountFeeId,
        'DisplayUrl' => getDisplayUrl(fee.compositeAccountFeeId),
        this.parentField => this.parentId,
        'FeeName' => fee.name,
        'FeeAmount' => fee.amount,
        'FeeFrequency' => feeFreqMap.containsKey(fee.frequency)
          ? feeFreqMap.get(fee.frequency)
          : fee.frequency,
        'FeeRate' => fee.rate,
        'Seq' => index
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
