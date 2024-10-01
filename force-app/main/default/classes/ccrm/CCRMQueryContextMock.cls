/**
 * @author Ayushi Gupta
 * @since July 2023
 * @description Mock implementation of DataSource.Connection class
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public class CCRMQueryContextMock {
  /**
   * @description Create DataSource.QueryContext for unit testing purpose
   * @param tableName String External object name
   * @return DataSource.QueryContext
   */
  public static DataSource.QueryContext createQueryContext(String tableName) {
    Map<String, List<String>> parentColumnMap = createParentColumn();
    Map<String, List<String>> tableColumnMap = createTableColumns();

    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = new DataSource.TableSelection();
    context.tableSelection.tableSelected = tableName;
    context.queryMoreToken = null;
    context.tableSelection.columnsSelected = new List<DataSource.ColumnSelection>();
    try {
      context.tableSelection.filter = createFilter(
        tableName,
        null,
        null,
        DataSource.FilterType.OR_
      );
      context.tableSelection.filter.subfilters = new List<DataSource.Filter>();
      DataSource.Filter subFilter;
      if (
        !(parentColumnMap.keySet().isEmpty()) &&
        parentColumnMap.keySet().contains(tableName)
      ) {
        subFilter = createFilter(
          tableName,
          parentColumnMap.get(tableName)[0],
          parentColumnMap.get(tableName)[1],
          DataSource.FilterType.EQUALS
        );
      } else {
        subFilter = createFilter(
          tableName,
          'CustomerId',
          'CAP-CIS_4011643101',
          DataSource.FilterType.EQUALS
        );
      }

      context.tableSelection.filter.subfilters.add(subFilter);
      context.maxResults = 11;
      context.offset = 0;
      context = createColumns(
        tableName,
        tableColumnMap.get(tableName),
        context
      );
    } catch (Exception ex) {
      Logger.error('Unexpected errors: ' + ex.getMessage());
      Logger.saveLog();
    }
    return context;
  }

  /**
   * @description Create DataSource.QueryContext for unit testing purpose
   * @param tableName String External object name
   * @return DataSource.QueryContext
   */
  public static DataSource.QueryContext createQueryContextForSOQL(
    String tableName
  ) {
    Map<String, List<String>> parentColumnMap = new Map<String, List<String>>();
    parentColumnMap.put(
      'AccountRelationship',
      new List<String>{
        'DepositAccount',
        'CAP-CIS_4011643101-234500817|DDA-234500817'
      }
    );
    Map<String, List<String>> tableColumnMap = createTableColumns();

    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = new DataSource.TableSelection();
    context.tableSelection.tableSelected = tableName;
    context.queryMoreToken = null;
    context.tableSelection.columnsSelected = new List<DataSource.ColumnSelection>();
    try {
      context.tableSelection.filter = createFilter(
        tableName,
        null,
        null,
        DataSource.FilterType.OR_
      );
      context.tableSelection.filter.subfilters = new List<DataSource.Filter>();
      DataSource.Filter subFilter;
      if (
        !(parentColumnMap.keySet().isEmpty()) &&
        parentColumnMap.keySet().contains(tableName)
      ) {
        subFilter = createFilter(
          tableName,
          parentColumnMap.get(tableName)[0],
          parentColumnMap.get(tableName)[1],
          DataSource.FilterType.EQUALS
        );
      } else {
        subFilter = createFilter(
          tableName,
          'CustomerId',
          'CAP-CIS_4011643101',
          DataSource.FilterType.EQUALS
        );
      }

      context.tableSelection.filter.subfilters.add(subFilter);
      context.maxResults = 11;
      context.offset = 0;
      context = createColumns(
        tableName,
        tableColumnMap.get(tableName),
        context
      );
    } catch (Exception ex) {
      Logger.error('Unexpected errors: ' + ex.getMessage());
      Logger.saveLog();
    }
    return context;
  }

  /**
   * @description Create DataSource.QueryContext with external Id as default column
   * @param tableName String External object name
   * @return DataSource.QueryContext
   */
  public static DataSource.QueryContext createQueryContextWithExternalId(
    String tableName
  ) {
    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = new DataSource.TableSelection();
    context.tableSelection.tableSelected = tableName;
    context.queryMoreToken = null;
    context.tableSelection.columnsSelected = new List<DataSource.ColumnSelection>();
    context.tableSelection.filter = createFilter(
      tableName,
      'ExternalId',
      '4011643101-391102388|ILS-391102388',
      DataSource.FilterType.EQUALS
    );
    context.tableSelection.filter.subfilters = null;
    context.maxResults = 11;
    context.offset = 0;
    List<String> columns = new List<String>{
      'SubProductCode',
      'ProductCode',
      'Relationship',
      'Balance',
      'ExternalId',
      'AccountName',
      'AccountNumber'
    };
    context = createColumns(tableName, columns, context);
    return context;
  }
  /**
   * @description Creates Map having parent Id and parent value as key/value pair
   * @return Map<String, List<String>>
   */
  private static Map<String, List<String>> createParentColumn() {
    Map<String, List<String>> parentColumnMap = new Map<String, List<String>>();
    parentColumnMap.put(
      'DiaryComment',
      new List<String>{ 'Customer', 'CAP-CIS_4011643101' }
    );
    parentColumnMap.put(
      'TransactionHistory',
      new List<String>{ 'TermDepositId', 'CDA-999961674' }
    );
    parentColumnMap.put(
      'AssetDetailELS',
      new List<String>{ 'ELSId', '4011643101' }
    );
    parentColumnMap.put(
      'AssetDetail',
      new List<String>{ 'AssetId', '4020632171' }
    );
    parentColumnMap.put(
      'GuaranteeFeeDetail',
      new List<String>{ 'ActiveGuaranteeId', '4020018249' }
    );
    parentColumnMap.put(
      'CommercialBillFee',
      new List<String>{ 'CommercialBillId', '4011643101' }
    );
    parentColumnMap.put(
      'AccountRelationship',
      new List<String>{ 'AMBITId', '4019028722-13521-0' }
    );
    return parentColumnMap;
  }
  /**
   * @description Creates Map having tableName and columnsName as key/value pair
   * @return Map<String, List<String>>
   */
  private static Map<String, List<String>> createTableColumns() {
    List<String> columnNames = new List<String>{
      'ProductCode',
      'AccountName',
      'AccountNumber'
    };
    Map<String, List<String>> tableColumnMap = new Map<String, List<String>>();
    tableColumnMap.put(
      'LoanAccount',
      new List<String>{
        'SubProductCode',
        'ProductCode',
        'Relationship',
        'Balance',
        'ExternalId',
        'AccountName',
        'AccountNumber'
      }
    );
    tableColumnMap.put(
      'DepositAccount',
      new List<String>{
        'OverdraftLimit',
        'CustomerId',
        'Relationship',
        'ExternalId'
      }
    );
    tableColumnMap.put(
      'TermDeposit',
      new List<String>{
        'OverdraftLimit',
        'CustomerId',
        'Relationship',
        'ExternalId'
      }
    );
    tableColumnMap.put(
      'CreditCard',
      new List<String>{
        'OverdraftLimit',
        'ProductCode',
        'Relationship',
        'Balance',
        'ExternalId'
      }
    );
    tableColumnMap.put('OtherLimitsAndLiabilities', columnNames);
    tableColumnMap.put('BalanceHistory', columnNames);
    tableColumnMap.put('AccountRelationship', columnNames);
    tableColumnMap.put('AssetFinanceELS', columnNames);
    tableColumnMap.put('AssetFinanceAMBIT', columnNames);
    tableColumnMap.put('QueryComment', columnNames);

    tableColumnMap.put(
      'MerchantFacility',
      new List<String>{
        'TradingName',
        'MerchantID',
        'LegalName',
        'NoOfTerminals',
        'AccountStatus'
      }
    );
    tableColumnMap.put(
      'CommercialBill',
      new List<String>{ 'Status', 'AccountNumber', 'Limit' }
    );
    tableColumnMap.put(
      'IndemnityGuarantee',
      new List<String>{ 'Status', 'AccountNumber', 'Limit' }
    );
    tableColumnMap.put(
      'Facilities',
      new List<String>{ 'Sequence', 'Amount', 'ExpiryDate', 'OLLId' }
    );

    tableColumnMap.put(
      'FacilityFee',
      new List<String>{
        'FacilityLimitFee',
        'FacilityLimitFeeAmount',
        'Frequency',
        'IndemnityGuaranteeId'
      }
    );
    tableColumnMap.put(
      'ActiveIndemnityGuarantee',
      new List<String>{ 'Amount', 'ExpiryDate', 'GuaranteeId', 'SerialNumber' }
    );
    tableColumnMap.put(
      'Asset',
      new List<String>{
        'PurchasePrice',
        'AmountFinanced',
        'Status',
        'SerialNumber',
        'AssetId'
      }
    );
    tableColumnMap.put(
      'AssetDetail',
      new List<String>{
        'AssetId',
        'AssetNo',
        'PurchasePrice',
        'SerialNo',
        'Year'
      }
    );
    tableColumnMap.put(
      'AssetDetailELS',
      new List<String>{
        'ELSId',
        'AssetNo',
        'PurchasePrice',
        'SerialNo',
        'Year'
      }
    );
    tableColumnMap.put(
      'AssetRepaymentDetail',
      new List<String>{
        'AssetId',
        'Amount',
        'Frequency',
        'RepaymentAccountNumber',
        'RepaymentType'
      }
    );
    tableColumnMap.put(
      'CardHolder',
      new List<String>{
        'Balance',
        'CardholderName',
        'CardNumber',
        'CreditCardId',
        'Fee'
      }
    );
    tableColumnMap.put(
      'CommercialBillFee',
      new List<String>{
        'FeeFrequency',
        'FeeAmount',
        'CommercialBillId',
        'FeeName'
      }
    );
    tableColumnMap.put(
      'CommercialBillRepaymentDetail',
      new List<String>{
        'CommercialBillId',
        'ScheduledBillReductionAmount',
        'ScheduledEndDate',
        'ScheduledStartDate'
      }
    );
    tableColumnMap.put(
      'CreditCardFee',
      new List<String>{ 'CreditCardId', 'FeeAmount', 'FeeType' }
    );
    tableColumnMap.put(
      'DiaryComment',
      new List<String>{ 'Customer', 'Description', 'DatePlaced' }
    );
    tableColumnMap.put(
      'Favouree',
      new List<String>{ 'ActiveGuaranteeId', 'Name', 'ABN' }
    );
    tableColumnMap.put(
      'GuaranteeFeeDetail',
      new List<String>{
        'ActiveGuaranteeId',
        'FeeChargeAccount',
        'FeeType',
        'Amount'
      }
    );
    tableColumnMap.put(
      'InactiveIndemnityGuarantee',
      new List<String>{ 'Amount', 'GuaranteeId', 'PurposeCode', 'SerialNumber' }
    );
    tableColumnMap.put(
      'LinkedAccount',
      new List<String>{
        'AccountNumber',
        'Code',
        'PortfolioOfLoanId',
        'ProductCode'
      }
    );
    tableColumnMap.put(
      'LinkedBill',
      new List<String>{
        'Amount',
        'CommercialBillId',
        'BillType',
        'ReferenceNo'
      }
    );
    tableColumnMap.put(
      'TransactionHistory',
      new List<String>{
        'Amount',
        'Description',
        'EffectiveDate',
        'RunningBalance',
        'TermDepositId'
      }
    );
    tableColumnMap.put(
      'PortfolioOfLoan',
      new List<String>{ 'AccountName', 'ProductCode' }
    );
    return tableColumnMap;
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
  private static DataSource.QueryContext createColumns(
    String tableName,
    List<String> columns,
    DataSource.QueryContext context
  ) {
    if (String.isNotBlank(tableName) && columns != null && columns.size() > 0) {
      for (Integer i = 0; i < columns.size(); i++) {
        context.tableSelection.columnsSelected.add(
          createColumnSelection(tableName, columns[i])
        );
      }
    }
    return context;
  }
}
