/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Other Limits And Liabilities external query class
 */
public with sharing class CCRMOtherLimitsAndLiabilitiesQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description OLL account Model class
   */
  public class CCRMOtherLimitsAndLiabilitiesModel extends CCRMFinancialAccountModelBase {
    public String ollType;
    public String branch;
    public DateTime openingDate;
    public String controllingPostId;
  }
  /**
   * @description OLL API callout response
   */
  public class CCRMOLLCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMOtherLimitsAndLiabilitiesModel> accounts;
  }
  /**
   * @description constructor
   */
  public CCRMOtherLimitsAndLiabilitiesQuery() {
    this.productCategory = 'oll';
    this.productTypes = new Set<String>{ 'CAP-CIS:OLL' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (CCRMOLLCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CCRMOLLCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to OLL Account records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;

    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMOtherLimitsAndLiabilitiesModel> accounts = new List<CCRMOtherLimitsAndLiabilitiesModel>();

    if (this.calloutResponse != null) {
      accounts = ((CCRMOLLCalloutResponse) this.calloutResponse).accounts;
    }

    for (CCRMOtherLimitsAndLiabilitiesModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      row.put('CustomerId', customerId);
      row.put('ExternalId', getExternalId(fa));
      row.put('DisplayUrl', getDisplayUrl(fa));
      row.put('Relationship', getAccountRelationship(fa.accountNumber));

      row.put('AccountName', fa.accountName);
      row.put('AccountNumber', formatAccountNumber(fa.accountNumber));
      row.put('AccountStatus', fa.status);
      row.put('OLLType', fa.ollType);
      row.put('Branch', fa.branch);
      row.put('DateOpened', formatDate(fa.openingDate));
      row.put('CPID', fa.controllingPostId);
      row.put('Limit', fa.accountLimit);
      result.queryResult.add(row);
    }
    return result;
  }
}
