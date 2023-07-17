/**
 * @author Peter Charalambous
 * @since 02/2022
 * @description Actions that are required to be run without sharing to be used here
 */
public without sharing class SystemModeActions {
  /**
   * @description The function name to use with logging.
   */
  private String className { get; set; }

  /**
   * @description The function name to use with logging.
   */
  private String methodName { get; set; }

  /**
   * @description Constructor
   * @param className Class name used to call method
   * @param methodName Method name used to call method
   */
  public SystemModeActions(String className, String methodName) {
    this.className = className;
    this.methodName = methodName;
  }

  /**
   * @description method to query and return query result
   * @param soql | String | The SOQL Query
   * @return results | List | A list of the returned database results
   */
  public List<SObject> query(String soql) {
    List<SObject> results = Database.query(soql);

    Logger.info('Query logged without sharing');
    Logger.saveLog();

    return results;
  }

  /**
   * @description method to update records in a without sharing context when needed
   * @param records records to update
   * @param objectName object name we're updating
   * @return boolean whether or not any errors were logged
   */
  public boolean updateRecords(List<SObject> records, String objectName) {
    if (records == null || records.size() == 0) {
      return false;
    }

    List<Database.SaveResult> results = Database.Update(records, false);
    Logger.error('', results);
    Boolean hasError = Logger.hasError();
    Logger.saveLog();
    return hasError;
  }

  /**
   * @description method to upsert records in a without sharing context when needed
   * @param records records to update
   * @param externalId externalId to match against
   * @param objectName object name we're upserting
   * @return Boolean
   */
  public Boolean upsertRecords(
    List<SObject> records,
    Schema.SObjectField externalId,
    String objectName
  ) {
    lib_systemLog log = new lib_systemLog(className, methodName);

    List<Database.UpsertResult> results = Database.upsert(
      records,
      externalId,
      false
    );

    //log errors to application log
    Boolean hasError = log.addDatabaseUpsertResult(
      objectName,
      results,
      records
    );
    log.insertLogAsync();
    return hasError;
  }
}
