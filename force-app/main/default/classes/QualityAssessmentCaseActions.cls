/**
 * @author Victor Wang
 * @since 08/2021
 * @description QualityAssessmentCaseActions class is to handle Quality Assessment Case related actions
 */
public with sharing class QualityAssessmentCaseActions {
  /**
   * @description method to decide if a case has ever been closed or not
   * @param record case record to decide
   * @return Boolean
   */
  public static Boolean isCaseClosedOnce(Case record) {
    return record != null && record.Closed_Once__c == true;
  }

  /**
   * @description method to set case Closed Once field to true. As this method will be invoked in a AfterTrigger context, have to new a record instead of reusing existing one. The invoking in a AfterTrigger decision is made due to the Apex Order to Execution
   * @param records case records
   * @return List<Case> a new case list with Closed Once field set as true
   */
  public static List<Case> setCaseClosedOnce(List<Case> records) {
    if (records == null || records.size() == 0) {
      return null;
    }

    List<Case> updatedRecords = new List<Case>();

    for (Case record : records) {
      updatedRecords.add(new Case(Id = record.Id, Closed_Once__c = true));
    }

    return updatedRecords;
  }

  /**
   * @description method to update case records' Ever Closed field to true
   * @param records case records to update
   */
  public static void updateCaseClosedOnce(List<Case> records) {
    if (records == null || records.size() == 0) {
      return;
    }

    List<Database.SaveResult> results = Database.Update(records, false);

    //log errors to application log
    lib_systemLog log = new lib_systemLog(
      'QualityAssessmentActions',
      'updateCaseClosedOnce'
    );

    log.addDatabaseSaveResult('Cases', results, records);

    log.insertLogAsync();
  }
}
