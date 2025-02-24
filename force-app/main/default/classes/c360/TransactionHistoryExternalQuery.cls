/**
 * @author Hitesh
 * @since  09/2024
 * @group Platform
 * @description Transaction History external query class
 */
public with sharing class TransactionHistoryExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Transaction History Model class
   */
  private class TransactionHistoryModel extends FinancialAccountModelBase {
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
    public List<TransactionHistoryModel> transactions;
  }

  /**
   * @description constructor
   */
  public TransactionHistoryExternalQuery() {
    this.productCategory = 'transactions';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'compositeId';
    this.enableServerPagination = true;
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return calloutResponse
   */
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (TransactionHistoryCalloutResponse) CalloutModel.deserialize(
      responseBody,
      TransactionHistoryCalloutResponse.class
    );
    return this.calloutResponse;
  }
  private static final Map<String, String> MPA_OF_TYPE_TRANSLATION = new Map<String, String>{
    'D' => 'D - Debit',
    'C' => 'C - Credit'
  };
  /**
   * @description Transform API response to Transaction History records
   * @param calloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    List<TransactionHistoryModel> transactions = ((TransactionHistoryCalloutResponse) calloutResponse)
        .transactions != null
      ? ((TransactionHistoryCalloutResponse) calloutResponse).transactions
      : new List<TransactionHistoryModel>();

    for (TransactionHistoryModel th : transactions) {
      String transactionType = (MPA_OF_TYPE_TRANSLATION.containsKey(
          th.transactionType
        )
        ? MPA_OF_TYPE_TRANSLATION.get(th.transactionType)
        : th.transactionType);

      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => th.compositeId +
        '|' +
        formatDate(th.postedDate),
        'DisplayUrl' => getDisplayUrl(th.compositeId),
        'Amount' => th.amount,
        this.parentField => this.parentId,
        'Description' => TextUtils.maskDataAnzx(th.description),
        'EffectiveDate' => formatDate(th.transactionDate),
        'PostDate' => formatDate(th.postedDate),
        'RunningBalance' => th.runningBalance,
        'Source' => formatSource(th.source),
        'Time' => th.transactionTime,
        'Type' => transactionType
      };
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description Transform API response to DepositAccount records
   * @param externalId externalId
   * @param row externalRecord row
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createDummyExternalRecord(
    String externalId,
    Map<String, Object> row
  ) {
    String accountNumber = externalId.indexOf('-', 5) != -1
      ? externalId.subString(0, externalId.indexOf('-', 5))
      : externalId;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    row = new Map<String, Object>{
      'ExternalId' => accountNumber,
      'AdditionalInformation' => 'No further information available',
      'PostDate' => externalId.substringAfterLast('|')
    };
    result.externalRecords.add(row);
    return result;
  }

  /**
   * @description Need to display Dummy FA record? return false by default
   * @return true / false
   **/
  @TestVisible
  protected override Boolean displayDummyRecord() {
    return displayDummayFinancialAccount(this.externalId, parentId);
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

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param queryMode QueryMode Enum
   * @param queryContext DataSource QueryContext
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout(
    QueryModeEnum queryMode,
    DataSource.QueryContext queryContext
  ) {
    ARNCService service = new ARNCService();
    ARNCService.FinancialAccountQueryParameters queryParams = new ARNCService.FinancialAccountQueryParameters();
    HttpCalloutResponse response;

    String payload = getPayload(queryContext);
    response = getCAPSummaryAccounts(service, queryParams, payload);
    response = getEBDSummaryAccounts(
      service,
      queryParams,
      payload,
      response,
      queryContext
    );
    response = getDetailAccounts(service, payload, response);

    if (response == null) {
      String errorMessge = String.format(
        'Invalid source system: {0} or query mode: {1}',
        new List<Object>{ this.sourceSystem, queryMode }
      );
      Logger.error(errorMessge);
      Logger.saveLog();
      throw new TypeException(errorMessge);
    }
    return response;
  }
}
