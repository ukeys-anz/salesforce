/**
 * @author Hitesh
 * @since  09/2024
 * @group Platform
 * @description Transaction History external query class
 */
public with sharing class TransactionHistoryExternalQuery extends CAPFinancialAccountQueryBase {
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
   * @description abstract CAP FinancialAccount Summary callout response class
   */
  public virtual class TransactionHistoryCalloutRequest extends ExternalObjectQueryBase.ExternalObjectCalloutRequestBase {
    public String productCategory;
    public QueryModeEnum queryMode;
    /**
     * @description abstract FinancialAccount callout response class
     * @param queryContext DataSource QueryContext
     * @param queryMode Query Mode Enum
     * @param crw calloutRequestWrapper having startdate and endDate
     */
    public TransactionHistoryCalloutRequest(
      DataSource.QueryContext queryContext,
      QueryModeEnum queryMode,
      CalloutRequestWrapper crw
    ) {
      super(queryContext, queryMode);
      this.productCategory = crw.productCategory;
      this.payload = new FinancialAccountEntities.FinancialAccountPayload();
      if (this.isSummaryRequest()) {
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .offSet = String.valueOf(queryContext.offSet);
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .pageSize = String.valueOf(queryContext.maxResults);
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .fieldSet = crw.fieldSet;
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .accountNumber = crw.accountNumber;
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .startDate = crw.startDate;
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .endDate = crw.endDate;
      }
    }

    public override String getEndpoint() {
      String host = Label.Financial_Account_Endpoint;
      return host + 'transactions';
    }
  }

  /**
   * @description DepositAccount API callout response
   */
  private class TransactionHistoryCalloutResponse extends FinancialAccountEntities.FinancialAccountCalloutResponse {
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
        'PostDate' => th.postedDate.dateGmt(),
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
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @param tableSelection DataSource.TableSelection
   * @return calloutRequest
   **/
  @testVisible
  protected override ExternalObjectCalloutRequestBase prepareCallout(
    DataSource.QueryContext queryContext,
    DataSource.TableSelection tableSelection
  ) {
    Date startDate = extractDate(queryContext, 'GREATER_THAN_OR_EQUAL_TO');
    Date endDate = extractDate(queryContext, 'LESS_THAN_OR_EQUAL_TO');

    if (isDateOlderThan7Years(startDate)) {
      throw new CommonUtil.GenericUserException(
        'Selected date range exceeds the 7-year allowable limit. Please refine your selection.'
      );
    }
    if (isDurationMoreThan2Years(startDate, endDate)) {
      throw new CommonUtil.GenericUserException(
        'The selected date range exceeds the 2-year limit per search. Please adjust your date range and perform multiple searches to cover the full period (maximum of 7 years), with each search covering no more than 2 years.'
      );
    }
    String accountNumber;
    ExternalObjectCalloutRequestBase calloutRequest = super.prepareCallout(
      queryContext,
      queryContext.TableSelection
    );
    if (calloutRequest.isSummaryRequest()) {
      accountNumber = this.parentId.right(
        this.parentId.length() - this.parentId.indexOf('|') - 1
      );
    }
    this.productCategory = 'transactions';
    CalloutRequestWrapper crw = new CalloutRequestWrapper();
    crw.startDate = String.valueOf(startDate);
    crw.endDate = String.valueOf(endDate);
    crw.productCategory = this.productCategory;
    crw.fieldSet = this.fieldSet;
    crw.accountNumber = accountNumber;
    TransactionHistoryCalloutRequest transCalloutRequest = new TransactionHistoryCalloutRequest(
      queryContext,
      this.queryMode,
      crw
    );
    this.accountNumbers = new Set<String>{ accountNumber };
    return transCalloutRequest;
  }

  /**
   * @description Main execute method - the orchestration layer
   * @param queryContext DataSource QueryContext
   * @return ExternalQueryResult
   */
  public override ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    this.tableName = queryContext.TableSelection.tableSelected;
    ExternalObjectCalloutRequestBase calloutRequest = prepareCallout(
      queryContext,
      queryContext.TableSelection
    );
    this.paginationKey = getPaginationKey(
      queryContext.tableSelection.tableSelected,
      this.parentId
    );
    ExternalObjectCalloutResponse calloutResponse;
    if (this.queryMode == QueryModeEnum.RECORD_DETAIL && displayDummyRecord()) {
      return createDummyExternalRecord(
        this.externalId,
        new Map<String, Object>()
      );
    }
    if (!this.accountNumbers.isEmpty()) {
      HttpCalloutResponse response = makeCallout(calloutRequest);
      calloutResponse = parseResponse(response.body);
    }
    return createExternalRecords(calloutResponse);
  }

  /**
   * @description Filter Date from QueryContext
   * @param ctx DataSource QueryContext
   * @param dateType DateType to extract
   * @return Datevalue
   **/
  private static Date extractDate(
    DataSource.QueryContext ctx,
    String dateType
  ) {
    String stringContext = String.valueOf(ctx);
    Integer typeIndex = stringContext.indexOf('type=' + dateType);
    if (typeIndex < 0) {
      return null;
    }
    Integer cvIndex = stringContext.lastIndexOf('columnValue=', typeIndex);
    Integer start = cvIndex + 'columnValue='.length();
    String dateStr = stringContext.substring(start, start + 10);
    return Date.valueOf(dateStr);
  }

  /**
   * @description checks if given date is older then 7 years
   * @param dateValue provided date
   * @return boolean
   **/
  public static Boolean isDateOlderThan7Years(Date dateValue) {
    Date sevenYearsAgo = Date.today().addYears(-7);
    if (dateValue != null && dateValue < sevenYearsAgo) {
      return true;
    }
    return false;
  }

  /**
   * @description checks if given dates have difference more then 2 years
   * @param startDate startingDate
   * @param endDate endingDate
   * @return boolean
   **/
  public static Boolean isDurationMoreThan2Years(Date startDate, Date endDate) {
    if (startDate == null && endDate == null) {
      return false;
    }
    if (startDate == null && endDate != null) {
      return false;
    }
    Date startPlus2 = startDate.addYears(2);
    if (startDate != null && endDate == null) {
      return Date.today() > startPlus2;
    }

    return endDate > startPlus2;
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   * @param parentFieldName parent name e.g. CustomerId
   * @param tableSelection DataSource.TableSelection
   * @return QueryModeEnum
   */
  @testVisible
  protected override QueryModeEnum parseFilters(
    String parentFieldName,
    DataSource.TableSelection tableSelection
  ) {
    Set<String> subFiltersToSkip = new Set<String>{ 'PostDate' };
    if (primaryFilterIsNotNull(tableSelection)) {
      return parseFields(
        parentFieldName,
        tableSelection.filter.columnName,
        String.valueOf(tableSelection.filter.columnValue)
      );
    } else if (subFiltersIsNotNull(tableSelection.filter)) {
      DataSource.Filter match = findFirstMatchingFilter(
        tableSelection.filter,
        subFiltersToSkip
      );
      if (match != null) {
        return parseFields(
          parentFieldName,
          match.columnName,
          String.valueOf(match.columnValue)
        );
      }
    }
    return null;
  }

  /**
   * @description find first filter skipping names from set
   * @param root root filter
   * @param skipNames set of string to skip filters
   * @return datasource filter
   */
  private DataSource.Filter findFirstMatchingFilter(
    DataSource.Filter root,
    Set<String> skipNames
  ) {
    if (root == null) {
      return null;
    }
    if (root.columnName != null && !skipNames.contains(root.columnName)) {
      return root;
    }
    if (root.subfilters != null) {
      for (DataSource.Filter child : root.subfilters) {
        DataSource.Filter match = findFirstMatchingFilter(child, skipNames);
        if (match != null) {
          return match;
        }
      }
    }
    return null;
  }

  /**
   * @description get parent object name
   * @param tableSelection DataSource.TableSelection
   * @return String parent object name
   */
  @testVisible
  protected override String getParentName(
    DataSource.TableSelection tableSelection
  ) {
    Set<String> subFiltersToSkip = new Set<String>{ 'PostDate' };
    if (primaryFilterIsNotNull(tableSelection)) {
      if (tableSelection.filter.columnName != 'ExternalId') {
        return tableSelection.filter.columnName;
      }
    } else if (subFiltersIsNotNull(tableSelection.filter)) {
      DataSource.Filter match = findFirstMatchingFilter(
        tableSelection.filter,
        subFiltersToSkip
      );

      if (match.columnName != 'ExternalId') {
        return match.columnName;
      }
    }
    return '';
  }

  /**
   * @description recursively verify if subfliter is null or not
   * @param filter Datasource filter
   * @return Boolean
   */
  private Boolean subFiltersIsNotNull(DataSource.Filter filter) {
    if (filter == null) {
      return false;
    }
    if (filter.columnName != null) {
      return true;
    }
    if (filter.subfilters != null) {
      for (DataSource.Filter sf : filter.subfilters) {
        if (subFiltersIsNotNull(sf)) {
          return true;
        }
      }
    }
    return false;
  }

  /**
   * @description Wrapper class for CalloutRequest
   */
  private class CalloutRequestWrapper {
    public String startDate;
    public String endDate;
    public String productCategory;
    public String fieldSet;
    public String accountNumber;
  }
}
