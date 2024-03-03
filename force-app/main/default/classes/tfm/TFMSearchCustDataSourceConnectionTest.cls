/**
 * @author Hinduja Upadhyay
 * @since  11/2023
 * @group
 * @description Salesforce connect custom adaptor connection test class
 */
@isTest
public class TFMSearchCustDataSourceConnectionTest {
  @isTest
  static void testSync() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    TFMSearchCustomerDataSourceConnection conn = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    List<DataSource.Table> result = conn.sync();
    Test.stopTest();
    Assert.areNotEqual(null, result, 'Connection is not established');
  }

  @isTest
  static void testQuery() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    TFMSearchCustomerDataSourceConnection conn = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = TFMSearchCustMockClass.createQueryContext(
      'PersonDigitalIdentity'
    );
    context.tableSelection.filter.columnValue = '00610477123667';
    DataSource.TableResult result = conn.query(context);
    Test.stopTest();
    Assert.areEqual(true, result.success, 'Table did not return data result');
    Assert.areEqual(
      'PersonDigitalIdentity',
      result.tableName,
      'Table name is not correct, expected: PersonDigitalIdentity'
    );
  }

  @isTest
  static void testExceptionQuery() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    DataSource.TableResult result;
    String exceptionMessage;
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    TFMSearchCustomerDataSourceConnection conn = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = TFMSearchCustMockClass.createQueryContext(
      'abc'
    );
    context.tableSelection.filter.columnName = null;
    context.tableSelection.filter.columnValue = null;
    try {
      result = conn.query(context);
    } catch (Exception e) {
      exceptionMessage = e.getMessage();
    }
    Test.stopTest();
  }

  @isTest
  static void testOCVIDQuery() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    TFMSearchCustomerDataSourceConnection conn = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = TFMSearchCustMockClass.createQueryContext(
      'PersonDigitalIdentity'
    );
    context.tableSelection.filter.columnValue = '1001292844';
    DataSource.TableResult result = conn.query(context);
    Test.stopTest();
    Assert.areEqual(true, result.success, 'Table did not return data result');
    Assert.areEqual(
      'PersonDigitalIdentity',
      result.tableName,
      'Table name is not correct, expected:PersonDigitalIdentity'
    );
  }

  @isTest
  static void testSearch() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    TFMSearchCustomerDataSourceConnection conn = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.SearchContext context = new DataSource.SearchContext();
    context.searchPhrase = '00610477123667';
    List<DataSource.TableSelection> tableSelectionList = new List<DataSource.TableSelection>();
    DataSource.TableSelection tableSelection = new DataSource.TableSelection();
    tableSelection.tableSelected = 'PersonDigitalIdentity';
    tableSelectionList.add(tableSelection);
    context.tableSelections = tableSelectionList;
    List<DataSource.TableResult> result = conn.search(context);
    Test.stopTest();
    Assert.areEqual(
      true,
      result[0].success,
      'Table did not return data result'
    );
    Assert.areEqual(
      'PersonDigitalIdentity',
      result[0].tableName,
      'Table name is not correct, expected:PersonDigitalIdentity'
    );
  }

  @isTest
  static void testExceptionSearch() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    List<DataSource.TableResult> result;
    String exceptionMessage;
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    TFMSearchCustomerDataSourceConnection conn = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.SearchContext context = new DataSource.SearchContext();
    context.searchPhrase = null;
    List<DataSource.TableSelection> tableSelectionList = new List<DataSource.TableSelection>();
    DataSource.TableSelection tableSelection = new DataSource.TableSelection();
    tableSelection.tableSelected = 'PersonDigitalIdentity';
    tableSelectionList.add(tableSelection);
    context.tableSelections = tableSelectionList;
    try {
      result = conn.search(context);
    } catch (Exception e) {
      exceptionMessage = e.getMessage();
    }
    Test.stopTest();
  }
}
