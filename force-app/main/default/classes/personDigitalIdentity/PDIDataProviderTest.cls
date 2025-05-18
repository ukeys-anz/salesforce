@isTest
private class PDIDataProviderTest {
  @isTest
  static void testGetAuthenticationCapabilities() {
    PDIDataProvider provider = new PDIDataProvider();
    Test.startTest();
    List<DataSource.AuthenticationCapability> capabilities = provider.getAuthenticationCapabilities();
    Test.stopTest();
    Assert.isTrue(
      capabilities.contains(DataSource.AuthenticationCapability.ANONYMOUS),
      'Capability should contain ANONYMOUS'
    );
  }

  @isTest
  static void testGetCapabilities() {
    PDIDataProvider provider = new PDIDataProvider();
    Test.startTest();
    List<DataSource.Capability> capabilities = provider.getCapabilities();
    Test.stopTest();
    Assert.isTrue(
      capabilities.contains(DataSource.Capability.ROW_QUERY),
      'Capability should contain ROW_QUERY'
    );
    Assert.isTrue(
      capabilities.contains(DataSource.Capability.ROW_UPDATE),
      'Capability should contain ROW_UPDATE'
    );
    Assert.isTrue(
      capabilities.contains(DataSource.Capability.ROW_DELETE),
      'Capability should contain ROW_DELETE'
    );
  }

  @isTest
  static void testGetConnection() {
    PDIDataProvider provider = new PDIDataProvider();
    DataSource.ConnectionParams connParams = new DataSource.ConnectionParams();
    Test.startTest();
    DataSource.Connection connection = provider.getConnection(connParams);
    Test.stopTest();
    Assert.isInstanceOfType(
      connection,
      PDIDataConnection.class,
      'Connection should be an instance of PDIDataConnection'
    );
  }
}
