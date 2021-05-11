/**
 * @author Peter Charalambous
 * @since  April 2021
 * @description This class is called as a wrapper for big object queries
 */
public with sharing class BigObjectHelper {
  /**
   * @description Used to insert the big object records
   * @param records big object records to insert
   * @param bigObjectName the api name of the big object being inserted
   * @return Boolean if success
   */
  public Boolean insertBigObject(List<SObject> records, String bigObjectName) {
    List<Database.SaveResult> results = Database.insertImmediate(records);

    //log errors to application log
    lib_systemLog log = new lib_systemLog('BigObjectHelper', 'insertBigObject');
    Boolean hasError = log.addDatabaseSaveResult(
      bigObjectName,
      results,
      new List<SObject>()
    );
    log.insertLog();

    return !hasError;
  }
}
