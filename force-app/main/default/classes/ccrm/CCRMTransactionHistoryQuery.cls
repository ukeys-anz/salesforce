/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Transaction History external query class
 */
public with sharing class CCRMTransactionHistoryQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Transaction History Model class
   */
  private class CCRMTransactionHistoryModel extends CCRMFinancialAccountModelBase {
    public DateTime transactionDate;
    public String transactionId;
    public DateTime postedDate;
    public String transactionType;
    public String description;
    public Decimal amount;
    public String source;
    public Decimal runningBalance;
    public String transactionTime;
    public String compositeId;
  }

  /**
   * @description DepositAccount API callout response
   */
  private class TransactionHistoryCalloutResponse extends FinancialAccountCalloutResponse {
    public List<CCRMTransactionHistoryModel> transactions;
  }

  /**
   * @description constructor
   */
  public CCRMTransactionHistoryQuery() {
    this.productCategory = 'transactions';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'compositeId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (TransactionHistoryCalloutResponse) JSON.deserialize(
      responseBody,
      TransactionHistoryCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Transaction History records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMTransactionHistoryModel> transactions = new List<CCRMTransactionHistoryModel>();

    if (this.calloutResponse != null) {
      transactions = ((TransactionHistoryCalloutResponse) this.calloutResponse)
          .transactions != null
        ? ((TransactionHistoryCalloutResponse) this.calloutResponse)
            .transactions
        : new List<CCRMTransactionHistoryModel>();
      //Pass pagination token
      result.queryMoreToken = this.calloutResponse.nextPageId;
    }

    for (CCRMTransactionHistoryModel th : transactions) {
      row = new Map<String, Object>();
      row.put('ExternalId', th.compositeId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        th.compositeId
      );
      row.put('Amount', th.amount);
      row.put(this.parent, this.parentId);
      row.put('Description', th.description);
      row.put('EffectiveDate', adjustUTCDateTime(th.transactionDate));
      row.put('PostDate', adjustUTCDateTime(th.postedDate));
      row.put('RunningBalance', th.runningBalance);
      row.put('Source', th.source);
      row.put('Time', th.transactionTime);
      row.put('Type', th.transactionType);
      result.queryResult.add(row);
    }
    return result;
  }
}
