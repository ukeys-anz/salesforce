/**
 * @description Provide methods for DML operations and loggings where needed
 * @author Tan Phan
 * @since 06/2024
 * @group Util
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public inherited sharing class DmlRepository {
  private static WithoutSharingActions systemDb {
    get {
      Logger.info('DML executing in "without sharing" context.');
      return systemDb ?? (systemDb = new WithoutSharingActions());
    }
    set;
  }

  //#region PUBLIC METHODS
  /**
   * @description Inserts a single record into the database.
   * @param record The record to be inserted.
   * @return The result of the insert operation.
   */
  public Database.SaveResult doInsert(SObject record) {
    return this.doInsert(record, new DmlConfig());
  }

  /**
   * @description Inserts a single record into the database with a specified configuration.
   * @param record The record to be inserted.
   * @param config The configuration for the insert operation.
   * @return The result of the insert operation.
   */
  public Database.SaveResult doInsert(SObject record, DmlConfig config) {
    return this.doInsert(new List<SObject>{ record }, config)[0];
  }

  /**
   * @description Inserts multiple records into the database.
   * @param records The records to be inserted.
   * @return The results of the insert operation.
   */
  public List<Database.SaveResult> doInsert(List<SObject> records) {
    return this.doInsert(records, new DmlConfig());
  }

  /**
   * @description Inserts multiple records into the database with a specified configuration.
   * @param records The records to be inserted.
   * @param config The configuration for the insert operation.
   * @return The results of the insert operation.
   */
  public List<Database.SaveResult> doInsert(
    List<SObject> records,
    DmlConfig config
  ) {
    try {
      return logSaveResult(
        config.withoutSharing
          ? systemDb.doInsert(records, config.dmlOptions)
          : Database.insert(records, config.dmlOptions, config.optAccess),
        config
      );
    } catch (Exception e) {
      throw logException(e, config);
    }
  }

  /**
   * @description Updates a single record in the database.
   * @param record The record to be updated.
   * @return The result of the update operation.
   */
  public Database.SaveResult doUpdate(SObject record) {
    return this.doUpdate(record, new DmlConfig());
  }

  /**
   * @description Updates a single record in the database with a specified configuration.
   * @param record The record to be updated.
   * @param config The configuration for the update operation.
   * @return The result of the update operation.
   */
  public Database.SaveResult doUpdate(SObject record, DmlConfig config) {
    return this.doUpdate(new List<SObject>{ record }, config)[0];
  }

  /**
   * @description Updates multiple records in the database.
   * @param records The records to be updated.
   * @return The results of the update operation.
   */
  public List<Database.SaveResult> doUpdate(List<SObject> records) {
    return this.doUpdate(records, new DmlConfig());
  }

  /**
   * @description Updates multiple records in the database with a specified configuration.
   * @param records The records to be updated.
   * @param config The configuration for the update operation.
   * @return The results of the update operation.
   */
  public List<Database.SaveResult> doUpdate(
    List<SObject> records,
    DmlConfig config
  ) {
    try {
      return logSaveResult(
        config.withoutSharing
          ? systemDb.doUpdate(records, config.dmlOptions)
          : Database.update(records, config.dmlOptions, config.optAccess),
        config
      );
    } catch (Exception e) {
      throw logException(e, config);
    }
  }

  /**
   * @description Upserts a single record into the database.
   * @param record The record to be upserted.
   * @return The result of the upsert operation.
   */
  public Database.UpsertResult doUpsert(SObject record) {
    return this.doUpsert(record, new DmlConfig());
  }

  /**
   * @description Upserts a single record into the database with a specified configuration.
   * @param record The record to be upserted.
   * @param config The configuration for the upsert operation.
   * @return The result of the upsert operation.
   */
  public Database.UpsertResult doUpsert(SObject record, DmlConfig config) {
    return this.doUpsert(new List<SObject>{ record }, config)[0];
  }

  /**
   * @description Upserts multiple records into the database.
   * @param records The records to be upserted.
   * @return The results of the upsert operation.
   */
  public List<Database.UpsertResult> doUpsert(List<SObject> records) {
    return this.doUpsert(records, new DmlConfig());
  }

  /**
   * @description Upserts multiple records into the database with a specified configuration.
   * @param records The records to be upserted.
   * @param config The configuration for the upsert operation.
   * @return The results of the upsert operation.
   */
  public List<Database.UpsertResult> doUpsert(
    List<SObject> records,
    DmlConfig config
  ) {
    try {
      return logUpsertResult(
        config.withoutSharing
          ? systemDb.doUpsert(records, config.allOrNone)
          : Database.upsert(records, config.allOrNone, config.optAccess),
        config
      );
    } catch (Exception e) {
      throw logException(e, config);
    }
  }

  /**
   * @description Deletes a single record from the database.
   * @param record The record to be deleted.
   * @return The result of the delete operation.
   */
  public Database.DeleteResult doDelete(SObject record) {
    return this.doDelete(record, new DmlConfig());
  }

  /**
   * @description Deletes a single record from the database with a specified configuration.
   * @param record The record to be deleted.
   * @param config The configuration for the delete operation.
   * @return The result of the delete operation.
   */
  public Database.DeleteResult doDelete(SObject record, DmlConfig config) {
    return this.doDelete(new List<SObject>{ record }, config)[0];
  }

  /**
   * @description Deletes multiple records from the database.
   * @param records The records to be deleted.
   * @return The results of the delete operation.
   */
  public List<Database.DeleteResult> doDelete(List<SObject> records) {
    return this.doDelete(records, new DmlConfig());
  }

  /**
   * @description Deletes multiple records from the database with a specified configuration.
   * @param records The records to be deleted.
   * @param config The configuration for the delete operation.
   * @return The results of the delete operation.
   */
  public List<Database.DeleteResult> doDelete(
    List<SObject> records,
    DmlConfig config
  ) {
    List<Database.DeleteResult> results;
    try {
      results = logDeleteResult(
        config.withoutSharing
          ? systemDb.doDelete(records, config.allOrNone)
          : Database.delete(records, config.allOrNone, config.optAccess),
        config
      );
    } catch (Exception e) {
      throw logException(e, config);
    }
    if (config.hardDelete == false) {
      return results;
    }
    List<Database.EmptyRecycleBinResult> binResults = this.doEmptyRecycleBin(
      results,
      config
    );
    return mergeResults(results, binResults);
  }

  /**
   * @description Remove from recycle bin the previously successfully deleted records.
   * @param deleteResults The DeleteResult records to empty recycly bin.
   * @param config The DmlConfig object containing configuration options.
   * @return `Database.EmptyRecycleBinResult` representing the results of the emptying operation.
   * @throws DmlException If the emptying operation fails for some records and the "allOrNone" option is set to true.
   */
  private List<Database.EmptyRecycleBinResult> doEmptyRecycleBin(
    List<Database.DeleteResult> deleteResults,
    DmlConfig config
  ) {
    Set<Id> recordIds = new Set<Id>();
    for (Database.DeleteResult result : deleteResults) {
      if (result.success) {
        recordIds.add(result.id);
      }
    }
    return this.doEmptyRecycleBin(recordIds, config);
  }

  /**
   * @description Performs emptying of the recycle bin for the specified record IDs.
   * @param recordIds The set of record IDs to empty from the recycle bin.
   * @param config The DmlConfig object containing configuration options.
   * @return `Database.EmptyRecycleBinResult` representing the results of the emptying operation.
   * @throws DmlException If the emptying operation fails for some records and the "allOrNone" option is set to true.
   */
  private List<Database.EmptyRecycleBinResult> doEmptyRecycleBin(
    Set<Id> recordIds,
    DmlConfig config
  ) {
    List<Id> listIds = new List<Id>(recordIds);
    List<Database.EmptyRecycleBinResult> results = logEmptyRecycleBinResult(
      config.withoutSharing
        ? systemDb.doEmptyRecycleBin(listIds)
        : Database.emptyRecycleBin(listIds),
      config
    );
    if (config.allOrNone == false) {
      return results;
    }
    for (Database.EmptyRecycleBinResult result : results) {
      if (result.success == false) {
        throw new DmlException(
          'EmptyRecycleBin failed: ' + result.getErrors()[0].message
        );
      }
    }
    return results;
  }

  /**
   * @description Undeletes a single record in the database.
   * @param record The record to be undeleted.
   * @return The result of the undelete operation.
   */
  public Database.UndeleteResult doUndelete(SObject record) {
    return this.doUndelete(record, new DmlConfig());
  }

  /**
   * @description Undeletes a single record in the database with a specified configuration.
   * @param record The record to be undeleted.
   * @param config The configuration for the undelete operation.
   * @return The result of the undelete operation.
   */
  public Database.UndeleteResult doUndelete(SObject record, DmlConfig config) {
    return this.doUndelete(new List<SObject>{ record }, config)[0];
  }

  /**
   * @description Undeletes multiple records in the database.
   * @param records The records to be undeleted.
   * @return The results of the undelete operation.
   */
  public List<Database.UndeleteResult> doUndelete(List<SObject> records) {
    return this.doUndelete(records, new DmlConfig());
  }

  /**
   * @description Undeletes multiple records in the database with a specified configuration.
   * @param records The records to be undeleted.
   * @param config The configuration for the undelete operation.
   * @return The results of the undelete operation.
   */
  public List<Database.UndeleteResult> doUndelete(
    List<SObject> records,
    DmlConfig config
  ) {
    try {
      return logUndeleteResult(
        config.withoutSharing
          ? systemDb.doUndelete(records, config.allOrNone)
          : Database.undelete(records, config.allOrNone, config.optAccess),
        config
      );
    } catch (Exception e) {
      throw logException(e, config);
    }
  }

  /**
   * @description Performs a publish operation on a single Event.
   * @param event The Event to publish.
   * @return The result of the publish operation.
   */
  public Database.SaveResult doPublish(SObject event) {
    return this.doPublish(event, new DmlConfig());
  }

  /**
   * @description Performs a publish operation on a single Event with a specified configuration.
   * @param event The Event to publish.
   * @param config The configuration for the publish operation. Only `optSeverity` and `errorLog` are used.
   * @return The result of the publish operation.
   */
  public Database.SaveResult doPublish(SObject event, DmlConfig config) {
    return this.doPublish(new List<SObject>{ event }, config)[0];
  }

  /**
   * @description Performs a publish operation on a list of Events.
   * @param events The list of Events to publish.
   * @return The results of the publish operation.
   */
  public List<Database.SaveResult> doPublish(List<SObject> events) {
    return this.doPublish(events, new DmlConfig());
  }

  /**
   * @description Performs a publish operation on a list of Salesforce Events with a specified configuration.
   * @param events The list of Events to publish.
   * @param config The configuration for the publish operation. Only `optSeverity` and `errorLog` are used.
   * @return The results of the publish operation.
   */
  public List<Database.SaveResult> doPublish(
    List<SObject> events,
    DmlConfig config
  ) {
    return logSaveResult(EventBus.publish(events), config);
  }
  //#endregion

  //#region HELPERS
  private static Exception logException(Exception e, DmlConfig config) {
    Logger.error(config.errorLog, e, config.optSeverity).save();
    return e;
  }

  private static List<Database.SaveResult> logSaveResult(
    List<Database.SaveResult> results,
    DmlConfig config
  ) {
    Logger.error(config.errorLog, results, config.optSeverity).save();
    return results;
  }

  private static List<Database.UpsertResult> logUpsertResult(
    List<Database.UpsertResult> results,
    DmlConfig config
  ) {
    Logger.error(config.errorLog, results, config.optSeverity).save();
    return results;
  }

  private static List<Database.DeleteResult> logDeleteResult(
    List<Database.DeleteResult> results,
    DmlConfig config
  ) {
    Logger.error(config.errorLog, results, config.optSeverity).save();
    return results;
  }

  private static List<Database.UndeleteResult> logUndeleteResult(
    List<Database.UndeleteResult> results,
    DmlConfig config
  ) {
    Logger.error(config.errorLog, results, config.optSeverity).save();
    return results;
  }

  private static List<Database.EmptyRecycleBinResult> logEmptyRecycleBinResult(
    List<Database.EmptyRecycleBinResult> results,
    DmlConfig config
  ) {
    Logger.error(config.errorLog, results, config.optSeverity).save();
    return results;
  }

  private static List<Database.DeleteResult> mergeResults(
    List<Database.DeleteResult> deleteResults,
    List<Database.EmptyRecycleBinResult> binResults
  ) {
    //filter error bin results
    List<Database.EmptyRecycleBinResult> errorBinResults = new List<Database.EmptyRecycleBinResult>();
    for (Database.EmptyRecycleBinResult binResult : binResults) {
      if (binResult.success == false) {
        errorBinResults.add(binResult);
      }
    }
    //convert EmptyRecycleBinResult to DeleteResult
    String jsonResults = JSON.serialize(errorBinResults);
    List<Database.DeleteResult> convertedResults = (List<Database.DeleteResult>) JSON.deserialize(
      jsonResults,
      List<Database.DeleteResult>.class
    );
    //construct map of bin result by record ID
    Map<Id, Database.DeleteResult> mapBinResult = new Map<Id, Database.DeleteResult>();
    for (Database.DeleteResult result : convertedResults) {
      mapBinResult.put(result.id, result);
    }
    //for each delete result, return bin result if any, otherwise return the delete result itself
    List<Database.DeleteResult> output = new List<Database.DeleteResult>();
    for (Database.DeleteResult deleteResult : deleteResults) {
      Database.DeleteResult binResult = mapBinResult.get(deleteResult.id);
      output.add(binResult ?? deleteResult);
    }
    return output;
  }
  //#endregion

  /**
   * @description Provide methods for DML operations in `without sharing` context
   */
  private without sharing class WithoutSharingActions {
    private List<Database.SaveResult> doInsert(
      List<SObject> records,
      Database.DMLOptions options
    ) {
      return Database.insert(records, options);
    }

    private List<Database.SaveResult> doUpdate(
      List<SObject> records,
      Database.DMLOptions options
    ) {
      return Database.update(records, options);
    }

    private List<Database.UpsertResult> doUpsert(
      List<SObject> records,
      Boolean allOrNone
    ) {
      return Database.upsert(records, allOrNone);
    }

    private List<Database.DeleteResult> doDelete(
      List<SObject> records,
      Boolean allOrNone
    ) {
      return Database.delete(records, allOrNone);
    }

    private List<Database.UndeleteResult> doUndelete(
      List<SObject> records,
      Boolean allOrNone
    ) {
      return Database.undelete(records, allOrNone);
    }

    private List<Database.EmptyRecycleBinResult> doEmptyRecycleBin(
      List<Id> recordIds
    ) {
      return Database.emptyRecycleBin(recordIds);
    }
  }

  //#region DEPRECATED
  public static final Boolean ALL_OR_NONE = true;
  public static final Boolean ALLOW_PARTIAL = false;
  public static final Boolean USER_MODE = true;
  public static final Boolean SYSTEM_MODE = false;

  /**
   * [DEPRECATED] Use `doUpdate`
   * @description Method to perform database updates
   * @param records List of records to update
   * @param allOrNone Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.SaveResult> Results of update operation
   */
  public List<Database.SaveResult> updateRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
      results = Database.update(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * [DEPRECATED] Use `doUpsert`
   * @description Method to perform database upserts
   * @param records List of records to insert/update
   * @param allOrNone Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.UpsertResult> Results of upsert operation
   */
  public List<Database.UpsertResult> upsertRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.UpsertResult> results = new List<Database.UpsertResult>();
    try {
      results = Database.upsert(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * [DEPRECATED] Use `doInsert`
   * @description Method to perform database insert
   * @param records List of records to insert
   * @param allOrNone Boolean value to validate if records should be inserted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   *  @return List<Database.SaveResult> Results of insert operation
   */
  public List<Database.SaveResult> insertRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
      results = Database.insert(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * [DEPRECATED] Use `doDelete`
   * @description Method to perform database delete
   * @param records List of records to delete
   * @param allOrNone Boolean value to validate if records should be deleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.DeleteResult> Results of delete operation
   */
  public List<Database.DeleteResult> deleteRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.DeleteResult> results = new List<Database.DeleteResult>();
    try {
      results = Database.delete(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * [DEPRECATED] Use `doUndelete`
   * @description Method to perform database undelete
   * @param records List of records to undelete
   * @param allOrNone Boolean value to validate if records should be undeleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.UndeleteResult> Results of undelete operation
   */
  public List<Database.UndeleteResult> undeleteRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.UndeleteResult> results = new List<Database.UndeleteResult>();
    try {
      results = Database.undelete(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  private static AccessLevel accessLevel(Boolean userLevel) {
    return userLevel ? AccessLevel.USER_MODE : AccessLevel.SYSTEM_MODE;
  }
  //#endregion
}
