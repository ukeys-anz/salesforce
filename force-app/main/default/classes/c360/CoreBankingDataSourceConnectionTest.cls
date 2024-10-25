/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platfrom
 * @description Salesforce connect custom adaptor connection test class
 */
@isTest
private class CoreBankingDataSourceConnectionTest {
  @isTest
  static void testSync() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    List<DataSource.Table> result = conn.sync();
    Test.stopTest();
    Assert.areEqual(result, null, 'Result is not null');
  }

  @isTest
  static void testQuery() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'DepositAccount'
    );
    DataSource.TableResult result = conn.query(context);
    Test.stopTest();
    Assert.areEqual(result.success, true, 'Error');
    Assert.areEqual(result.tableName, 'DepositAccount', 'Error');
  }

  @isTest
  static void testQueryWithInvalidTableName() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'Deposit'
    );
    String exceptionMessage;
    try {
      conn.query(context);
    } catch (Exception e) {
      exceptionMessage = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      exceptionMessage,
      'Unsupported External Object : Deposit',
      'Error'
    );
  }
}
