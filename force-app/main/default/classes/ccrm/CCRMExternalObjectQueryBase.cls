/**
 * @author Ian Huang
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description CCRM External object external query base class
 */
public abstract with sharing class CCRMExternalObjectQueryBase {
  /**
   * @description External query result wrapper class
   */
  public class ExternalQueryResult {
    public String queryMoreToken;
    public List<Map<String, Object>> queryResult = new List<Map<String, Object>>();
  }

  protected DataSource.QueryContext queryContext;
  protected DataSource.TableSelection tableSelection;
  protected String externalField;
  @testVisible
  protected String externalId;
  @testVisible
  protected String parentId;
  @testVisible
  protected String parent;
  protected String paginationKey;
  protected Boolean enableServerPagination = false;

  /**
   * @description Main execute method
   * @param queryContext DataSource QueryContext
   * @return ExternalQueryResult
   */
  public virtual ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    this.queryContext = queryContext;
    this.tableSelection = queryContext.TableSelection;
    if (enableServerPagination) {
      paginationKey = constructPaginationKey();
    }
    return null;
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   */
  protected virtual void prepareCallout() {
  }

  /**
   * @description Parse External Id and Customer Id from SF query contenxt paramaters
   * @param parent parent name e.g. CustomerId
   */
  protected virtual void parseFilters(String parent) {
    if (
      this.tableSelection.filter != null &&
      this.tableSelection.filter.columnName != null
    ) {
      if (this.tableSelection.filter.columnName == 'ExternalId') {
        externalId = String.valueOf(this.tableSelection.filter.columnValue);
      } else if (this.tableSelection.filter.columnName == parent) {
        parentId = String.valueOf(this.tableSelection.filter.columnValue);
      }
    } else if (
      this.tableSelection.filter != null &&
      this.tableSelection.filter.subfilters != null &&
      this.tableSelection.filter.subfilters[0].columnName != null
    ) {
      if (this.tableSelection.filter.subfilters[0].columnName == 'ExternalId') {
        externalId = String.valueOf(
          this.tableSelection.filter.subfilters[0].columnValue
        );
      } else if (
        this.tableSelection.filter.subfilters[0].columnName == parent
      ) {
        parentId = String.valueOf(
          this.tableSelection.filter.subfilters[0].columnValue
        );
      }
    }
  }

  /**
   * @description get parent name
   */
  protected virtual void getParent() {
    if (
      this.tableSelection.filter != null &&
      this.tableSelection.filter.columnName != null
    ) {
      if (this.tableSelection.filter.columnName != 'ExternalId') {
        parent = this.tableSelection.filter.columnName;
      }
    } else if (
      this.tableSelection.filter != null &&
      this.tableSelection.filter.subfilters != null &&
      this.tableSelection.filter.subfilters[0].columnName != null
    ) {
      if (this.tableSelection.filter.subfilters[0].columnName != 'ExternalId') {
        parent = this.tableSelection.filter.subfilters[0].columnName;
      }
    }
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param
   * @return HttpCalloutResponse
   */
  protected virtual HttpCalloutResponse makeCallout() {
    return null;
  }

  /**
   * @description construct pagination key using user Id-table name-parent Id
   * @param
   * @return String
   */
  protected virtual String constructPaginationKey() {
    String key =
      UserInfo.getUserId() +
      '-' +
      queryContext.tableSelection.tableSelected +
      '-' +
      parentId;
    return generateHash(key);
  }

  /**
   * @description generate Hashed string
   * @param key string value to be hashed
   * @return String
   */
  protected virtual String generateHash(String key) {
    Blob data = Blob.valueOf(key);
    Blob hash = Crypto.generateDigest('SHA-256', data);
    String hashedString = EncodingUtil.convertToHex(hash);
    return hashedString;
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
}
