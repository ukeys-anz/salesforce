/**
 * @author Hinduja Upadhyay
 * @since 11/2023
 * @description Mock implementation of DataSource.Connection class
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public class TFMSearchCustMockClass {
  /**
   * @description Create DataSource.QueryContext for unit testing purpose
   * @param tableName String External object name
   * @return DataSource.QueryContext
   */
  public static DataSource.QueryContext createQueryContext(String tableName) {
    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = new DataSource.TableSelection();
    context.tableSelection.tableSelected = tableName;
    context.queryMoreToken = null;
    context.tableSelection.columnsSelected = new List<DataSource.ColumnSelection>();
    context.tableSelection.filter = createFilter(
      tableName,
      null,
      null,
      DataSource.FilterType.OR_
    );
    context.tableSelection.filter.subfilters = new List<DataSource.Filter>();
    DataSource.Filter subFilter = createFilter(
      tableName,
      'Type',
      'Retail',
      DataSource.FilterType.EQUALS
    );
    context.tableSelection.filter.subfilters.add(subFilter);
    context.maxResults = 11;
    context.offset = 0;
    List<String> columns = new List<String>{
      'UUID',
      'Preferred Name',
      'Mobile Number',
      'Email',
      'Created On',
      'OCV ID',
      'IAL (Identity Assurance Level)',
      'Status',
      'PIN Status',
      'Persona ID',
      'Type',
      'Internal User ID'
    };
    for (Integer i = 0; i < columns.size(); i++) {
      context.tableSelection.columnsSelected.add(
        createColumnSelection(tableName, columns[i])
      );
    }
    return context;
  }

  /**
   * @description Create DataSource.ColumnSelection for unit testing purpose
   * @param tableName External object name
   * @param columnName column name
   * @return DataSource.ColumnSelection
   */
  private static DataSource.ColumnSelection createColumnSelection(
    String tableName,
    String columnName
  ) {
    DataSource.ColumnSelection col = new DataSource.ColumnSelection();
    col.columnName = columnName;
    col.tableName = tableName;
    return col;
  }

  /**
   * @description Create DataSource.createFilter for unit testing purpose
   * @param tableName External object name
   * @param columnName column name
   * @param columnValue column Value
   * @param filterType filter Type
   * @return DataSource.createFilter
   */
  private static DataSource.Filter createFilter(
    String tableName,
    String columnName,
    String columnValue,
    DataSource.FilterType filterType
  ) {
    DataSource.Filter filter = new DataSource.Filter();
    filter.columnName = columnName;
    filter.columnValue = columnValue;
    filter.tableName = tableName;
    filter.type = filterType;
    return filter;
  }
}
