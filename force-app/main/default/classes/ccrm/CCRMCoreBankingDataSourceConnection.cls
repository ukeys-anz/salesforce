/**
 * @author Ian Huang
 * @since  06/2023
 * @group CCRM (Commercial CRM)
 * @description Salesforce Connect custom adaptor connection class
 * @runTests CCRMCoreBankingDataSourceConnectionTest
 */
global class CCRMCoreBankingDataSourceConnection extends DataSource.Connection {
  /**
   * @description Class constructor
   * @param connectionParams DataSource.ConnectionParams
   */
  global CCRMCoreBankingDataSourceConnection(
    DataSource.ConnectionParams connectionParams
  ) {
  }

  /**
   * @description External object fields are configured at Salesforce setup UI
   *              Setup -> External Objects
   * @return List<DataSource.Table>
   */
  override global List<DataSource.Table> sync() {
    return null;
  }

  /**
   * @description Query capability implementation
   * @param context DataSource.QueryContext
   * @return DataSource.TableResult
   */
  override global DataSource.TableResult query(
    DataSource.QueryContext context
  ) {
    // query external objetcs
    return queryExternalObject(context);
  }

  /**
   * @description Query external object data
   * @param context DataSource.QueryContext
   * @return DataSource.TableResult
   */
  private DataSource.TableResult queryExternalObject(
    DataSource.QueryContext context
  ) {
    //instantiate External object query class based on external object name
    CCRMExternalObjectQueryBase externalQuery = instantiateExternalQueryClass(
      context.tableSelection.tableSelected
    );

    DataSource.TableResult result;
    try {
      CCRMExternalObjectQueryBase.ExternalQueryResult externalData = externalQuery.execute(
        context
      );

      result = DataSource.TableResult.get(
        true,
        '',
        context.TableSelection.tableSelected,
        externalData.queryResult
      );
      result.queryMoreToken = externalData.queryMoreToken;
    } catch (Exception ex) {
      Logger.error('Unexpected errors: ' + ex.getMessage());
      Logger.saveLog();

      result = DataSource.TableResult.get(
        false,
        'Unexpected errors. Please contact your system administrator.',
        context.TableSelection.tableSelected,
        new List<Map<String, Object>>()
      );
    }

    return result;
  }

  /**
   * @description Instantiate External object Query class based on Financial account name
   * @param tableName External object name
   * @return CCRMExternalObjectQueryBase class
   */
  private CCRMExternalObjectQueryBase instantiateExternalQueryClass(
    String tableName
  ) {
    CCRMExternalObjectQueryBase externalQuery;

    String queryClassName = 'CCRM' + tableName.remove(' ') + 'Query';
    Type t = Type.forName(queryClassName);
    if (t != null) {
      externalQuery = (CCRMExternalObjectQueryBase) t.newInstance();
    } else {
      Logger.error('Unsupported External Object : ' + tableName);
      Logger.saveLog();
      throw new TypeException('Unsupported External Object : ' + tableName);
    }

    return externalQuery;
  }
}
