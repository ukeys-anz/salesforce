/**
 * @description This class serves as a data connection for the Person Digital Identity (PDI) system.
 *              It extends the DataSource.Connection class and provides implementations for sync, search, and query operations.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIDataConnection extends DataSource.Connection {
  @TestVisible
  private static final Map<String, Type> REPOSITORY_CLASSES = new Map<String, Type>{
    'Passkey' => PDIPasskeyDataRepository.class,
    'Device' => PDIDeviceDataRepository.class
  };

  override public List<DataSource.Table> sync() {
    return new List<DataSource.Table>();
  }

  override public DataSource.TableResult query(
    DataSource.QueryContext context
  ) {
    final String table = context.tableSelection.tableSelected;
    final DataSource.TableResult empty = DataSource.TableResult.get(
      context,
      new List<Map<String, Object>>()
    );

    try {
      return getRepository(table).query(context);
    } catch (Exception e) {
      if (
        e instanceof RepositoryBase.InsufficientAccessException ||
        e instanceof RepositoryBase.ServerErrorException ||
        e instanceof CalloutException
      ) {
        return empty;
      }
      Logger.error('PDIDataConnection.query ' + table, e).save();
      return empty;
    }
  }

  private static DataRepositoryBase getRepository(String table) {
    Type repositoryType = REPOSITORY_CLASSES.get(table);
    return (DataRepositoryBase) Lib_InstanceProvider.forType(repositoryType);
  }

  override public List<DataSource.DeleteResult> deleteRows(
    DataSource.DeleteContext context
  ) {
    final String table = context.tableSelected;
    return getRepository(table).deleteRows(context);
  }

  /**
   * @description Base class for data repositories to handle search and query operations.
   */
  public abstract class DataRepositoryBase {
    /**
     * @description Executes a query against a data source based on the provided query context.
     *              This method is intended to be overridden by subclasses to implement specific
     *              query logic. By default, it returns null.
     * @param context The query context containing the parameters and criteria for the query.
     * @return A list of CalloutModel objects representing the query results.
     */
    protected virtual List<CalloutModel> doQuery(
      DataSource.QueryContext context
    ) {
      return null;
    }
    /**
     * @description Transforms the given CalloutModel record into a Map of String keys and Object values.
     *              This method is intended to be overridden by subclasses to provide specific transformation logic.
     * @param record The CalloutModel instance to be transformed.
     * @return A Map<String, Object> representing the transformed data.
     */
    protected virtual Map<String, Object> transform(CalloutModel record) {
      return null;
    }

    /**
     * @description Queries the data source using the provided query context.
     * @param context The query context containing table selection and filters.
     * @return A list of mapped records as key-value pairs.
     */
    public virtual DataSource.TableResult query(
      DataSource.QueryContext context
    ) {
      List<CalloutModel> apiRecords = this.doQuery(context);
      List<Map<String, Object>> records = this.process(
        context,
        this.transform(apiRecords)
      );
      return DataSource.TableResult.get(context.tableSelection, records);
    }

    /**
     * @description Transforms a list of CalloutModel records into a list of key-value pairs.
     * @param records The list of CalloutModel records to be transformed.
     * @return A list of mapped records as key-value pairs.
     */
    @TestVisible
    protected virtual List<Map<String, Object>> transform(
      List<CalloutModel> records
    ) {
      List<Map<String, Object>> mappedRecords = new List<Map<String, Object>>();
      if (records == null) {
        return mappedRecords;
      }
      for (CalloutModel record : records) {
        Map<String, Object> mappedRecord = this.transform(record);
        if (mappedRecord != null) {
          mappedRecords.add(mappedRecord);
        }
      }
      return mappedRecords;
    }

    /**
     * @description Processes a list of records based on the provided query context. Purely for overriding in unit-test
     * @param context The query context containing metadata and parameters for processing the records.
     * @param records A list of records represented as maps of field names to their corresponding values.
     * @return A processed list of records as maps of field names to their corresponding values.
     */
    @TestVisible
    protected virtual List<Map<String, Object>> process(
      DataSource.QueryContext context,
      List<Map<String, Object>> records
    ) {
      return DataSource.QueryUtils.process(context, records);
    }

    /**
     * @description Handles the deletion of external records according to the given delete context.
     * @param context The context containing metadata and parameters for deleting the records.
     * @return A list of results generated from deleting each external ID.
     */
    @TestVisible
    protected virtual List<DataSource.DeleteResult> deleteRows(
      DataSource.DeleteContext context
    ) {
      List<DataSource.DeleteResult> results = new List<DataSource.DeleteResult>();

      for (String externalId : context.externalIds) {
        try {
          doDelete(externalId);
          results.add(DataSource.DeleteResult.success(externalId));
        } catch (Exception e) {
          results.add(
            DataSource.DeleteResult.failure(externalId, e.getMessage())
          );
        }
      }
      return results;
    }

    /**
     * @description Deletes a single record.
     * @param externalId The external Id of the record to be deleted.
     */
    @TestVisible
    protected virtual void doDelete(String externalId) {
    }
  }
}
