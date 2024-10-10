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
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public virtual override CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult queryResult = new CCRMFinancialAccountQueryBase.ExternalQueryResult();
    super.callExecuteOfQueryBase(queryContext);
    prepareCallout();

    if (displayDummayFinancialAccount(this.externalId, this.parentId)) {
      queryResult = createDummyFinancialAccounts(this.externalId);
      return queryResult;
    }
    HttpCalloutResponse response = makeCallout();
    parseResponse(response.body);
    queryResult = createFinancialAccounts();
    return queryResult;
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (TransactionHistoryCalloutResponse) CalloutModel.deserialize(
      responseBody,
      TransactionHistoryCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Transaction History records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMTransactionHistoryModel> transactions = new List<CCRMTransactionHistoryModel>();
    final Map<String, String> mapOfTypeTranslation = new Map<String, String>{
      'D' => 'D - Debit',
      'C' => 'C - Credit'
    };

    if (this.calloutResponse == null) {
      return result;
    }

    transactions = ((TransactionHistoryCalloutResponse) this.calloutResponse)
        .transactions != null
      ? ((TransactionHistoryCalloutResponse) this.calloutResponse).transactions
      : new List<CCRMTransactionHistoryModel>();
    //Pass pagination token
    result.queryMoreToken = this.calloutResponse.nextPageId;

    for (CCRMTransactionHistoryModel th : transactions) {
      String transactionType = (mapOfTypeTranslation.containsKey(
          th.transactionType
        )
        ? mapOfTypeTranslation.get(th.transactionType)
        : th.transactionType);

      row = new Map<String, Object>{
        'ExternalId' => th.compositeId +
        '|' +
        formatDate(th.postedDate),
        'DisplayUrl' => URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        th.compositeId,
        'Amount' => th.amount,
        this.parent => this.parentId,
        'Description' => th.description,
        'EffectiveDate' => formatDate(th.transactionDate),
        'PostDate' => formatDate(th.postedDate),
        'RunningBalance' => th.runningBalance,
        'Source' => formatSource(th.source),
        'Time' => th.transactionTime,
        'Type' => transactionType
      };
      result.queryResult.add(row);
    }
    return result;
  }

  /**
   * @description Create Dummy FA record
   * @param externalId Format RSV-929490053-0-11-0001
   * @return dummy FA record. externalId Id will be formatted from RSV-929490053-0-11-0001 to RSV-929490053
   **/
  @TestVisible
  private CCRMExternalObjectQueryBase.ExternalQueryResult createDummyFinancialAccounts(
    String externalId
  ) {
    String accountNumber = externalId.indexOf('-', 5) != -1
      ? externalId.subString(0, externalId.indexOf('-', 5))
      : externalId;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row = new Map<String, Object>{
      'ExternalId' => accountNumber,
      'AdditionalInformation' => 'No further information available',
      'PostDate' => externalId.substringAfterLast('|')
    };
    result.queryResult.add(row);
    return result;
  }

  /**
   * @description Return true if detail API is needed. ExternalId : True => Detail API Call
   * @param externalId externalId value
   * @param parentId parentId value
   * @return boolean true/false
   */
  @TestVisible
  private static Boolean displayDummayFinancialAccount(
    String externalId,
    String parentId
  ) {
    return !String.isEmpty(externalId) && String.isEmpty(parentId);
  }

  /**
   * @description Capialize first Character of words seperated by underscore, and replace underscore by space.
   * @param source Souce Name
   * @return string. Sample: heLLo_WoRlD_new => Hello World New
   */
  @TestVisible
  private static String formatSource(String source) {
    if (String.isBlank(source)) {
      return '';
    }
    List<String> sourceSplit = source.toLowerCase().split('_');
    for (integer i = 0; i < sourceSplit.size(); i++) {
      sourceSplit[i] = sourceSplit[i].capitalize();
    }
    return String.join(sourceSplit, ' ');
  }
}
