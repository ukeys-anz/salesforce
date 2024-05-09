/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Credit Card external query class
 */
public with sharing class CCRMCreditCardQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  public class CCRMCreditCardModel extends CCRMFinancialAccountModelBase {
    public Decimal interestRate;
    public String controllingPostId;
    public DateTime openDate;
    public Decimal cashAdvanceRate;
    public Integer interestFreeDays;
  }

  /**
   * @description CreditCard API callout response
   */
  public class CreditCardCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMCreditCardModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMCreditCardQuery() {
    this.productCategory = 'credit-card';
    this.productTypes = new Set<String>{ 'CAP-CIS:PCA' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
    this.useProductCodeFromFinancialAccount = true;
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (CreditCardCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CreditCardCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to CreditCard records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMCreditCardModel> accounts = new List<CCRMCreditCardModel>();

    if (this.calloutResponse != null) {
      accounts = ((CreditCardCalloutResponse) this.calloutResponse).accounts;
    }

    for (CCRMCreditCardModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      row.put('CustomerId', customerId);
      row.put('ExternalId', getExternalId(fa));
      row.put('DisplayUrl', getDisplayUrl(fa));

      row.put('AccountName', fa.accountName);
      row.put('AccountNumber', formatAccountNumber(fa.accountNumber));
      row.put('AccountStatus', fa.status);
      row.put('Balance', fa.accountBalance);
      row.put('ProductCode', fa.productCode);
      row.put('OpenedDate', formatDate(fa.openDate));
      row.put('InterestRate', fa.interestRate);
      row.put('CreditLimit', fa.accountLimit);
      row.put('CashAdvanceRate', fa.cashAdvanceRate);
      row.put('InterestFreeDays', fa.interestFreeDays);
      result.queryResult.add(row);
    }

    return result;
  }
}
