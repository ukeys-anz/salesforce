/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Finance ELS external query class
 */
public with sharing class CCRMAssetFinanceELSQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Asset Finance ELS Model class
   */
  public class CCRMAssetFinanceELSModel extends CCRMFinancialAccountModelBase {
    public String compositeAccountNumber;
    public String tradingName;
    public String merchantId;
    public String merchantTerminals;
    public String legalName;
    public Decimal interestRate;
    public Decimal accountBalance;
    public Decimal arrearsAmount;
    public DateTime expiryDate;
    public Decimal balloonAmount;
    public Decimal repaymentAmount;
    public String loanTerm;
    public String loanRepaymentFrequency;
    public String interestType;
  }

  /**
   * @description Asset Finance ELS API callout response
   */
  public class AssetFinanceELSCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<CCRMAssetFinanceELSModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMAssetFinanceELSQuery() {
    this.productCategory = 'asset-finance';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.assetFinanceType = 'ELS';
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
    this.calloutResponse = (AssetFinanceELSCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetFinanceELSCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to AssetFinance accounts
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;

    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMAssetFinanceELSModel> accounts = new List<CCRMAssetFinanceELSModel>();

    if (this.calloutResponse == null) {
      return result;
    }

    accounts = ((AssetFinanceELSCalloutResponse) this.calloutResponse).accounts;
    //Pass pagination token
    result.queryMoreToken = this.calloutResponse.nextPageId;

    for (CCRMAssetFinanceELSModel fa : accounts) {
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
      row.put('AccountStatus', fa.status);
      row.put('AccountName', fa.accountName);
      row.put('ProductCode', fa.productCode);
      row.put('AccountNumber', fa.accountNumber);
      row.put('IntRate', fa.interestRate);
      row.put('Balance', fa.accountBalance);
      row.put('AmountInArrears', fa.arrearsAmount);
      row.put('Expires', formatDate(fa.expiryDate));
      row.put('BalloonAmount', fa.balloonAmount);
      row.put('Amount', fa.repaymentAmount);
      row.put('LoanTerm', fa.loanTerm);
      row.put('TotalNumberOfRepayments', fa.loanRepaymentFrequency);
      row.put('Limit', fa.accountLimit);
      result.queryResult.add(row);
    }
    return result;
  }
}
