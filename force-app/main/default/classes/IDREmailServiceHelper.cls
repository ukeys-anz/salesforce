/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains helper methods for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDREmailServiceHelper {
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  /**
   * @description Creates a new case
   * @param email Inbound email object
   * @param senderEmail The email address sent to
   * @param fromEmail The email address recieved from
   * @param caseOrigin The case origin
   */
  public static Case createNewCase(
    Messaging.InboundEmail email,
    String senderEmail,
    String fromEmail,
    String caseOrigin
  ) {
    Case newCase = new Case(
      Description = email.plainTextBody?.replaceAll('<.*>', 'REMOVED'),
      Priority = IDRConstants.CASE_PRIORITY_STANDARD,
      Status = IDRConstants.OPEN_STATUS,
      Subject = email.subject,
      SuppliedEmail = fromEmail,
      IDR_Inbox_Email_Address__c = senderEmail,
      recordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID,
      Origin = caseOrigin
    );
    if (fromEmail == System.Label.ANZ_com_Sender_Address) {
      IDREmailToCase.parseWebFormEmail(newCase);
    }

    AccessCheckUtil.AccessCheckWrapper acw = AccessCheckUtil.checkAccess(
      'Case',
      AccessType.CREATABLE,
      new List<Case>{ newCase }
    );
    if (acw.inAccessibleFields != null) {
      Lib_SystemLog log = new Lib_SystemLog(
        IDREmailServiceHandler.class.getName(),
        'createNewCase'
      );
      log.error(
        'EmailServiceException',
        'User does not have create access to fields --' +
        acw.inAccessibleFields +
        ' Recieved email from : ' +
        fromEmail +
        ' Subject of email : ' +
        email.subject +
        ' Email sent to : ' +
        senderEmail
      );
      log.publishEvent();
    } else {
      try {
        insert newCase;
      } catch (Exception err) {
        Lib_SystemLog log = new Lib_SystemLog(
          IDREmailServiceHandler.class.getName(),
          'createNewCase'
        );
        log.error(
          'EmailServiceException',
          'Error in creating new case from email service class : ' +
          'Recieved email from : ' +
          fromEmail +
          ' Subject of email : ' +
          email.subject +
          ' Email sent to : ' +
          senderEmail +
          err.getMessage()
        );
        log.publishEvent();
      }
    }
    return newCase;
  }
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
      AccessCheckUtil.AccessCheckWrapper acw = AccessCheckUtil.checkAccess(
        'EmailMessage',
        AccessType.CREATABLE,
        new List<EmailMessage>{ emailMessage }
      );
      if (acw.inAccessibleFields != null) {
        CommonUtil.logAndThrowIAE(
          IDREmailServiceHelper.class.getName(),
          'createEmailMessage',
          'User does not have create access to fields -- ' +
          acw.inAccessibleFields
        );
      } else {
        insert emailMessage;
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
