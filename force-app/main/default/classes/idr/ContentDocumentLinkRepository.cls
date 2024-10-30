/**
 * @since 10/2024
 * @description This class provides SOQL and DML helpers for classes related ContentDocumentLinkTriggerHandler.
 * @runTests ContentDocumentLinkTriggerHandlerTest
 */
public with sharing class ContentDocumentLinkRepository {
  /**
   * @description Query PEND Tasks whose Status is not completed
   * @param linkedEntityId Linked Entity Ids in current context
   * @param linkId Document link Ids in current context
   * @return list of Content Document Link
   */
  public List<ContentDocumentLink> queryContentDocumentLink(
    Set<Id> linkedEntityId,
    Set<Id> linkId
  ) {
    if (linkedEntityId.isEmpty() && linkId.isEmpty()) {
      return new List<ContentDocumentLink>();
    }
    return [
      SELECT
        Id,
        ContentDocument.Title,
        LinkedEntityId,
        ContentDocument.LatestPublishedVersion.FileType,
        ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :linkedEntityId AND Id IN :linkId
      WITH USER_MODE
    ];
  }
}
