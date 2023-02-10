/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Helper class for {@link LogEventBuilder} specialising in DatabaseResult functions
 */

public with sharing class DatabaseResultHelper {
  /**
   * @description Checks if a list of Database.SaveResult is successful, if not return the serialised results with errors
   * @param saveResults A list of save results to check
   * @return Serialised string of the save result
   */
  public static String getSaveResultError(
    List<Database.SaveResult> saveResults
  ) {
    List<DatabaseResult> saveResultErrors = new List<DatabaseResult>();
    for (Database.SaveResult sr : saveResults) {
      if (sr.isSuccess() == false) {
        DatabaseResult resultValue = new DatabaseResult(sr);
        saveResultErrors.add(resultValue);
      }
    }
    String result = saveResultErrors.isEmpty() == false
      ? JSON.serializePretty(saveResultErrors)
      : '';
    return result;
  }

  /**
   * @description Checks if a list of Database.DeleteResult is successful, if not return the serialised results with errors
   * @param deleteResults A list of delete results to check
   * @return Serialised string of the delete result
   */
  public static String getDeleteResultError(
    List<Database.DeleteResult> deleteResults
  ) {
    List<DatabaseResult> deleteResultErrors = new List<DatabaseResult>();
    for (Database.DeleteResult dr : deleteResults) {
      if (dr.isSuccess() == false) {
        DatabaseResult resultValue = new DatabaseResult(dr);
        deleteResultErrors.add(resultValue);
      }
    }
    String result = deleteResultErrors.isEmpty() == false
      ? JSON.serializePretty(deleteResultErrors)
      : '';
    return result;
  }

  /**
   * @description Checks if a list of Database.MergeResult is successful, if not return the serialised results with errors
   * @param mergeResults A list of merge results to check
   * @return Serialised string of the merge result
   */
  public static String getMergeResultError(
    List<Database.MergeResult> mergeResults
  ) {
    List<DatabaseMergeResult> mergeResultErrors = new List<DatabaseMergeResult>();
    for (Database.MergeResult mr : mergeResults) {
      if (mr.isSuccess() == false) {
        DatabaseMergeResult resultValue = new DatabaseMergeResult(mr);
        mergeResultErrors.add(resultValue);
      }
    }
    String result = mergeResultErrors.isEmpty() == false
      ? JSON.serializePretty(mergeResultErrors)
      : '';
    return result;
  }

  /**
   * @description Checks if a list of Database.UpsertResult is successful, if not return the serialised results with errors
   * @param upsertResults A list of upsert results to check
   * @return Serialised string of the upsert result
   */
  public static String getUpsertResultError(
    List<Database.UpsertResult> upsertResults
  ) {
    List<DatabaseUpsertResult> upsertResultErrors = new List<DatabaseUpsertResult>();
    for (Database.UpsertResult ur : upsertResults) {
      if (ur.isSuccess() == false) {
        DatabaseUpsertResult resultValue = new DatabaseUpsertResult(ur);
        upsertResultErrors.add(resultValue);
      }
    }
    String result = upsertResultErrors.isEmpty() == false
      ? JSON.serializePretty(upsertResultErrors)
      : '';
    return result;
  }

  /**
   * @description Checks if a list of Database.UndeleteResult is successful, if not return the serialised results with errors
   * @param undeleteResults A list of undelete results to check
   * @return Serialised string of the undelete result
   */
  public static String getUndeleteResultError(
    List<Database.UndeleteResult> undeleteResults
  ) {
    List<DatabaseResult> undeleteResultErrors = new List<DatabaseResult>();
    for (Database.UndeleteResult ur : undeleteResults) {
      if (ur.isSuccess() == false) {
        DatabaseResult resultValue = new DatabaseResult(ur);
        undeleteResultErrors.add(resultValue);
      }
    }
    String result = undeleteResultErrors.isEmpty() == false
      ? JSON.serializePretty(undeleteResultErrors)
      : '';
    return result;
  }

  /**
   * @description Checks if a list of Database.EmptyRecycleBinResult is successful, if not return the serialised results with errors
   * @param emptyRecycleBinResults A list of empty recycle bin results to check
   * @return Serialised string of the empty recycle bin result
   */
  public static String getEmptyRecycleBinResultError(
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults
  ) {
    List<DatabaseResult> emptyRecycleBinResultErrors = new List<DatabaseResult>();
    for (Database.EmptyRecycleBinResult er : emptyRecycleBinResults) {
      if (er.isSuccess() == false) {
        DatabaseResult resultValue = new DatabaseResult(er);
        emptyRecycleBinResultErrors.add(resultValue);
      }
    }
    String result = emptyRecycleBinResults.isEmpty() == false
      ? JSON.serializePretty(emptyRecycleBinResults)
      : '';
    return result;
  }

  /**
   * @description Wrapper class to contain the database results and the recordId
   * Wrapper created because when the isSuccess = false in database results then record Id is not available on the the result
   */

  private class DatabaseResult {
    private List<Database.Error> errors;
    private Id id;
    private Boolean success;

    /**
     * @description Constructor class for Database.SaveResult
     * @param sr Record which failed during insert process
     */

    private DatabaseResult(Database.SaveResult sr) {
      this.id = sr.getId();
      this.success = sr.isSuccess();
      this.errors = sr.getErrors();
    }

    /**
     * @description Constructor class for Database.DeleteResult
     * @param dr Record which failed during Delete process
     */

    private DatabaseResult(Database.DeleteResult dr) {
      this.id = dr.getId();
      this.success = dr.isSuccess();
      this.errors = dr.getErrors();
    }

    /**
     * @description Constructor class for Database.UndeleteResult
     * @param udr Record which failed during Undelete process
     */

    private DatabaseResult(Database.UndeleteResult udr) {
      this.id = udr.getId();
      this.success = udr.isSuccess();
      this.errors = udr.getErrors();
    }

    /**
     * @description Constructor class for Database.EmptyRecycleBinResult
     * @param er Record which failed during EmptyRecycleBin process
     */

    private DatabaseResult(Database.EmptyRecycleBinResult er) {
      this.id = er.getId();
      this.success = er.isSuccess();
      this.errors = er.getErrors();
    }
  }

  /**
   * @description Wrapper class for the merge result class as it has additional information compared to other result classes
   * Wrapper created because when the isSuccess = false in database results then record Id is not available on the the result
   */

  private class DatabaseMergeResult {
    private List<Database.Error> errors;
    private Id id;
    private Boolean success;
    private List<String> mergedRecordIds;
    private List<String> updatedRelatedIds;

    /**
     * @description Constructor class for Database.MergeResult
     * @param mr Record which failed during Merge process
     */

    private DatabaseMergeResult(Database.MergeResult mr) {
      this.id = mr.getId();
      this.success = mr.isSuccess();
      this.errors = mr.getErrors();
      this.mergedRecordIds = mr.getMergedRecordIds();
      this.updatedRelatedIds = mr.getUpdatedRelatedIds();
    }
  }

  /**
   * @description Wrapper class for the upsert result class as it has additional information compared to other result classes
   * Wrapper created because when the isSuccess = false in database results then record Id is not available on the the result
   */

  private class DatabaseUpsertResult {
    private List<Database.Error> errors;
    private Id id;
    private Boolean success;
    private Boolean created;

    /**
     * @description Constructor class for Database.UpsertResult
     * @param ur Record which failed during Upsert process
     */

    private DatabaseUpsertResult(Database.UpsertResult ur) {
      this.id = ur.getId();
      this.success = ur.isSuccess();
      this.errors = ur.getErrors();
      this.created = ur.isCreated();
    }
  }
}
