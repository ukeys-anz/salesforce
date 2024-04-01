/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Finance AMBIT external query class
 */
public with sharing class CCRMAssetFinanceAMBITQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Asset Finance AMBIT Model class
   */
  public class CCRMAssetFinanceAMBITModel extends CCRMFinancialAccountModelBase {
    public String contractNumber;
    public String compositeAccountNumber;
    public String productCode;
    public Decimal originalAmountFinanced;
    public DateTime openedDate;
    public Decimal balloonAmount;
    public Decimal interestRate;
    public String interestType;
    public String loanTermYears;
    public String loanTermMonths;
    public DateTime expiryDate;
    public String govtGuarantee;
    public Decimal amountInArrears;
    public String securityIndicator;
    public Decimal undrawnBalance;
  }

  /**
   * @description Asset Finance AMBIT API callout response
   */
  public class AssetFinanceAMBITCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<CCRMAssetFinanceAMBITModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMAssetFinanceAMBITQuery() {
    this.productCategory = 'asset-finance';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.assetFinanceType = 'AMBIT';
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
    this.calloutResponse = (AssetFinanceAMBITCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetFinanceAMBITCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to AMBIT accounts
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;

    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMAssetFinanceAMBITModel> accounts = new List<CCRMAssetFinanceAMBITModel>();

    if (this.calloutResponse == null) {
      return result;
    }

    accounts = ((AssetFinanceAMBITCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = this.calloutResponse.nextPageId;

    for (CCRMAssetFinanceAMBITModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = String.isNotBlank(fa.compositeAccountNumber)
        ? fa.compositeAccountNumber.substringBefore('-')
        : null;
      row.put('CustomerId', 'CAP-CIS_' + customerId);
      row.put('ExternalId', fa.compositeAccountNumber);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fa.compositeAccountNumber
      );
      row.put('AccountStatus', fa.status);
      row.put('AccountName', fa.accountName);
      row.put('ProductCode', fa.productCode);
      row.put('AccountNumber', fa.contractNumber);
      row.put('Balance', fa.accountBalance);
      row.put('Limit', fa.accountLimit);
      row.put('OriginalAmountFinanced', fa.originalAmountFinanced);
      row.put('OpenedDate', formatDate(fa.openedDate));
      row.put('BalloonPayments', fa.balloonAmount);
      row.put('IntRate', fa.interestRate);
      row.put('IntType', fa.interestType);
      row.put('LoanTermMonths', fa.loanTermMonths);
      row.put('LoanTermYears', fa.loanTermYears);
      row.put('Expires', formatDate(fa.expiryDate));
      row.put('GovernmentGuarantee', fa.govtGuarantee == 'YES' ? true : false);
      row.put('AmountInArrears', fa.amountInArrears);
      row.put('SI', fa.securityIndicator);
      row.put('UndrawnBalance', fa.undrawnBalance);
      result.queryResult.add(row);
    }
    return result;
  }
}
