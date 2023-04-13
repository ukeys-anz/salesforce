/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains helper methods for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDREmailServiceTest
 */
public with sharing class IDREmailServiceHelper {
  /**
   * @description Creates a new case
   * @param email Inbound email object
   * @param senderEmail The email address sent to
   * @param fromEmail The email address recieved from
   * @param caseOrigin The case origin
   * @return Case record
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
      Subject = email.subject,
      SuppliedEmail = fromEmail,
      IDR_Inbox_Email_Address__c = senderEmail.Abbreviate(80),
      RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID,
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
      Logger.error(
        'No create access to fields --' +
        acw.inAccessibleFields +
        ' From: ' +
        fromEmail +
        ' Subject: ' +
        email.subject +
        ' To: ' +
        senderEmail
      );
      Logger.saveLog();
    } else {
      try {
        insert newCase;
      } catch (Exception err) {
        Logger.error(
          'From: ' +
          fromEmail +
          ' Subject: ' +
          email.subject +
          ' To: ' +
          senderEmail,
          err
        );
        Logger.saveLog();
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
      Logger.error(
        'EmailServiceException: ' +
        'Error in creating email message from service class, which needs to be attached to existing case :',
        caseId,
        err
      );
      Logger.saveLog();
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
    List<Messaging.InboundEmail.TextAttachment> tAttachments = email.textAttachments;
    List<Messaging.InboundEmail.BinaryAttachment> bAttachments = email.binaryAttachments;
    List<ContentVersion> contentVersionList = new List<ContentVersion>();

    //Get all text attachments
    contentVersionList.addAll(getTextFileAttachments(tAttachments, caseId));
    //Get all binary attachments
    contentVersionList.addAll(getTextBinaryAttachments(bAttachments, caseId));

    if (contentVersionList.size() > 0) {
      AccessCheckUtil.AccessCheckWrapper acw = AccessCheckUtil.checkAccess(
        'ContentVersion',
        AccessType.CREATABLE,
        contentVersionList
      );
      if (acw.inAccessibleFields != null) {
        CommonUtil.logAndThrowIAE(
          IDREmailServiceHelper.class.getName(),
          'createAttachmentFiles',
          'User does not have create access to fields of ContentVersion --' +
          acw.inAccessibleFields
        );
      } else {
        List<Database.SaveResult> results = Database.insert(
          contentVersionList,
          false
        );
        Logger.error('', results);
        Logger.saveLog();
      }
    }

    List<Id> contentVerIds = new List<Id>();
    for (ContentVersion cv : contentVersionList) {
      contentVerIds.add(cv.Id);
    }
    FileUtil.linkContentWithRecord(contentVerIds, caseId, 'I');
  }

  /**
   * @description Fetches the text attachments from the email
   * @param tAttachments The messaging inbound email text attachments
   * @param caseId The case Id that needs to be related to
   * @return List<ContentVersion> Wraps through content version
   */
  public static List<ContentVersion> getTextFileAttachments(
    List<Messaging.InboundEmail.TextAttachment> tAttachments,
    Id caseId
  ) {
    List<ContentVersion> returnConVerList = new List<ContentVersion>();
    if (tAttachments != null && tAttachments.size() > 0) {
      for (Messaging.InboundEmail.TextAttachment tAttachment : tAttachments) {
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
          Logger.error(
            'Discarded an attachment as the type was unsupported => filename : ' +
            tAttachment.fileName +
            ' , mimesubtype : ' +
            tAttachment.mimeTypeSubType,
            caseId
          );
        }
      }
    }
    Logger.saveLog();
    return returnConVerList;
  }

  /**
   * @description Fetches the text attachments from the email
   * @param bAttachments The messaging inbound email binary attachments
   * @param caseId The case Id that needs to be related to
   * @return List<ContentVersion> Wraps through content version
   */
  public static List<ContentVersion> getTextBinaryAttachments(
    List<Messaging.InboundEmail.BinaryAttachment> bAttachments,
    Id caseId
  ) {
    List<ContentVersion> returnConVerList = new List<ContentVersion>();
    if (bAttachments != null && bAttachments.size() > 0) {
      for (Messaging.InboundEmail.BinaryAttachment bAttachment : bAttachments) {
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
          Logger.error(
            'Discarded a binary attachment as the type was unsupported => filename : ' +
            bAttachment.fileName +
            ' , mimesubtype : ' +
            bAttachment.mimeTypeSubType,
            caseId
          );
        }
      }
    }
    Logger.saveLog();
    return returnConVerList;
  }

  /**
   * @description Updates the case with queue
   * @param newCase The case record
   * @param type The type of group
   * @param queueName The name of queue
   */
  public static void updateCaseWithQueue(
    Case newCase,
    String type,
    String queueName
  ) {
    Group queue = CommonUtil.getGroupDetails(type, queueName);
    AccessCheckUtil.AccessCheckWrapper acw = AccessCheckUtil.checkAccess(
      'Case',
      AccessType.UPDATABLE,
      new List<Case>{ newCase }
    );
    if (acw.inAccessibleFields != null) {
      CommonUtil.logAndThrowIAE(
        IDREmailServiceHelper.class.getName(),
        'updateCaseWithQueue',
        'User does not have edit access to fields of Case --' +
        acw.inAccessibleFields
      );
    } else {
      newCase.OwnerId = queue.Id;
      try {
        update newCase;
      } catch (Exception err) {
        Logger.error(
          'Error in updating case with queue for caseId :',
          newCase.Id,
          err
        );
        Logger.saveLog();
      }
    }
  }
}
