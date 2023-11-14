/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Salesforce connect custom adaptor connection test class
 */
@isTest
private class CCRMCoreBankingDataSourceConnectionTest {
  @isTest
  static void testSync() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    List<DataSource.Table> result = conn.sync();
    Test.stopTest();
    System.assertEquals(result, null, 'Result is not null');
  }

  @isTest
  static void testQuery() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'DepositAccount'
    );
    DataSource.TableResult result = conn.query(context);
    Test.stopTest();
    System.assertEquals(result.success, true, 'Error');
    System.assertEquals(result.tableName, 'DepositAccount', 'Error');
  }

  @isTest
  static void testQueryWithInvalidTableName() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'Deposit'
    );
    String exceptionMessage;
    try {
      DataSource.TableResult result = conn.query(context);
    } catch (Exception e) {
      exceptionMessage = e.getMessage();
    }
    Test.stopTest();
    System.assertEquals(
      exceptionMessage,
      'Unsupported External Object : Deposit',
      'Error'
    );
  }
}
