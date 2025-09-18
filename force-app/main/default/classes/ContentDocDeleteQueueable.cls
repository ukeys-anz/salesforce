/**
 * @author Hitesh W
 * @since  10/2023
 * @description Deletes ContentDocuments in async way when uploaded from Outlook by ML User
 * @test class - ContentDocumentLinkTriggerHandler
 */
public class ContentDocDeleteQueueable implements Queueable {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final ContentDocumentLinkRepository CDL_REPOSITORY = (ContentDocumentLinkRepository) Lib_InstanceProvider.forType(
    ContentDocumentLinkRepository.class
  );
  public List<Id> contentDocsToDelete;

  /**
   * @description onAfterInsert: After Insert actions.
   * @param records - ContentDocumentIds List to be deleted
   */
  public ContentDocDeleteQueueable(List<Id> records) {
    contentDocsToDelete = records;
  }

  /**
   * @description onAfterInsert: After Insert actions.
   * @param context contex variable
   */
  public void execute(QueueableContext context) {
    List<ContentDocument> contentDocListToDelete = CDL_REPOSITORY.getContentDocuments(
      new Set<Id>(contentDocsToDelete)
    );
    DML_REPOSITORY.doDelete(
      contentDocListToDelete,
      new DmlConfig().allowPartial().systemMode()
    );
  }
}
