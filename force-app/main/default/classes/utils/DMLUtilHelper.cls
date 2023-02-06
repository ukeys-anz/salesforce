/**
 * @description       : Helper class for the DMLUtil class
 * @author            : Prakash B
 * @group             : Util
 * @last modified on  : 30-01-2023
 **/

public inherited sharing class DMLUtilHelper {
  /**
   * @description Method which loops through the database results and logs any error if there are any
   * @param results List of database results to process
   */

  public static void processResults(List<Database.SaveResult> results) {
    Logger.error('', results);
    Logger.saveLog();
  }

  /**
   * @description Method which loops through the database upsert results and logs any error if there are any
   * @param results List of database upsert results to process
   */

  public static void processUpsertResults(List<Database.UpsertResult> results) {
    Logger.error('', results);
    Logger.saveLog();
  }

  /**
   * @description Method which loops through the database delete results and logs any error if there are any
   * @param results List of database delete results to process
   */

  public static void processDeleteResults(List<Database.DeleteResult> results) {
    Logger.error('', results);
    Logger.saveLog();
  }

  /**
   * @description Method which loops through the database undelete results and logs any error if there are any
   * @param results List of database undelete results to process
   */

  public static void processUndeleteResults(
    List<Database.UndeleteResult> results
  ) {
    Logger.error('', results);
    Logger.saveLog();
  }

  /**
   * @description Generic method to log errors for exceptions
   * @param e Exception during the DML operation
   */

  public static void logException(Exception e) {
    Logger.error(e.getMessage(), e);
    Logger.saveLog();
  }
}
