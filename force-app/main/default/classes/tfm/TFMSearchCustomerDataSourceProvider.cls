/**
 * @author Hinduja Upadhyay
 * @since Oct 2023
 * @description establish connection b/w SF and AegisDB
 * @group
 */

public with sharing class TFMSearchCustomerDataSourceProvider extends DataSource.Provider {
  /**
   * @description method is used to Define Supported Authentication capability
   * @return List<DataSource.AuthenticationCapability>
   */
  override public List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
    List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
    capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
    return capabilities;
  }

  /*
   * @description method is used to get Other capabilities supported by Custom Adapters
   * @return List<DataSource.AuthenticationCapability>
   */
  override public List<DataSource.Capability> getCapabilities() {
    List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
    capabilities.add(DataSource.Capability.ROW_QUERY);
    capabilities.add(DataSource.Capability.SEARCH);
    return capabilities;
  }

  /*
   * @description method is used to obtain the external system’s schema and handle the queries and searches of the external data
   * @return List<DataSource.AuthenticationCapability>
   */
  override public DataSource.Connection getConnection(
    DataSource.ConnectionParams connectionParams
  ) {
    return new TFMSearchCustomerDataSourceConnection(connectionParams);
  }
}
