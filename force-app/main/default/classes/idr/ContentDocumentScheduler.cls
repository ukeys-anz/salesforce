/**
 * @author Greg Shaw (shawg2)
 * @since 10/2023
 * @description Schedule ContentDocumentBatch
 * @group IDR(Internal Dispute Resolution)
 */

public with sharing class ContentDocumentScheduler implements Schedulable {

  /**
   * @description Execute the ContentDocumentBatch
   * @param context SchedulableContext unused
   */
  public void execute(SchedulableContext context) {

    Database.executeBatch(new ContentDocumentBatch());
  }
}