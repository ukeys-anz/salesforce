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

  /**
   * @description return EmailMessage Map using profileName and List of Ids
   * @param emailMessageIds List of EmailMessage Ids
   * @param profileNames List of profileName of EmailMessage Creator
   * @return Map<Id, EmailMessage>
   * @US CC-1893
   */
  public Map<Id, EmailMessage> getEmailMessageUsingProfileName(
    Set<Id> emailMessageIds,
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
      WITH USER_MODE
    ];
  }

  /**
   * @description return Content Versions using recordtypes and cdList
   * @param cdList list of ContentDocument
   * @param cvRecordTypes list of recordtypes
   * @return List<ContentVersion>
   */
  public List<ContentVersion> getCVList(
    List<ContentDocument> cdList,
    List<Id> cvRecordTypes
  ) {
    if (cdList.isEmpty() || cvRecordTypes.isEmpty()) {
      return new List<ContentVersion>();
    }
    return [
      SELECT ContentDocumentId, RecordTypeId
      FROM ContentVersion
      WHERE
        (RecordTypeID IN :cvRecordTypes
        OR RecordTypeID = NULL)
        AND ContentDocumentId IN :cdList
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description return Content Document Link using cdList
   * @param cdList list of ContentDocument
   * @return List<ContentDocumentLink>
   */
  public List<ContentDocumentLink> getCdlList(Set<Id> cdList) {
    if (cdList.isEmpty()) {
      return new List<ContentDocumentLink>();
    }
    return [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE ContentDocumentId IN :cdList
      WITH USER_MODE
    ];
  }
}
