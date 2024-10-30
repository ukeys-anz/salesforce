/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Commercial Bill external query class
 * @runTests CommercialBillExternalQueryTest
 */
public with sharing class CommercialBillExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description CommercialBill business model class
   */
  public class CommercialBillModel extends FinancialAccountModelBase {
    public String compositeAccountNumber;
    public String sequenceNo;
    public String status;
    public DateTime openedDate;
    public DateTime expires;
    public String purposeCode;
    public Integer loanTermYears;
    public Integer loanTermMonths;
    public Decimal facilityAccountLimit;
    public Decimal capAccountLimit;
    public String description;
    public string productCode;
    public string subProductCode;
    public string purpose;
  }

  /**
   * @description Commecial Bill API callout response
   */
  public class CommercialBillCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<CommercialBillModel> accounts;
  }
  /**
   * @description Class constructor
   */
  public CommercialBillExternalQuery() {
    this.productCategory = 'commercial-bills';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
    this.enableServerPagination = true;
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse transformed respoonse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isNotBlank(responseBody)) {
      this.calloutResponse = (CommercialBillCalloutResponse) CalloutModel.deserialize(
        responseBody,
        CommercialBillCalloutResponse.class
      );
    }
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to MerchantFacility accounts
   * @param calloutResponse API response from source system
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
    List<CommercialBillModel> accounts = ((CommercialBillCalloutResponse) calloutResponse)
      .accounts;
    for (CommercialBillModel fa : accounts) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => fa.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(fa.compositeAccountNumber),
        'AccountNumber' => fa.accountNumber,
        'AccountStatus' => fa.status,
        'SequenceNo' => fa.sequenceNo,
        'OpeningDate' => formatDate(fa.openedDate),
        'Expires' => formatDate(fa.expires),
        'PurposeCode' => fa.purposeCode,
        'LoanTermYears' => fa.loanTermYears,
        'LoanTermMonths' => fa.loanTermMonths,
        'FacilityLimit' => fa.facilityAccountLimit,
        'CAPAccountLimit' => fa.capAccountLimit,
        'ProductName' => fa.description,
        'ProductCode' => fa.productCode,
        'SubProductCode' => fa.subProductCode,
        'Purpose' => fa.purpose
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
