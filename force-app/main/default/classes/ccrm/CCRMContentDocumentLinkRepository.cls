/**
 * @author Naman Garg
 * @since 06/2024
 * @description This class provide SOQL and DML helper for class related to CCRMContentDocumentLinkActions.
 */

public with sharing class CCRMContentDocumentLinkRepository {
  /**
   * @description return EmailMessage Map using profileName and List of Ids
   * @param emailMessageIds List of EmailMessage Ids
   * @param profileNames List of profileName of EmailMessage Creator
   * @return Map<Id, EmailMessage>
   * @US CC-1893
   */
  public Map<Id, EmailMessage> getEmailMessageUsingProfileName(
    List<Id> emailMessageIds,
    List<String> profileNames
  ) {
    if (emailMessageIds.isEmpty() || profileNames.isEmpty()) {
      return new Map<Id, EmailMessage>();
    }
    return new Map<Id, EmailMessage>(
      [
        SELECT
          Id,
          FromAddress,
          CcAddress,
          ToAddress,
          Incoming,
          CreatedBy.Profile_Name__c,
          Attachment_Notes__c
        FROM EmailMessage
        WHERE
          Createdby.Profile_Name__c IN :profileNames
          AND Id IN :emailMessageIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description return ContentDocuments using contentDocs Ids
   * @param contentDocsIds List of ContentDocument Ids
   * @return List<ContentDocument>
   */
  public List<ContentDocument> getContentDocuments(Set<Id> contentDocsIds) {
    if (contentDocsIds.isEmpty()) {
      return new List<ContentDocument>();
    }
    return [
      SELECT id
      FROM ContentDocument
      WHERE id IN :contentDocsIds
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description return Content Versions using recordtypes and cdList
   * @param cdList list of ContentDocument
   * @return List<ContentVersion>
   */
  public List<ContentVersion> getCVList(List<ContentDocument> cdList) {
    return [
      SELECT ContentDocumentId, RecordTypeId
      FROM ContentVersion
      WHERE
        (RecordTypeID IN :ContentDocumentTriggerActions.CONTENT_VERSION_RT
        OR RecordTypeID = NULL)
        AND ContentDocumentId IN :cdList
    ];
  }

  /**
   * @description return Content Document Links using Content Document Ids
   * @param contentDocIdList list of ContentDocument Ids
   * @return List<ContentDocumentLink>
   */
  public List<ContentDocumentLink> getCDL(Set<Id> contentDocIdList) {
    return [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE ContentDocumentId IN :contentDocIdList
    ];
  }
}
