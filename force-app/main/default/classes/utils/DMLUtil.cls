/**
 * @description       : Util class for DML operations
 * inherited sharing: to declaring a class to enforce the sharing rules of the class that calls it
 * @author            : Prakash B
 * @group             : Util
 * @last modified on  : 19-04-2023
 **/

public inherited sharing class DMLUtil {
  //Partial Update Constants
  public static final Boolean ALLOW_PARTIAL_UPDATE = true;
  public static final Boolean NOT_ALLOW_PARTIAL_UPDATE = false;
  //Access Level Constants
  public static final Boolean USER_MODE = true;
  public static final Boolean SYSTEM_MODE = false;
  /**
   * @description Method to perform database updates
   * @param records List of records to update
   * @param allowPartialUpdate Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.SaveResult> Results of update operation
   */
  public static List<Database.SaveResult> updateRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;

    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
      results = Database.update(records, allowPartialUpdate, accessLevel);
      DMLUtilHelper.processResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }

    return results;
  }

  /**
   * @description Method to perform database upserts
   * @param records List of records to insert/update
   * @param allowPartialUpdate Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.UpsertResult> Results of upsert operation
   */
  public static List<Database.UpsertResult> upsertRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;

    List<Database.UpsertResult> results = new List<Database.UpsertResult>();
    try {
      results = Database.upsert(records, allowPartialUpdate, accessLevel);
      DMLUtilHelper.processUpsertResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }

    return results;
  }

  /**
   * @description Method to perform database insert
   * @param records List of records to insert
   * @param allowPartialUpdate Boolean value to validate if records should be inserted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   *  @return List<Database.SaveResult> Results of insert operation
   */

  public static List<Database.SaveResult> insertRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;

    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
      results = Database.insert(records, allowPartialUpdate, accessLevel);
      DMLUtilHelper.processResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }

    return results;
  }

  /**
   * @description Method to perform database delete
   * @param records List of records to delete
   * @param allowPartialUpdate Boolean value to validate if records should be deleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.DeleteResult> Results of delete operation
   */

  public static List<Database.DeleteResult> deleteRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;

    List<Database.DeleteResult> results = new List<Database.DeleteResult>();
    try {
      results = Database.delete(records, allowPartialUpdate, accessLevel);
      DMLUtilHelper.processDeleteResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }

    return results;
  }

  /**
   * @description Method to perform database undelete
   * @param records List of records to undelete
   * @param allowPartialUpdate Boolean value to validate if records should be undeleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.UndeleteResult> Results of undelete operation
   */

  public static List<Database.UndeleteResult> undeleteRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;

    List<Database.UndeleteResult> results = new List<Database.UndeleteResult>();
    try {
      results = Database.undelete(records, allowPartialUpdate, accessLevel);
      DMLUtilHelper.processUndeleteResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }

    return results;
  }
}
