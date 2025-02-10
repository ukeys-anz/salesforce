/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Helper class for {@link LogEventBuilder} specialising in DatabaseResult functions
 */

public with sharing class DatabaseResultHelper {
  public static final Set<StatusCode> IGNORED_CODES = new Set<StatusCode>{
    StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION
  };
  /**
   * @description Checks if a list of Database.SaveResult is successful, if not return the serialised results with errors
   * @param saveResults A list of save results to check
   * @return Serialised string of the save result
   */
  public static String getSaveResultError(
    List<Database.SaveResult> saveResults
  ) {
    List<DatabaseResult> errorResults = new List<DatabaseResult>();
    for (Database.SaveResult dbResult : saveResults) {
      if (dbResult.success) {
        continue;
      }
      DatabaseResult apexResult = new DatabaseResult(dbResult);
      if (apexResult.filteredErrors.isEmpty() == false) {
        errorResults.add(apexResult);
      }
    }
    return serializeResults(errorResults);
  }

  /**
   * @description Checks if a list of Database.DeleteResult is successful, if not return the serialised results with errors
   * @param deleteResults A list of delete results to check
   * @return Serialised string of the delete result
   */
  public static String getDeleteResultError(
    List<Database.DeleteResult> deleteResults
  ) {
    List<DatabaseResult> errorResults = new List<DatabaseResult>();
    for (Database.DeleteResult dbResult : deleteResults) {
      if (dbResult.success) {
        continue;
      }
      DatabaseResult apexResult = new DatabaseResult(dbResult);
      if (apexResult.filteredErrors.isEmpty() == false) {
        errorResults.add(apexResult);
      }
    }
    return serializeResults(errorResults);
  }

  /**
   * @description Checks if a list of Database.MergeResult is successful, if not return the serialised results with errors
   * @param mergeResults A list of merge results to check
   * @return Serialised string of the merge result
   */
  public static String getMergeResultError(
    List<Database.MergeResult> mergeResults
  ) {
    List<DatabaseMergeResult> errorResults = new List<DatabaseMergeResult>();
    for (Database.MergeResult dbResult : mergeResults) {
      if (dbResult.success) {
        continue;
      }
      DatabaseMergeResult apexResult = new DatabaseMergeResult(dbResult);
      if (apexResult.filteredErrors.isEmpty() == false) {
        errorResults.add(apexResult);
      }
    }
    return serializeResults(errorResults);
  }

  /**
   * @description Checks if a list of Database.UpsertResult is successful, if not return the serialised results with errors
   * @param upsertResults A list of upsert results to check
   * @return Serialised string of the upsert result
   */
  public static String getUpsertResultError(
    List<Database.UpsertResult> upsertResults
  ) {
    List<DatabaseUpsertResult> errorResults = new List<DatabaseUpsertResult>();
    for (Database.UpsertResult dbResult : upsertResults) {
      if (dbResult.success) {
        continue;
      }
      DatabaseUpsertResult apexResult = new DatabaseUpsertResult(dbResult);
      if (apexResult.filteredErrors.isEmpty() == false) {
        errorResults.add(apexResult);
      }
    }
    return serializeResults(errorResults);
  }

  /**
   * @description Checks if a list of Database.UndeleteResult is successful, if not return the serialised results with errors
   * @param undeleteResults A list of undelete results to check
   * @return Serialised string of the undelete result
   */
  public static String getUndeleteResultError(
    List<Database.UndeleteResult> undeleteResults
  ) {
    List<DatabaseResult> errorResults = new List<DatabaseResult>();
    for (Database.UndeleteResult dbResult : undeleteResults) {
      if (dbResult.success) {
        continue;
      }
      DatabaseResult apexResult = new DatabaseResult(dbResult);
      if (apexResult.filteredErrors.isEmpty() == false) {
        errorResults.add(apexResult);
      }
    }
    return serializeResults(errorResults);
  }

  /**
   * @description Checks if a list of Database.EmptyRecycleBinResult is successful, if not return the serialised results with errors
   * @param emptyRecycleBinResults A list of empty recycle bin results to check
   * @return Serialised string of the empty recycle bin result
   */
  public static String getEmptyRecycleBinResultError(
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults
  ) {
    List<DatabaseResult> errorResults = new List<DatabaseResult>();
    for (Database.EmptyRecycleBinResult dbResult : emptyRecycleBinResults) {
      if (dbResult.success) {
        continue;
      }
      DatabaseResult apexResult = new DatabaseResult(dbResult);
      if (apexResult.filteredErrors.isEmpty() == false) {
        errorResults.add(apexResult);
      }
    }
    return serializeResults(errorResults);
  }

  /**
   * @description Serializes a list of Apex objects into a pretty-printed JSON string if list has elements.
   * @param apexResults The list of Apex objects to serialize.
   * @return A pretty-printed JSON string representation of the list, or an empty string if the list is empty.
   */
  private static String serializeResults(List<Object> apexResults) {
    return apexResults.isEmpty() ? '' : JSON.serializePretty(apexResults);
  }

  /**
   * @description Base wrapper class providing basic database results data and filtering errors in accordance with IGNORED_CODES
   */
  private virtual class DatabaseResultBase {
    private Id id;
    private Boolean success;
    private List<Database.Error> errors;
    private transient List<Database.Error> filteredErrors {
      get {
        if (this.filteredErrors != null) {
          return this.filteredErrors;
        }
        this.filteredErrors = new List<Database.Error>();
        for (Database.Error error : errors) {
          if (IGNORED_CODES.contains(error.statuscode) == false) {
            this.filteredErrors.add(error);
          }
        }
        return this.filteredErrors;
      }
      set;
    }
  }

  /**
   * @description Wrapper class to contain the database results and the recordId
   * Wrapper created because when the isSuccess = false in database results then record Id is not available on the the result
   */
  private class DatabaseResult extends DatabaseResultBase {
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

  private class DatabaseMergeResult extends DatabaseResultBase {
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

  private class DatabaseUpsertResult extends DatabaseResultBase {
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
