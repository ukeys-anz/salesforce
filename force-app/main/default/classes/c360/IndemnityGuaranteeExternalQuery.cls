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
    List<IndemnityGuaranteeModel> accounts = new List<IndemnityGuaranteeModel>();
    String customerId;
    Set<String> customerIdSet = new Set<String>();
    Map<String, String> customerNameMap = new Map<String, String>();

    if (this.calloutResponse == null) {
      return result;
    }
    accounts = ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
      .nextPageId;

    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (IndemnityGuaranteeModel fa : accounts) {
      customerIdSet.add(
        getCustomerId(this.parentId, fa.compositeAccountNumber)
      );
    }
    customerNameMap = getCustomerName(customerIdSet);
    for (IndemnityGuaranteeModel fa : accounts) {
      customerId = getCustomerId(this.parentId, fa.compositeAccountNumber);
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => customerId,
        'ExternalId' => fa.compositeAccountNumber,
        'AccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.accountNumber
        ),
        'AccountName' => customerNameMap.get(customerId) ?? null,
        'DisplayUrl' => getDisplayUrl(fa.compositeAccountNumber),
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

  /**
   * @description get the customer Id
   * @param parentId of the customer
   * @param compositeAccountNumber External id of account
   * @return String Customer Id
   */
  @testVisible
  private String getCustomerId(String parentId, String compositeAccountNumber) {
    return String.isBlank(parentId)
      ? 'CAP-CIS_' + compositeAccountNumber.substringBefore('-')
      : parentId;
  }
}
