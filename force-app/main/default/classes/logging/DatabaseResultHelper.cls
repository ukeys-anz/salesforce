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
      if (sr.isSuccess() == false) {
        saveResultErrors.add(sr);
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
    List<Database.DeleteResult> deleteResultErrors = new List<Database.DeleteResult>();
    for (Database.DeleteResult dr : deleteResults) {
      if (dr.isSuccess() == false) {
        deleteResultErrors.add(dr);
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
    List<Database.MergeResult> mergeResultErrors = new List<Database.MergeResult>();
    for (Database.MergeResult mr : mergeResults) {
      if (mr.isSuccess() == false) {
        mergeResultErrors.add(mr);
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
    List<Database.UpsertResult> upsertResultErrors = new List<Database.UpsertResult>();
    for (Database.UpsertResult ur : upsertResults) {
      if (ur.isSuccess() == false) {
        upsertResultErrors.add(ur);
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
    List<Database.UndeleteResult> undeleteResultErrors = new List<Database.UndeleteResult>();
    for (Database.UndeleteResult ur : undeleteResults) {
      if (ur.isSuccess() == false) {
        undeleteResultErrors.add(ur);
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
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResultErrors = new List<Database.EmptyRecycleBinResult>();
    for (Database.EmptyRecycleBinResult er : emptyRecycleBinResults) {
      if (er.isSuccess() == false) {
        emptyRecycleBinResultErrors.add(er);
      }
    }
    String result = emptyRecycleBinResults.isEmpty() == false
      ? JSON.serializePretty(emptyRecycleBinResults)
      : '';
    return result;
  }
}
