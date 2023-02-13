/**
 * @description       : Util class for DML operations
 * @author            : Prakash B
 * @group             : Util
 * @last modified on  : 30-01-2023
 **/

public inherited sharing class DMLUtil {
  /**
   * @description Method to perform database updates
   * @param records List of records to update
   * @param allowPartialUpdate Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   */
  public static void updateRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;
    try {
      List<Database.SaveResult> results = Database.update(
        records,
        allowPartialUpdate,
        accessLevel
      );
      DMLUtilHelper.processResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }
  }

  /**
   * @description Method to perform database upserts
   * @param records List of records to insert/update
   * @param allowPartialUpdate Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   */
  public static void upsertRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;
    try {
      List<Database.UpsertResult> results = Database.upsert(
        records,
        allowPartialUpdate,
        accessLevel
      );
      DMLUtilHelper.processUpsertResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }
  }

  /**
   * @description Method to perform database insert
   * @param records List of records to insert
   * @param allowPartialUpdate Boolean value to validate if records should be inserted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   */

  public static void insertRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;
    try {
      List<Database.SaveResult> results = Database.insert(
        records,
        allowPartialUpdate,
        accessLevel
      );
      DMLUtilHelper.processResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }
  }

  /**
   * @description Method to perform database delete
   * @param records List of records to delete
   * @param allowPartialUpdate Boolean value to validate if records should be deleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   */

  public static void deleteRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;
    try {
      List<Database.DeleteResult> results = Database.delete(
        records,
        allowPartialUpdate,
        accessLevel
      );
      DMLUtilHelper.processDeleteResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }
  }

  /**
   * @description Method to perform database undelete
   * @param records List of records to undelete
   * @param allowPartialUpdate Boolean value to validate if records should be undeleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   */

  public static void undeleteRecords(
    List<SObject> records,
    Boolean allowPartialUpdate,
    Boolean userLevel
  ) {
    System.AccessLevel accessLevel = userLevel
      ? AccessLevel.USER_MODE
      : AccessLevel.SYSTEM_MODE;
    try {
      List<Database.UndeleteResult> results = Database.undelete(
        records,
        allowPartialUpdate,
        accessLevel
      );
      DMLUtilHelper.processUndeleteResults(results);
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }
  }
}
