/**
 * @author Hitesh W
 * @since  10/2023
 * @description Deletes ContentDocuments in async way when uploaded from Outlook by ML User
 * @test class - ContentDocumentLinkTriggerHandler
 */
public class MLCRMContentDocDeleteQueueable implements Queueable {
  public List<Id> contentDocsToDelete;

  /**
   * @description onAfterInsert: After Insert actions.
   * @param records - ContentDocumentIds List to be deleted
   */
  public MLCRMContentDocDeleteQueueable(List<Id> records) {
    contentDocsToDelete = records;
  }

  /**
   * @description onAfterInsert: After Insert actions.
   * @param context contex variable
   */
  public void execute(QueueableContext context) {
    List<ContentDocument> cds = [
      SELECT id
      FROM ContentDocument
      WHERE id IN :contentDocsToDelete
    ];
    delete cds;
  }
}
