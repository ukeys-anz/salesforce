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
    DataSource.Filter subFilter;
    if (tableName == 'DiaryComment') {
      subFilter = createFilter(
        tableName,
        'Customer',
        'CAP-CIS_4011643101',
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
    List<String> columns;
    switch on tableName {
      when 'LoanAccount' {
        columns = new List<String>{
          'SubProductCode',
          'ProductCode',
          'Relationship',
          'Balance',
          'ExternalId',
          'AccountName',
          'AccountNumber'
        };
      }
      when 'DepositAccount', 'TermDeposit' {
        columns = new List<String>{
          'OverdraftLimit',
          'CustomerId',
          'Relationship',
          'ExternalId'
        };
      }
      when 'CreditCard' {
        columns = new List<String>{
          'OverdraftLimit',
          'ProductCode',
          'Relationship',
          'Balance',
          'ExternalId'
        };
      }
      when 'OtherLimitsAndLiabilities',
        'BalanceHistory',
        'AccountRelationship',
        'AssetFinanceELS',
        'AssetFinanceAMBIT',
        'QueryComment' {
        columns = new List<String>{
          'ProductCode',
          'AccountName',
          'AccountNumber'
        };
      }
      when 'MerchantFacility' {
        columns = new List<String>{
          'TradingName',
          'MerchantID',
          'LegalName',
          'NoOfTerminals',
          'AccountStatus'
        };
      }
      when 'CommercialBill', 'IndemnityGuarantee' {
        columns = new List<String>{ 'Status', 'AccountNumber', 'Limit' };
      }
      when 'Facilities' {
        columns = new List<String>{
          'Sequence',
          'Amount',
          'ExpiryDate',
          'OLLId'
        };
      }
      when 'FacilityFee' {
        columns = new List<String>{
          'FacilityLimitFee',
          'FacilityLimitFeeAmount',
          'Frequency',
          'IndemnityGuaranteeId'
        };
      }
      when 'ActiveIndemnityGuarantee' {
        columns = new List<String>{
          'Amount',
          'ExpiryDate',
          'GuaranteeId',
          'SerialNumber'
        };
      }
      when 'Asset' {
        columns = new List<String>{
          'PurchasePrice',
          'AmountFinanced',
          'Status',
          'SerialNumber',
          'AssetId'
        };
      }
      when 'AssetDetail' {
        columns = new List<String>{
          'AssetId',
          'AssetNo',
          'PurchasePrice',
          'SerialNo',
          'Year'
        };
      }
      when 'AssetDetailELS' {
        columns = new List<String>{
          'ELSId',
          'AssetNo',
          'PurchasePrice',
          'SerialNo',
          'Year'
        };
      }
      when 'AssetRepaymentDetail' {
        columns = new List<String>{
          'AssetId',
          'Amount',
          'Frequency',
          'RepaymentAccountNumber',
          'RepaymentType'
        };
      }
      when 'CardHolder' {
        columns = new List<String>{
          'Balance',
          'CardholderName',
          'CardNumber',
          'CreditCardId',
          'Fee'
        };
      }
      when 'CommercialBillFee' {
        columns = new List<String>{
          'FeeFrequency',
          'FeeAmount',
          'CommercialBillId',
          'FeeName'
        };
      }
      when 'CommercialBillRepaymentDetail' {
        columns = new List<String>{
          'CommercialBillId',
          'ScheduledBillReductionAmount',
          'ScheduledEndDate',
          'ScheduledStartDate'
        };
      }
      when 'CreditCardFee' {
        columns = new List<String>{ 'CreditCardId', 'FeeAmount', 'FeeType' };
      }
      when 'DiaryComment' {
        columns = new List<String>{ 'Customer', 'Description', 'DatePlaced' };
      }
      when 'Favouree' {
        columns = new List<String>{ 'ActiveGuaranteeId', 'Name', 'ABN' };
      }
      when 'GuaranteeFeeDetail' {
        columns = new List<String>{
          'ActiveGuaranteeId',
          'FeeChargeAccount',
          'FeeType',
          'Amount'
        };
      }
      when 'InactiveIndemnityGuarantee' {
        columns = new List<String>{
          'Amount',
          'GuaranteeId',
          'PurposeCode',
          'SerialNumber'
        };
      }
      when 'LinkedAccount' {
        columns = new List<String>{
          'AccountNumber',
          'Code',
          'PortfolioOfLoanId',
          'ProductCode'
        };
      }
      when 'LinkedBill' {
        columns = new List<String>{
          'Amount',
          'CommercialBillId',
          'BillType',
          'ReferenceNo'
        };
      }
      when 'TransactionHistory' {
        columns = new List<String>{
          'Amount',
          'Description',
          'EffectiveDate',
          'RunningBalance'
        };
      }
      when 'PortfolioOfLoan' {
        columns = new List<String>{ 'AccountName', 'ProductCode' };
      }
    }
    context = createColumns(tableName, columns, context);
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
