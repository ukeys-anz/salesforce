/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description PTF external query class
 * Suppressing ExcessivePublicCount rule to allow for added callouts
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class CCRMPortfolioOfLoanQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description PTF account Model class
   */
  public class CCRMPortfolioOfLoanAccountModel extends CCRMFinancialAccountModelBase {
    public String subProductCode;
    public DateTime openDate;
    public Decimal undrawnBalance;
    public String purposeCode;
    public String tpmiCode;
    public String sao;
    public String controllingPostId;
    public DateTime maturityDate;
    public Integer loanTermMonth;
    public Integer loanTermYears;
  }
  /**
   * @description PTF API callout response
   */
  public class PortfolioOfLoanCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMPortfolioOfLoanAccountModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMPortfolioOfLoanQuery() {
    this.productCategory = 'ptf';
    this.productTypes = new Set<String>{ 'CAP-CIS:PTF' };
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
    this.calloutResponse = (PortfolioOfLoanCalloutResponse) JSON.deserialize(
      responseBody,
      PortfolioOfLoanCalloutResponse.class
    );
  }
  /**
   * @description Transform API response to PTF account records
   * @return External object rows List<Map<String, Object>>
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMPortfolioOfLoanAccountModel> accounts = new List<CCRMPortfolioOfLoanAccountModel>();
    if (this.calloutResponse != null) {
      accounts = ((PortfolioOfLoanCalloutResponse) this.calloutResponse)
        .accounts;
    }

    for (CCRMPortfolioOfLoanAccountModel fa : accounts) {
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
      row.put('ProductCode', fa.productCode);
      row.put('SubProductCode', fa.subProductCode);
      row.put('LoanTermMonth', fa.loanTermMonth);
      row.put('LoanTermYears', fa.loanTermYears);
      row.put('Expires', adjustUTCDateTime(fa.maturityDate));
      row.put('Limit', fa.accountLimit);
      row.put('DateOpened', adjustUTCDateTime(fa.openDate));
      row.put('UndrawnBalance', fa.undrawnBalance);
      row.put('PurposeCode', fa.purposeCode);
      row.put('TPMI', fa.tpmiCode);
      row.put('SAO', fa.sao);
      row.put('SAO', fa.sao);
      row.put('CPID', fa.controllingPostId);
      result.queryResult.add(row);
    }
    return result;
  }
}
