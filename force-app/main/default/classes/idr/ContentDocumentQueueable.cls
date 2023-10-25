/**
 * @author Greg Shaw (shawg2)
 * @since 10/2023
 * @description Delete ContentDocument in batches from static resource
 * @group IDR(Internal Dispute Resolution)
 */

public with sharing class ContentDocumentQueueable implements Queueable {
  private final Set<Id> stDocumentIds;

  /**
   * @description default constructor. Load static resource
   */
  public ContentDocumentQueueable() {
    List<StaticResource> lstLogDeletions = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'LogDeletionExport'
    ];
    stDocumentIds = new Set<Id>();
    if (lstLogDeletions.size() > 0) {
      for (
        String strDocumentId : lstLogDeletions[0].Body.toString().split('\r\n')
      ) {
        if ( strDocumentId.startsWith('069')) {
          stDocumentIds.add(strDocumentId);
        }
      }
    }
  }

  /**
   * @description Parameterised constructor for use by previous ContentDocumentQueueable iteration
   * @param stDocumentIds initialiser for stDDocumentIds member variable
   */
  public ContentDocumentQueueable(Set<Id> stDocumentIds) {
    this.stDocumentIds = stDocumentIds;
  }

  /**
   * @description Delete batch of ContentDocument records and call next iteration
   * @param context Queueable context unused.
   */
  public void execute(QueueableContext context) {
    if (ContentDocument.getSObjectType().getDescribe().isDeletable() &&
        stDocumentIds != null &&
        stDocumentIds.size() > 0) {
      Set<Id> stIds = new Set<Id>();
      for (String strDocumentId : stDocumentIds) {
        if (stIds.size() < 2000) {
          stIds.add(strDocumentId);
        }
      }
      List<ContentDocument> lstDocuments = [
        SELECT Id
        FROM ContentDocument
        WHERE Id IN :stIds
      ];
      if ( lstDocuments.size() > 0 ) {
        delete lstDocuments;
      }
      stDocumentIds.removeAll(stIds);
      System.debug('DocumentIds: ' + stDocumentIds.size());
      System.enqueueJob(new ContentDocumentQueueable(stDocumentIds));
    }
  }
}
