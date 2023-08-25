/**
 * @author Adnan
 * @since  08/2023
 * @description Batch class to mask cfms case comments
 */
public class IDRCFMSCaseCommentsMaskingBatch implements Database.Batchable<sObject> {
  private static final String NO_POST_PROCESSING_STEPS_MSG = 'No post processing steps as of now';

  /**
   * @description Get all the task records whose type is Pend Case and withing due date window
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query = 'Select CommentBody from CaseComment where Parent.RecordType.Name = \'CFMS Migrated Case\' AND Parent.Date_Closed__c > 2013-04-30';
    return Database.getQueryLocator(query);
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param caseComments from start method
   */
  public void execute(
    Database.BatchableContext bc,
    List<CaseComment> caseComments
  ) {
    for (CaseComment cc : caseComments) {
      cc.CommentBody = TextUtils.maskData(cc.CommentBody);
    }
    try {
      update caseComments;
    } catch (Exception e) {
      Logger.error(
        'Problem in masking cfms case comment record from batch job : ' +
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
    System.debug(LoggingLevel.debug, NO_POST_PROCESSING_STEPS_MSG);
  }
}
