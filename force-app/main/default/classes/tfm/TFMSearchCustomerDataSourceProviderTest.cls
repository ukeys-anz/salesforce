/**
 * @author Hinduja Upadhyay
 * @since  11/2023
 * @group
 * @description Salesforce connect custom adapter connection test class
 */
@isTest
public class TFMSearchCustomerDataSourceProviderTest {
  @isTest
  static void testAuthenticationCapabilities() {
    TFMSearchCustomerDataSourceProvider dataProvider = new TFMSearchCustomerDataSourceProvider();
    Test.startTest();
    List<DataSource.AuthenticationCapability> capability = dataProvider.getAuthenticationCapabilities();
    Test.stopTest();
    System.assertEquals(
      capability.size(),
      1,
      'AuthenticationCapability size is 1'
    );
  }

  @isTest
  static void testGetCapabilities() {
    TFMSearchCustomerDataSourceProvider dataProvider = new TFMSearchCustomerDataSourceProvider();
    Test.startTest();
    List<DataSource.Capability> capability = dataProvider.getCapabilities();
    Test.stopTest();
    System.assertEquals(capability.size(), 2, 'Capability size is 2');
  }

  @isTest
  static void testGetConnection() {
    TFMSearchCustomerDataSourceProvider dataProvider = new TFMSearchCustomerDataSourceProvider();
    Test.startTest();
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    DataSource.Connection con = dataProvider.getConnection(connectionParams);
    TFMSearchCustomerDataSourceConnection expectedCon = new TFMSearchCustomerDataSourceConnection(
      connectionParams
    );
    Test.stopTest();
    System.assert(con != null, 'Error');
  }
}
