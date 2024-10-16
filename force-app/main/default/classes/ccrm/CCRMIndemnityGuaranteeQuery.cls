/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Indemnity Guarantee external query class
 */
public with sharing class CCRMIndemnityGuaranteeQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description  IG Model class
   */
  public class CCRMIndemnityGuaranteeModel extends CCRMFinancialAccountModelBase {
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
    public List<CCRMIndemnityGuaranteeModel> accounts;
  }
  /**
   * @description class constructor
   */
  public CCRMIndemnityGuaranteeQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (IndemnityGuaranteeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      IndemnityGuaranteeCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to IG accounts
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMIndemnityGuaranteeModel> accounts = new List<CCRMIndemnityGuaranteeModel>();

    if (this.calloutResponse == null) {
      return result;
    }

    accounts = ((IndemnityGuaranteeCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = this.calloutResponse.nextPageId;

    for (CCRMIndemnityGuaranteeModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = String.isNotBlank(fa.compositeAccountNumber)
        ? fa.compositeAccountNumber.substringBefore('-')
        : null;
      row.put('CustomerId', 'CAP-CIS_' + customerId);
      row.put('ExternalId', fa.compositeAccountNumber);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() + '/' + fa.compositeAccountNumber
      );
      row.put('AccountNumber', formatAccountNumber(fa.accountNumber));
      row.put('AccountName', getCustomerName(customerId));
      row.put('AccountStatus', fa.status);
      row.put('Limit', fa.accountLimit);
      row.put('ProductCode', fa.productCode);
      row.put('OLLType', fa.ollType);
      row.put('OpenedDate', formatDate(fa.openedDate));
      row.put('ExpiryDate', formatDate(fa.expiryDate));
      row.put('UndrawnBalance', fa.undrawnBalance);
      row.put(
        'SecurityType',
        SECURITY_TYPES.containsKey(fa.securityType)
          ? SECURITY_TYPES.get(fa.securityType)
          : fa.securityType
      );
      result.queryResult.add(row);
    }
    return result;
  }
}
