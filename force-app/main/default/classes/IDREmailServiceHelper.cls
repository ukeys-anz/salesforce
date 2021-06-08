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
  public static void createAttachmentFiles(
    Messaging.InboundEmail email,
    Id caseId
  ) {
    List<Messaging.Inboundemail.TextAttachment> tAttachments = email.textAttachments;
    List<Messaging.Inboundemail.BinaryAttachment> bAttachments = email.binaryAttachments;
    List<ContentVersion> contentVersionList = new List<ContentVersion>();

    //Get all text attachments
    contentVersionList.addAll(getTextFileAttachments(tAttachments, caseId));
    //Get all binary attachments
    contentVersionList.addAll(getTextBinaryAttachments(bAttachments, caseId));

    if (contentVersionList.size() > 0) {
      if (ContentVersion.sObjectType.getDescribe().isCreateable()) {
        insert contentVersionList;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDREmailServiceHelper',
          'createAttachmentFiles',
          'Not enough permissions to create ContentVersion.'
        );
      }
    }

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
    'application/rtf' => 'rtf',
    'text/rtf' => 'rtf',
    'application/pdf' => 'pdf',
    'application/msword' => 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'image/tiff' => 'tiff,tif',
    'image/jpeg' => 'jpeg,jpg',
    'image/gif' => 'gif',
    'image/bmp' => 'bmp',
    'image/png' => 'png',
    'application/vnd.ms-excel' => 'xls',
    'application/octet-stream' => 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx',
    'application/vnd.ms-excel.sheet.binary.macroenabled.12' => 'xlsb',
    'application/vnd.ms-powerpoint' => 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
    'message/rfc822' => 'eml',
    'application/vnd.ms-outlook' => 'msg',
    'text/csv' => 'csv',
    'application/zip' => 'zip',
    'application/x-zip-compressed' => 'zip'
  };

  /**
   * @description method to link attachment with case records
   * @param contentVerIds Content Version Ids
   * @param caseId The case Id that needs to be related to
   */
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

  /**
   * @description Gets the filtered string using Regular Expression
   * @param pattern The RegEx pattern
   * @param matcher The string with which the matching is performed
   * @return returnString The filtered String
   */
  public static String filterStringUsingRegEx(String pattern, String matcher) {
    String returnString;
    Matcher m = System.Pattern.compile(pattern).matcher(matcher);
    if (m.find()) {
      if (pattern == IDRConstants.CASE_NO_REGEX) {
        returnString = m.group().leftPad(8, '0');
      } else {
        returnString = m.group();
      }
    } else {
      returnString = matcher;
    }
    return returnString;
  }

  /**
   * @description Queries through the group object
   * @param type The type of group
   * @param queueName The devveloper name of group
   * @return List<Group>
   */
  public static List<Group> getGroupDetails(String type, String queueName) {
    if (Group.sObjectType.getDescribe().isQueryable()) {
      return [
        SELECT Id
        FROM Group
        WHERE Type = :type AND developername = :queueName
        LIMIT 1
      ];
    } else {
      return null;
    }
  }

  /**
   * @description Fetches the text attachments from the email
   * @param tAttachments The messaging inbound email text attachments
   * @param caseId The case Id that needs to be related to
   * @return List<ContentVersion> Wraps through content version
   */
  public static List<ContentVersion> getTextFileAttachments(
    List<Messaging.Inboundemail.TextAttachment> tAttachments,
    Id caseId
  ) {
    List<ContentVersion> returnConVerList = new List<ContentVersion>();
    if (tAttachments != null && tAttachments.size() > 0) {
      for (Messaging.Inboundemail.TextAttachment tAttachment : tAttachments) {
        if (checkExtension(tAttachment.mimeTypeSubType)) {
          ContentVersion cv = new ContentVersion(
            Title = tAttachment.fileName,
            PathOnClient = tAttachment.fileName,
            VersionData = Blob.valueOf(tAttachment.body)
          );
          returnConVerList.add(cv);
        } else {
          Lib_SystemLog.logAPIError(
            IDREmailServiceHelper.class.getName(),
            'Discarded an attachment as the type was unsupported => filename : ' +
            tAttachment.fileName +
            ' , mimesubtype : ' +
            tAttachment.mimeTypeSubType +
            ', For the case : ' +
            caseId,
            null,
            null,
            IDREmailServiceHelper.class.getName(),
            null,
            null
          );
        }
      }
    }
    return returnConVerList;
  }

  /**
   * @description Fetches the text attachments from the email
   * @param bAttachments The messaging inbound email binary attachments
   * @param caseId The case Id that needs to be related to
   * @return List<ContentVersion> Wraps through content version
   */
  public static List<ContentVersion> getTextBinaryAttachments(
    List<Messaging.Inboundemail.BinaryAttachment> bAttachments,
    Id caseId
  ) {
    List<ContentVersion> returnConVerList = new List<ContentVersion>();
    if (bAttachments != null && bAttachments.size() > 0) {
      for (Messaging.Inboundemail.BinaryAttachment bAttachment : bAttachments) {
        if (checkExtension(bAttachment.mimeTypeSubType)) {
          ContentVersion cv = new ContentVersion(
            Title = bAttachment.fileName,
            PathOnClient = bAttachment.fileName,
            VersionData = bAttachment.body
          );
          returnConVerList.add(cv);
        } else {
          Lib_SystemLog.logAPIError(
            IDREmailServiceHelper.class.getName(),
            'Discarded a binary attachment as the type was unsupported => filename : ' +
            bAttachment.fileName +
            ' , mimesubtype : ' +
            bAttachment.mimeTypeSubType +
            ', For the case : ' +
            caseId,
            null,
            null,
            IDREmailServiceHelper.class.getName(),
            null,
            null
          );
        }
      }
    }
    return returnConVerList;
  }

  /**
   * @description Updates the case with queue
   * @param newCase The case record
   */
  public static void updateCaseWithQueue(Case newCase) {
    //Get Indexing Queue
    List<Group> queueList = getGroupDetails('Queue', 'Indexing_Queue');
    if (queueList.size() > 0 && Case.sObjectType.getDescribe().isUpdateable()) {
      newCase.OwnerId = queueList[0].Id;
      try {
        update newCase;
      } catch (Exception err) {
        Lib_SystemLog.logAPIError(
          IDREmailServiceHandler.class.getName(),
          'Error in updating case with queue for caseId :' + newCase.Id,
          err.getMessage(),
          null,
          IDREmailServiceHandler.class.getName(),
          null,
          null
        );
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'IDREmailServiceHelper',
        'updateCaseWithQueue',
        'Case is not updateable for the current user.'
      );
    }
  }
}
