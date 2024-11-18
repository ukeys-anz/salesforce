/**
 * @author Manisha
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
    Set<String> allowedCaseRecTypes = new Set<String>{
      RTCase.customerComplaint,
      RTCase.nonCustomerComplaint,
      RTCase.generalInquiryCmos,
      RTCase.systemicIssue
    };
    if (linkedEntityId.isEmpty() || linkId.isEmpty()) {
      return new List<ContentDocumentLink>();
    }
    return [
      SELECT
        Id,
        ContentDocument.Title,
        ContentDocument.LatestPublishedVersion.FileType,
        ContentDocumentId,
        LinkedEntityId,
        TYPEOF LinkedEntity
          WHEN Case THEN CaseNumber, Subject
          ELSE Id
        END
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId IN (
          SELECT Id
          FROM Case
          WHERE
            Id IN :linkedEntityId
            AND RecordTypeId IN :allowedCaseRecTypes
            AND Owner.IsActive = TRUE
        )
        AND Id IN :linkId
    ];
  }
}
