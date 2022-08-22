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
    List<Database.SaveResult> saveResultErrors = new List<Database.SaveResult>();
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        saveResultErrors.add(sr);
      }
    }
    String result = saveResultErrors.size() > 0
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
    List<Database.DeleteResult> deleteResultErrors = new List<Database.DeleteResult>();
    for (Database.DeleteResult dr : deleteResults) {
      if (!dr.isSuccess()) {
        deleteResultErrors.add(dr);
      }
    }
    String result = deleteResultErrors.size() > 0
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
    List<Database.MergeResult> mergeResultErrors = new List<Database.MergeResult>();
    for (Database.MergeResult mr : mergeResults) {
      if (!mr.isSuccess()) {
        mergeResultErrors.add(mr);
      }
    }
    String result = mergeResultErrors.size() > 0
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
    List<Database.UpsertResult> upsertResultErrors = new List<Database.UpsertResult>();
    for (Database.UpsertResult ur : upsertResults) {
      if (!ur.isSuccess()) {
        upsertResultErrors.add(ur);
      }
    }
    String result = upsertResultErrors.size() > 0
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
    List<Database.UndeleteResult> undeleteResultErrors = new List<Database.UndeleteResult>();
    for (Database.UndeleteResult ur : undeleteResults) {
      if (!ur.isSuccess()) {
        undeleteResultErrors.add(ur);
      }
    }
    String result = undeleteResultErrors.size() > 0
      ? JSON.serializePretty(undeleteResultErrors)
      : '';
    return result;
  }
}
