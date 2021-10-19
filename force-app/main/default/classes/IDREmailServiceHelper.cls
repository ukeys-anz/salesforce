/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains helper methods for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDREmailServiceHelper {
  /**
   * @description Creates a new email message record
   * @param email Inbound email object
   * @param caseId The case Id that needs to be related to
   */
  public static void createEmailMessage(
    Messaging.InboundEmail email,
    Id caseId
  ) {
    try {
      EmailMessage emailMessage = new EmailMessage();
      emailMessage.ParentId = caseId;
      emailMessage.FromAddress = email.fromAddress;
      emailMessage.FromName = email.fromName;
      emailMessage.Subject = email.subject;
      emailMessage.HtmlBody = email
        ?.htmlBody
        ?.replaceAll('<a.*<.{1}a>', 'REMOVED');
      emailMessage.TextBody = email?.plainTextBody;
      if (
        Schema.EmailMessage.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.EmailMessage.fields.ParentId.isCreateable() &&
        Schema.sObjectType.EmailMessage.fields.FromAddress.isCreateable() &&
        Schema.sObjectType.EmailMessage.fields.FromName.isCreateable() &&
        Schema.sObjectType.EmailMessage.fields.Subject.isCreateable() &&
        Schema.sObjectType.EmailMessage.fields.HtmlBody.isCreateable()
      ) {
        insert emailMessage;
      } else {
        CommonUtil.logAndThrowIAE(
          IDREmailServiceHelper.class.getName(),
          'createEmailMessage',
          'Not enough permissions to create EmailMessage.'
        );
      }
    } catch (Exception err) {
      Lib_SystemLog log = new Lib_SystemLog(
        IDREmailServiceHelper.class.getName(),
        'createEmailMessage'
      );
      log.error(
        'EmailServiceException',
        'Error in creating email message from service class, which needs to be attached to existing case :' +
        caseId +
        err.getMessage()
      );
      log.publishEvent();
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
        List<Database.SaveResult> results = Database.insert(
          contentVersionList,
          false
        );
        lib_systemLog log = new lib_systemLog(
          'IDREmailServiceHelper',
          'createAttachmentFiles'
        );
        log.addDatabaseSaveResult(
          'ContentVersion',
          results,
          contentVersionList
        );
        log.insertLogAsync();
      } else {
        CommonUtil.logAndThrowIAE(
          IDREmailServiceHelper.class.getName(),
          'createAttachmentFiles',
          'Not enough permissions to create ContentVersion.'
        );
      }
    }

    List<Id> contentVerIds = new List<ID>();
    for (ContentVersion cv : contentVersionList) {
      contentVerIds.add(cv.Id);
    }
    FileUtil.linkContentWithRecord(contentVerIds, caseId);
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
    Lib_SystemLog log = new Lib_SystemLog(
      IDREmailServiceHelper.class.getName(),
      'getTextFileAttachments'
    );
    if (tAttachments != null && tAttachments.size() > 0) {
      for (Messaging.Inboundemail.TextAttachment tAttachment : tAttachments) {
        if (
          FileUtil.checkExtension(
            tAttachment.mimeTypeSubType,
            tAttachment.fileName
          )
        ) {
          ContentVersion cv = new ContentVersion(
            Title = tAttachment.fileName,
            PathOnClient = tAttachment.fileName,
            VersionData = Blob.valueOf(tAttachment.body),
            RecordTypeId = IDRConstants.EMAIL_ATTACHMENT_RT_ID
          );
          returnConVerList.add(cv);
        } else {
          log.error(
            'EmailServiceException',
            'Discarded an attachment as the type was unsupported => filename : ' +
            tAttachment.fileName +
            ' , mimesubtype : ' +
            tAttachment.mimeTypeSubType +
            ', For the case : ' +
            caseId
          );
        }
      }
    }
    log.publishEvent();
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
    Lib_SystemLog log = new Lib_SystemLog(
      IDREmailServiceHelper.class.getName(),
      'getTextBinaryAttachments'
    );
    if (bAttachments != null && bAttachments.size() > 0) {
      for (Messaging.Inboundemail.BinaryAttachment bAttachment : bAttachments) {
        if (
          FileUtil.checkExtension(
            bAttachment.mimeTypeSubType,
            bAttachment.fileName
          )
        ) {
          ContentVersion cv = new ContentVersion(
            Title = bAttachment.fileName,
            PathOnClient = bAttachment.fileName,
            VersionData = bAttachment.body,
            RecordTypeId = IDRConstants.EMAIL_ATTACHMENT_RT_ID
          );
          returnConVerList.add(cv);
        } else {
          log.error(
            'EmailServiceException',
            'Discarded a binary attachment as the type was unsupported => filename : ' +
            bAttachment.fileName +
            ' , mimesubtype : ' +
            bAttachment.mimeTypeSubType +
            ', For the case : ' +
            caseId
          );
        }
      }
    }
    log.publishEvent();
    return returnConVerList;
  }
}
