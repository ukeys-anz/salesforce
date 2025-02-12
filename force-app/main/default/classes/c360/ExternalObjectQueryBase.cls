/**
 * @author Ian Huang
 * @since  07/2023
 * @group Platform
 * @description External object external query base class
 * @runTests DepositAccountExternalQueryTest
 */
public abstract with sharing class ExternalObjectQueryBase {
  /**
   * @description External query result wrapper class
   */
  public class ExternalQueryResult {
    public String queryMoreToken;
    public List<Map<String, Object>> externalRecords = new List<Map<String, Object>>();
  }

  /**
   * @description abstract external object callout response class
   */
  public abstract class ExternalObjectCalloutResponse {
  }

  /**
   * @description QueryMode enums for determining type of external query
   * RelatedList - e.g. Related financial accounst for a customer
   * RecordDetail - e.g. Deposit account record detail
   */
  public enum QueryModeEnum {
    RELATED_LIST,
    RECORD_DETAIL
  }

  @testVisible
  protected ExternalObjectCalloutResponse calloutResponse;
  @testVisible
  protected String externalId;
  @testVisible
  protected String externalField;
  @testVisible
  protected String parentId;
  @testVisible
  protected String parentField;
  protected String paginationKey;
  protected Boolean enableServerPagination = false;

  /**
   * @description Main execute method - the orchestration layer
   * @param queryContext DataSource QueryContext
   * @return ExternalQueryResult
   */
  public virtual ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    ExternalQueryResult externalQueryResult;
    QueryModeEnum queryMode = prepareCallout(queryContext);
    this.paginationKey = getPaginationKey(
      queryContext.tableSelection.tableSelected,
      this.parentId
    );
    if (queryMode == QueryModeEnum.RECORD_DETAIL && displayDummyRecord()) {
      externalQueryResult = createDummyExternalRecord(
        this.externalId,
        new Map<String, Object>()
      );
    } else {
      HttpCalloutResponse response = makeCallout(queryMode, queryContext);
      calloutResponse = parseResponse(response.body);
      externalQueryResult = createExternalRecords(calloutResponse);
    }
    return externalQueryResult;
  }

  /**
   * @description Prepare API callout using SF query contenxt paramaters
   * @param queryContext DataSource QueryContext
   * @return QueryModeEnum
   */
  protected virtual QueryModeEnum prepareCallout(
    DataSource.QueryContext queryContext
  ) {
    this.parentField = getParentName(queryContext.TableSelection);
    return parseFilters(this.parentField, queryContext.TableSelection);
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   * @param parentFieldName parent name e.g. CustomerId
   * @param tableSelection DataSource.TableSelection
   * @return QueryModeEnum
   */
  @testVisible
  protected virtual QueryModeEnum parseFilters(
    String parentFieldName,
    DataSource.TableSelection tableSelection
  ) {
    if (primaryFilterIsNotNull(tableSelection)) {
      return parseFields(
        parentFieldName,
        tableSelection.filter.columnName,
        String.valueOf(tableSelection.filter.columnValue)
      );
    } else if (subFiltersIsNotNull(tableSelection)) {
      return parseFields(
        parentFieldName,
        tableSelection.filter.subfilters[0].columnName,
        String.valueOf(tableSelection.filter.subfilters[0].columnValue)
      );
    }
    return null;
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   * @param parentFieldName Parent name e.g. CustomerId
   * @param columnName Filter column name
   * @param columnValue Filter column value
   * @return QueryModeEnum
   */
  private QueryModeEnum parseFields(
    String parentFieldName,
    String columnName,
    String columnValue
  ) {
    if (columnName == 'ExternalId') {
      this.externalId = columnValue;
      return QueryModeEnum.RECORD_DETAIL;
    } else if (columnName == parentFieldName) {
      this.parentId = columnValue;
      return QueryModeEnum.RELATED_LIST;
    }
    return null;
  }

  /**
   * @description virtual Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  protected virtual ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    return null;
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param queryMode QueryMode Enum
   * @param queryContext DataSource.QueryContext
   * @return HttpCalloutResponse
   */
  protected virtual HttpCalloutResponse makeCallout(
    QueryModeEnum queryMode,
    DataSource.QueryContext queryContext
  ) {
    return null;
  }

  /**
   * @description virtual Transform API response to external records
   * @param calloutResponse API CalloutResponse
   * @return ExternalQueryResult - List<Map<String, Object>>
   */
  protected virtual ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    return null;
  }

  /**
   * @description virtual Transform SOQL query response to financial account records
   * @return ExternalQueryResult - List<Map<String, Object>>
   */
  protected virtual ExternalQueryResult createExternalRecordsBySOQLQuery() {
    return null;
  }

  /**
   * @description Determine whether to display a dummy FA record, returns false by default
   * @return displaying a dummy external record? true / false
   **/
  @TestVisible
  protected virtual Boolean displayDummyRecord() {
    return false;
  }

  /**
   * @description Create a Dummy external object record
   * @param externalId External Id
   * @param row Additional dummy values from derived class
   * @return dummy financial account record
   **/
  @TestVisible
  protected virtual ExternalObjectQueryBase.ExternalQueryResult createDummyExternalRecord(
    String externalId,
    Map<String, Object> row
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    row.put('ExternalId', externalId);
    row.put('AdditionalInformation', 'No further information available');
    result.ExternalRecords.add(row);
    return result;
  }

  /**
   * @description get parent object name
   * @param tableSelection DataSource.TableSelection
   * @return String parent object name
   */
  @testVisible
  protected virtual String getParentName(
    DataSource.TableSelection tableSelection
  ) {
    if (primaryFilterIsNotNull(tableSelection)) {
      if (tableSelection.filter.columnName != 'ExternalId') {
        return tableSelection.filter.columnName;
      }
    } else if (subFiltersIsNotNull(tableSelection)) {
      if (tableSelection.filter.subfilters[0].columnName != 'ExternalId') {
        return tableSelection.filter.subfilters[0].columnName;
      }
    }
    return '';
  }

  /**
   * @description get UTC datetime from GMT+10 datetime
   * @param localTime localTime
   * @return DateTime UTC datetime
   */
  protected DateTime adjustUTCDateTime(DateTime localTime) {
    if (localTime != null) {
      //Get desired time zone
      TimeZone tz = TimeZone.getTimeZone('Australia/Sydney');
      //getOffset returns the value in ms, we need it in seconds.
      DateTime utcTime = localTime.addSeconds(
        -1 * tz.getOffset(localTime) / 1000
      );
      return utcTime;
    }
    return localTime;
  }

  /**
   * @description Format DateTime as DateTime
   * @param dateTimeParam DateTime param
   * @return String formatted datetime
   */
  protected String formatDateTime(DateTime dateTimeParam) {
    if (dateTimeParam == null) {
      return null;
    }
    return dateTimeParam.format('dd/MM/yyyy hh:mm a', 'GMT');
  }

  /**
   * @description Format DateTime as Date
   * @param dateTimeParam DateTime param
   * @return String formatted date
   */
  protected String formatDate(DateTime dateTimeParam) {
    if (dateTimeParam == null) {
      return null;
    }
    return dateTimeParam.format('dd/MM/yyyy', 'GMT');
  }

  /**
   * @description Format index as sequence string
   * @param indexParam Integer param
   * @return String four digit index
   */
  @TestVisible
  protected String formatSequence(Integer indexParam) {
    if (indexParam == null) {
      return null;
    }
    return String.valueOf(indexParam).leftPad(4, '0');
  }

  /**
   * @description get external record DisplayUrl
   * @param  appendUrl Financial account record
   * @return String DisplayUrl
   */
  protected String getDisplayUrl(String appendUrl) {
    return URL.getOrgDomainUrl().toExternalForm() + '/' + appendUrl;
  }

  /**
   * @description construct pagination key using user Id-table name-parent Id
   * @param tableName Name of object
   * @param parentId Parent identifier value
   * @return String Unique pagination key
   */
  protected virtual String getPaginationKey(String tableName, String parentId) {
    String key = UserInfo.getUserId() + '-' + tableName + '-' + parentId;
    return generateHash(key);
  }

  /**
   * @description generate Hashed string
   * @param key string value to be hashed
   * @return String
   */
  protected String generateHash(String key) {
    Blob data = Blob.valueOf(key);
    Blob hash = Crypto.generateDigest('SHA-256', data);
    String hashedString = EncodingUtil.convertToHex(hash);
    return hashedString;
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   * @param tableSelection DataSource.TableSelection
   * @return Boolean is primary filter empty
   */
  private Boolean primaryFilterIsNotNull(
    DataSource.TableSelection tableSelection
  ) {
    return tableSelection.filter != null &&
      tableSelection.filter.columnName != null;
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   * @param tableSelection DataSource.TableSelection
   * @return Boolean is sub filters empty
   */
  private Boolean subFiltersIsNotNull(
    DataSource.TableSelection tableSelection
  ) {
    return tableSelection.filter != null &&
      tableSelection.filter.subfilters != null &&
      tableSelection.filter.subfilters[0].columnName != null;
  }

  /**
   * @description get unique sequence
   * @param  index index
   * @return String sequence
   */
  @testVisible
  protected String getSequence(Integer index) {
    return index.toString().leftPad(4, '0');
  }
}
