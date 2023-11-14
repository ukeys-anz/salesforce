/**
 * @author Ian Huang
 * @since  06/2023
 * @group CCRM (Commercial CRM)
 * @description Salesforrce connect custom adapter connection class
 * @runTests CCRMCoreBankingDataSourceProviderTest
 */
global class CCRMCoreBankingDataSourceProvider extends DataSource.Provider {
  /**
   * @description define Authentication Capabilities
   * @return List<DataSource.AuthenticationCapability>
   **/
  override global List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
    List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
    capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
    capabilities.add(DataSource.AuthenticationCapability.OAUTH);
    return capabilities;
  }

  /**
   * @description Other capabilities supported by Custom Adapters
   * @return  List<DataSource.Capability>
   **/
  override global List<DataSource.Capability> getCapabilities() {
    List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
    capabilities.add(DataSource.Capability.ROW_QUERY);
    capabilities.add(DataSource.Capability.QUERY_PAGINATION_SERVER_DRIVEN);
    capabilities.add(DataSource.Capability.QUERY_TOTAL_SIZE);
    return capabilities;
  }

  /**
   * @description obtain the external system’s schema and handle
   *  the queries and searches of the external data
   * @param connectionParams DataSource.ConnectionParams
   * @return DataSource.Connection
   **/
  override global DataSource.Connection getConnection(
    DataSource.ConnectionParams connectionParams
  ) {
    return new CCRMCoreBankingDataSourceConnection(connectionParams);
  }
}
