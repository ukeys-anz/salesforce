/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description LinkedAccount external query class
 */
public with sharing class CCRMLinkedAccountQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description LinkedAccount Model class
   */
  public class LinkedAccountModel extends CCRMFinancialAccountModelBase {
    public String relateCode;
    public String accountNumber;
    public String productCode;
    public String compositeLinkedAccountId;
  }

  /**
   * @description LinkedAccount callout response
   */
  public class LinkedAccountResponse extends FinancialAccountCalloutResponse {
    public List<LinkedAccountModel> relatedAccounts;
  }

  /**
   * @description constructor
   */
  public CCRMLinkedAccountQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'LINKED_ACCOUNTS';
    this.externalField = 'compositeLinkedAccountId';
    this.productCategory = 'ptf';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (LinkedAccountResponse) CalloutModel.deserialize(
      responseBody,
      LinkedAccountResponse.class
    );
  }

  /**
   * @description Transform API response to LinkedAccount records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      LinkedAccountModel acct : ((LinkedAccountResponse) this.calloutResponse)
        .relatedAccounts
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', acct.compositeLinkedAccountId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        acct.compositeLinkedAccountId
      );
      row.put(this.parent, this.parentId);
      row.put('AccountNumber', formatAccountNumber(acct.accountNumber));
      row.put('Code', acct.relateCode);
      row.put('ProductCode', acct.productCode);
      result.queryResult.add(row);
    }
    return result;
  }
}
