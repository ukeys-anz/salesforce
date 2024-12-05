/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Salesforce connect custom adapter connection test class
 */
@isTest
private class CoreBankingDataSourceProviderTest {
  @isTest
  static void testAuthenticationCapabilities() {
    CoreBankingDataSourceProvider dataProvider = new CoreBankingDataSourceProvider();
    Test.startTest();
    List<DataSource.AuthenticationCapability> capability = dataProvider.getAuthenticationCapabilities();
    Test.stopTest();
    Assert.areEqual(
      capability.size(),
      2,
      'AuthenticationCapability size is not 2'
    );
  }

  @isTest
  static void testGetCapabilities() {
    CoreBankingDataSourceProvider dataProvider = new CoreBankingDataSourceProvider();
    Test.startTest();
    List<DataSource.Capability> capability = dataProvider.getCapabilities();
    Test.stopTest();
    Assert.areEqual(capability.size(), 3, 'Capability size is not 3');
  }

  @isTest
  static void testGetConnection() {
    CoreBankingDataSourceProvider dataProvider = new CoreBankingDataSourceProvider();
    Test.startTest();
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    DataSource.Connection con = dataProvider.getConnection(connectionParams);
    new CoreBankingDataSourceConnection(connectionParams);
    Test.stopTest();
    Assert.isTrue(con != null, 'Error');
  }
}
