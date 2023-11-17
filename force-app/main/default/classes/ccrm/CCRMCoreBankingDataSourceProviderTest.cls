/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Salesforce connect custom adapter connection test class
 */
@isTest
private class CCRMCoreBankingDataSourceProviderTest {
  @isTest
  static void testAuthenticationCapabilities() {
    CCRMCoreBankingDataSourceProvider dataProvider = new CCRMCoreBankingDataSourceProvider();
    Test.startTest();
    List<DataSource.AuthenticationCapability> capability = dataProvider.getAuthenticationCapabilities();
    Test.stopTest();
    System.assertEquals(
      capability.size(),
      2,
      'AuthenticationCapability size is not 2'
    );
  }

  @isTest
  static void testGetCapabilities() {
    CCRMCoreBankingDataSourceProvider dataProvider = new CCRMCoreBankingDataSourceProvider();
    Test.startTest();
    List<DataSource.Capability> capability = dataProvider.getCapabilities();
    Test.stopTest();
    System.assertEquals(capability.size(), 3, 'Capability size is not 3');
  }

  @isTest
  static void testGetConnection() {
    CCRMCoreBankingDataSourceProvider dataProvider = new CCRMCoreBankingDataSourceProvider();
    Test.startTest();
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    DataSource.Connection con = dataProvider.getConnection(connectionParams);
    CCRMCoreBankingDataSourceConnection expectedCon = new CCRMCoreBankingDataSourceConnection(
      connectionParams
    );
    Test.stopTest();
    System.assert(con != null, 'Error');
  }
}
