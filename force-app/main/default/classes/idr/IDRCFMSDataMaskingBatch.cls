/**
 * @author Adnan
 * @since  08/2023
 * @description Batch class to mask cfms cases
 */
public class IDRCFMSDataMaskingBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all the task records whose type is Pend Case and withing due date window
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query = 'Select Id, IDR_Account_Card_Policy_Number__c, IDR_Account_Card_Policy_Number_2__c, IDR_Account_Card_Policy_Number_3__c, Description, IDR_Complainant_Desired_Outcome__c, IDR_Description_of_Outcome__c, IDR_Systemic_Issue_Description__c, IDR_Other_Remedy_Provided__c, IDR_Other_Remedy_Provided_2__c, IDR_Other_Remedy_Provided_3__c, How_has_delay_criteria_been_met_not_met__c, Subject, IDR_Masked_CFMS__c  from Case where RecordType.Name = \'CFMS Migrated Case\' AND IsClosed = True AND Date_Closed__c > 2013-04-30 AND IDR_Masked_CFMS__c = False';
    return Database.getQueryLocator(query);
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param cfmsCaseList from start method
   */
  public void execute(Database.BatchableContext bc, List<Case> cfmsCaseList) {
    for (Case c : cfmsCaseList) {
      CommonUtil.handleMasking(
        c,
        null,
        SObjectType.Case.FieldSets.IDR_Masked_Fields.getFields()
      );
      c.IDR_Masked_CFMS__c = true;
    }
    try {
      update cfmsCaseList;
    } catch (Exception e) {
      Logger.error(
        'Problem in masking cfms record from batch job : ' +
        bc.getJobId() +
        e.getMessage(),
        e
      );
      Logger.saveLog();
    }
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
    Database.executeBatch(new IDRCFMSCaseCommentsMaskingBatch(), 2000);
  }
}
