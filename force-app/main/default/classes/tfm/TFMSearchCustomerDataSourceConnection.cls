/**
 * @author Hinduja Upadhyay
 * @since Oct 2023
 * @description DataSource connection class for Aegis Search Functionality
 * @group
 */
public class TFMSearchCustomerDataSourceConnection extends DataSource.Connection {
  private DataSource.ConnectionParams conParam;

  /**
   * @description constructor
   * @param connectionParams  DataSource.ConnectionParams
   */
  public TFMSearchCustomerDataSourceConnection(
    DataSource.ConnectionParams connectionParams
  ) {
    conParam = connectionParams;
  }

  /**
   * @description method is used to invoke serach
   * @param context DataSource.SearchContext
   * @return List<DataSource.TableResult>
   */
  override public List<DataSource.TableResult> search(
    DataSource.SearchContext context
  ) {
    try {
      return TFMSearchCustomerDataSourceService.searchExtServer(context);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description method is used to invoke sync
   * @return List<DataSource.Table>
   */
  override public List<DataSource.Table> sync() {
    try {
      return TFMSearchCustomerDataSourceService.syncData();
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description method is used to invoke query on external object
   * @param context DataSource.QueryContext
   * @return DataSource.TableResult
   */
  override public DataSource.TableResult query(
    DataSource.QueryContext context
  ) {
    try {
      return TFMSearchCustomerDataSourceService.queryExtServer(context);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return null;
    }
  }
}
