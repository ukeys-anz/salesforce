/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains helper methods for IDREmailService class
 */
public with sharing class IDREmailServiceHelper {
  /**
   * @description Creates a new email message record
   * @param email Inbound email object
   * @param caseId The case Id that needs to be related to
   */
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) //Since we ApexCRUD cannot be done on emailMessage object
  public static void createEmailMessage(
    Messaging.InboundEmail email,
    Id caseId
  ) {
    EmailMessage emailMessage = new EmailMessage();
    emailMessage.parentId = caseId;
    emailMessage.fromAddress = email.fromAddress;
    emailMessage.fromName = email.fromName;
    emailMessage.subject = email.subject;
    emailMessage.htmlBody = email.htmlBody.replaceAll('<a.*<.{1}a>', 'REMOVED');
    if (Case.sObjectType.getDescribe().isCreateable()) {
      insert emailMessage;
    }
  }

  /**
   * @description Creates attachment/files from the email attachment
   * @param email Inbound email object
   * @param caseId The case Id that needs to be related to
   */
  @SuppressWarnings(
    'PMD.CyclomaticComplexity'
  ) //Since the method is already refined to reduce complexity
  public static void createAttachmentFiles(
    Messaging.InboundEmail email,
    Id caseId
  ) {
    List<Messaging.Inboundemail.TextAttachment> tAttachments = email.textAttachments;
    List<Messaging.Inboundemail.BinaryAttachment> bAttachments = email.binaryAttachments;
    List<ContentVersion> contentVersionList = new List<ContentVersion>();
    if (tAttachments != null && tAttachments.size() > 0) {
      for (Messaging.Inboundemail.TextAttachment tAttachment : tAttachments) {
        if (checkExtension(tAttachment.mimeTypeSubType)) {
          ContentVersion cv = new ContentVersion(
            Title = tAttachment.fileName,
            PathOnClient = tAttachment.fileName,
            VersionData = Blob.valueOf(tAttachment.body)
          );
          contentVersionList.add(cv);
        } else {
          System.debug(
            LoggingLevel.DEBUG,
            'Discarded   a   text   file   ' + tAttachment.fileName
          );
        }
      }
    }

    if (bAttachments != null && bAttachments.size() > 0) {
      for (Messaging.Inboundemail.BinaryAttachment bAttachment : bAttachments) {
        if (checkExtension(bAttachment.mimeTypeSubType)) {
          ContentVersion cv = new ContentVersion(
            Title = bAttachment.fileName,
            PathOnClient = bAttachment.fileName,
            VersionData = bAttachment.body
          );
          contentVersionList.add(cv);
        } else {
          System.debug(
            LoggingLevel.DEBUG,
            'Discarded   a   binary   file   ' + bAttachment.fileName
          );
        }
      }
    }
    if (ContentVersion.sObjectType.getDescribe().isCreateable()) {
      insert contentVersionList;
    }

    //Call queueable apex to do linking
    List<Id> contentVerIds = new List<ID>();
    for (ContentVersion cv : contentVersionList) {
      contentVerIds.add(cv.Id);
    }
    linkContentWithCase(contentVerIds, caseId);
  }

  /**
   * @description Checks the extension of attachments
   * @param mimeType Mime type of attachments
   * @return Boolean return true/false if the extension is valid
   */
  public static Boolean checkExtension(String mimeType) {
    List<String> extensions = getExtensions(mimeType);
    if (extensions != null) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Gets the extension of attachments
   * @param mimeType Mime type of attachments
   * @return List<String> List of extension type
   */
  public static List<String> getExtensions(String mimeType) {
    if (mimeTypeToFileExtensionsMap.containsKey(mimeType)) {
      return mimeTypeToFileExtensionsMap.get(mimeType).split(',');
    }
    return null;
  }

  private static Map<String, String> mimeTypeToFileExtensionsMap = new Map<String, String>{
    'text/plain' => 'txt,text,conf,def,list,log,in',
    'application/pdf' => 'pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx,doc',
    'image/tiff' => 'tiff,tif',
    'image/jpeg' => 'jpeg,jpg',
    'image/gif' => 'gif',
    'image/bmp' => 'bmp',
    'image/png' => 'png',
    'application/vnd.ms-excel' => 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx,xlsb',
    'application/vnd.ms-powerpoint' => 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
    'application/octet-stream' => 'msg',
    'application/vnd.ms-outlook' => 'eml',
    'text/csv' => 'csv',
    'application/zip' => 'zip'
  };

  /**
   * @description Future method to link attachment with case records
   * @param contentVerIds Content Version Ids
   * @param caseId The case Id that needs to be related to
   */
  @future
  public static void linkContentWithCase(List<Id> contentVerIds, Id caseId) {
    List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
    List<ContentVersion> contentVersionList;
    if (ContentVersion.sObjectType.getDescribe().isQueryable()) {
      contentVersionList = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE Id IN :contentVerIds
      ];
    }
    if (contentVersionList.size() > 0) {
      for (ContentVersion cv : contentVersionList) {
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = caseId;
        contentLink.ContentDocumentId = cv.ContentDocumentId;
        contentLink.shareType = 'V';
        contentDocLinkList.add(contentLink);
      }
    }

    if (contentDocLinkList.size() > 0) {
      if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) {
        insert contentDocLinkList;
      }
    }
  }
}
