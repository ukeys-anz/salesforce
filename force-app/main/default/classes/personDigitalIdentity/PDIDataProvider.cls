/**
 * @description This class provides data source capabilities for Person Digital Identity.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIDataProvider extends DataSource.Provider {
  /**
   * @description method is used to Define Supported Authentication capability
   * @return List<DataSource.AuthenticationCapability>
   */
  override public List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
    return new List<DataSource.AuthenticationCapability>{
      DataSource.AuthenticationCapability.ANONYMOUS
    };
  }

  /*
   * @description method is used to get Other capabilities supported by Custom Adapters
   * @return List<DataSource.AuthenticationCapability>
   */
  override public List<DataSource.Capability> getCapabilities() {
    return new List<DataSource.Capability>{
      DataSource.Capability.ROW_QUERY,
      DataSource.Capability.ROW_CREATE,
      DataSource.Capability.ROW_UPDATE,
      DataSource.Capability.ROW_DELETE
    };
  }

  /*
   * @description method is used to obtain the external system’s schema and handle the queries and searches of the external data
   * @return List<DataSource.AuthenticationCapability>
   */
  override public DataSource.Connection getConnection(
    DataSource.ConnectionParams conn
  ) {
    return new PDIDataConnection();
  }
}
