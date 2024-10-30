/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Indemnity Guarantee external query class
 */
public with sharing class IndemnityGuaranteeExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description  IG Model class
   */
  public class IndemnityGuaranteeModel extends FinancialAccountModelBase {
    public String compositeAccountNumber;
    public String accountNumber;
    public String ollType;
    public DateTime openedDate;
    public DateTime expiryDate;
    public Decimal undrawnBalance;
    public String securityType;
    public String productCode;
  }
  private static final Map<String, String> SECURITY_TYPES = new Map<String, String>{
    '1' => '1 - Registered Mortgage',
    '2' => '2 - Cash Secured',
    '3' => '3 - Partially Secured',
    '4' => '4 - Other',
    '97' => '97 - Incorrect Record',
    '98' => '98 - Missing Record '
  };
  /**
   * @description IG API callout response
   */
  public class IndemnityGuaranteeCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<IndemnityGuaranteeModel> accounts;
  }
  /**
   * @description class constructor
   */
  public IndemnityGuaranteeExternalQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
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
   * @description Transform API response to IG accounts
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (this.calloutResponse == null) {
      return result;
    }
    List<IndemnityGuaranteeModel> accounts = ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
      .nextPageId;
      
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (IndemnityGuaranteeModel fa : accounts) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => fa.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(fa.compositeAccountNumber),
        'AccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.accountNumber
        ),
        'AccountName' => getCustomerName(this.parentId),
        'AccountStatus' => fa.status,
        'Limit' => fa.accountLimit,
        'ProductCode' => fa.productCode,
        'OLLType' => fa.ollType,
        'OpenedDate' => formatDate(fa.openedDate),
        'ExpiryDate' => formatDate(fa.expiryDate),
        'UndrawnBalance' => fa.undrawnBalance,
        'SecurityType' => SECURITY_TYPES.containsKey(fa.securityType)
          ? SECURITY_TYPES.get(fa.securityType)
          : fa.securityType
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
