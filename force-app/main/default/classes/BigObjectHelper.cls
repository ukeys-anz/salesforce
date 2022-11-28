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
    Logger.error('', results);
    Boolean hasError = LoggerHelper.getBufferSize() > 0;
    Logger.saveLog();
    return !hasError;
  }
}
