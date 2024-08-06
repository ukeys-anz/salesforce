/**
 * @author Hinduja Upadhyay
 * @since Oct 2023
 * @description DataSource connection class for Aegis Search Functionality
 * @group
 */
public with sharing class TFMSearchCustomerDataSourceService {
  private static final String MOBILEPREFIX = '00610';
  private static final String NUMBERFOUR = '4';
  private static final String NUMBERZERO = '0';
  private static final String NUMBERSIXONE = '61';
  public DataSource.QueryContext queryContext;
  public DataSource.TableSelection tableSelection;

  /**
   * @description method will query external object
   * @param context DataSource.QueryContext
   * @return DataSource.TableResult
   */
  public static DataSource.TableResult queryExtServer(
    DataSource.QueryContext context
  ) {
    String searchText = (String) context.tableSelection.filter.columnValue;
    searchText = String.isBlank(searchText)
      ? (String) context.tableSelection.filter.subfilters[0].columnValue
      : searchText;
    searchText = getMobileInFormat(searchText);
    Service.IdType refId = getRefName(searchText);
    if (refId == null) {
      return null;
    }
    List<Map<String, Object>> queryResponse = DataSource.QueryUtils.process(
      context,
      getRows(refId, searchText)
    );
    return DataSource.TableResult.get(context, queryResponse);
  }

  /**
   * @description method will make do search on external object
   * @param context DataSource.QueryContext
   * @return DataSource.TableResult
   */
  public static List<DataSource.TableResult> searchExtServer(
    DataSource.SearchContext context
  ) {
    List<DataSource.TableResult> searchResults = new List<DataSource.TableResult>();
    String searchText = context.searchPhrase.replace('\\', '');
    searchText = getMobileInFormat(searchText);
    Service.IdType refId = getRefName(searchText);
    if (refId == null) {
      return null;
    }
    for (DataSource.TableSelection tableSelection : context.tableSelections) {
      searchResults.add(
        DataSource.TableResult.get(tableSelection, getRows(refId, searchText))
      );
    }
    return searchResults;
  }

  /**
   * @description method is taking care of hitting the api and getting external obj's row
   * @param refId  String
   * @param searchText  String
   * @return List<Map<String,Object>>
   */
  public static List<Map<String, Object>> getRows(
    Service.IdType refId,
    String searchText
  ) {
    List<Map<String, Object>> lstReturnDataset = new List<Map<String, Object>>();
    searchText = getMobileInFormat(searchText);
    lstReturnDataset = TFMSearchCustomerDataQueryImpl.getRowsAndHitAPI(
      getRefName(searchText),
      searchText
    );
    return lstReturnDataset;
  }

  /**
   * @description method is taking care of hitting the api and getting external obj's row
   * @param
   * @return List<DataSource.Table>
   */
  public static List<DataSource.Table> syncData() {
    return TFMSearchCustomerDataQueryImpl.sync();
  }

  /**
   * @description method is returing refId that is being used in headers
   * @param searchText String to get refId
   * @return String refId
   */

  public static Service.IdType getRefName(String searchText) {
    Service.IdType refId;
    String uuidPattern = '^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$';
    String ocvIdPattern = '^[0-9]*$';
    String mobilePattern = '^(?:\\+?61|0|00610)[4]([0-9]){8}$';
    Pattern myUUIDPattern = Pattern.compile(uuidPattern);
    Pattern myOCVIDPattern = Pattern.compile(ocvIdPattern);
    Pattern myMobilePattern = Pattern.compile(mobilePattern);
    Matcher myUuidMatcher = myUUIDPattern.matcher(searchText);
    Matcher myOcvIdMatcher = myOCVIDPattern.matcher(searchText);
    Matcher myMobileMatcher = myMobilePattern.matcher(searchText);
    if (myMobileMatcher.matches()) {
      refId = Service.IdType.IDENTIFIER;
    } else if (searchText.length() == 10 && myOcvIdMatcher.matches()) {
      refId = Service.IdType.OCVID;
    } else if (searchText.length() > 10 && myUuidMatcher.matches()) {
      refId = Service.idType.UUID;
    }
    return refId;
  }
  /**
   * @description method is returing searchtext in format if text is mobile number
   * @param searchText String to get formatted mobile number
   * @return String searchText
   */
  public static String getMobileInFormat(String searchText) {
    if (
      searchText.length() <= 14 &&
      searchText.contains(NUMBERFOUR) &&
      (searchText.startsWith(NUMBERFOUR) ||
      searchText.startsWith(NUMBERZERO) ||
      searchText.startsWith(NUMBERSIXONE))
    ) {
      // required format is 006104XXXXXXXX
      return MOBILEPREFIX +
        searchText.substring(searchText.indexOf(NUMBERFOUR));
    } else {
      return searchText;
    }
  }
}
