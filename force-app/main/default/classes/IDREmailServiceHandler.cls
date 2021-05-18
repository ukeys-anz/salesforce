/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains handler methods for IDREmailService class
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public with sharing class IDREmailServiceHandler {
  /**
   * @description Checks if the email is a spam email
   * @param senderEmail The email address sent to
   * @param fromEmail The email address recieved from
   * @param subject The subject of email
   * @param technicalEmailAddress The technical email address of email services
   * @return isSpam If it is a spam or not
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static Boolean checkSpamming(
    String senderEmail,
    String fromEmail,
    String subject,
    String technicalEmailAddress
  ) {
    Boolean isSpam = false;
    if (senderEmail != null && senderEmail == technicalEmailAddress) {
      Lib_SystemLog.logAPIError(
        IDREmailServiceHandler.class.getName(),
        'Spam detected from IDR apex email service' + null,
        'Recieved email from --' +
        fromEmail +
        ' Subject --' +
        subject,
        null,
        IDREmailServiceHandler.class.getName(),
        null,
        null
      );
      isSpam = true;
    }
    return isSpam;
  }

  /**
   * @description Updates exisitng case with email
   * @param email Inbound email object
   * @param fromEmail The email address recieved from
   * @param caseNo Case number retrieved from subject line
   * @return Boolean if the case is updated or not successfully
   */
  public static Boolean updateExistingEmail(
    Messaging.InboundEmail email,
    String fromEmail,
    String caseNo
  ) {
    Case caseToUpd;
    List<Case> caseToUpdList;
    if (Case.sObjectType.getDescribe().isQueryable()) {
      caseToUpdList = [
        SELECT Id
        FROM Case
        WHERE
          CaseNumber = :caseNo
          AND Status != 'Closed'
          AND Status != 'Resolved'
          AND SuppliedEmail = :fromEmail
        LIMIT 1
      ];
    }
    if (caseToUpdList.size() > 0) {
      caseToUpd = caseToUpdList[0];
      try {
        //Create email message
        IDREmailServiceHelper.createEmailMessage(email, caseToUpd.Id);
        //Create files from attachments
        IDREmailServiceHelper.createAttachmentFiles(email, caseToUpd.Id);
      } catch (Exception err) {
        Lib_SystemLog.logAPIError(
          IDREmailServiceHandler.class.getName(),
          'Error in creating email message / attachment from service class' +
          caseToUpd.Id,
          err.getMessage(),
          null,
          IDREmailServiceHandler.class.getName(),
          null,
          null
        );
      }
      return false;
    } else {
      return true;
    }
  }

  /**
   * @description Creates a new case
   * @param email Inbound email object
   * @param senderEmail The email address sent to
   * @param fromEmail The email address recieved from
   * @param caseOrigin The case origin
   */
  @SuppressWarnings(
    'PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.ExcessiveParameterList'
  ) //Since the method is already refined to reduce complexity
  public static void createNewCase(
    Messaging.InboundEmail email,
    String senderEmail,
    String fromEmail,
    String caseOrigin
  ) {
    //Get Indexing Queue Id
    List<Group> queueList;
    if (Group.sObjectType.getDescribe().isQueryable()) {
      queueList = [
        SELECT Id
        FROM Group
        WHERE Type = 'Queue' AND developername = 'Indexing_Queue'
        LIMIT 1
      ];
    }
    //Create new case
    Case newCase = new Case(
      Description = email.plainTextBody.replaceAll('<.*>', 'REMOVED'),
      Priority = 'Standard',
      Status = 'New',
      Subject = email.subject,
      SuppliedEmail = fromEmail,
      recordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID
    );
    if (queueList.size() > 0) {
      newCase.OwnerId = queueList[0].Id;
    }
    if (caseOrigin != '') {
      newCase.Origin = caseOrigin;
    }
    if (fromEmail == System.Label.ANZ_com_Sender_Address) {
      IDREmailToCase.parseWebFormEmail(newCase);
    }
    try {
      if (Case.sObjectType.getDescribe().isCreateable()) {
        insert newCase;
      }
    } catch (Exception err) {
      Lib_SystemLog.logAPIError(
        IDREmailServiceHandler.class.getName(),
        'Error in creating new case from email service class' + null,
        err.getMessage(),
        null,
        IDREmailServiceHandler.class.getName(),
        null,
        null
      );
    }

    if (newCase.Id != null) {
      try {
        //Create email message
        IDREmailServiceHelper.createEmailMessage(email, newCase.Id);
        //Create files from attachments
        IDREmailServiceHelper.createAttachmentFiles(email, newCase.Id);
      } catch (Exception err) {
        Lib_SystemLog.logAPIError(
          IDREmailServiceHandler.class.getName(),
          'Error in creating email message / attachments from email service class' +
          newCase.Id,
          err.getMessage(),
          null,
          IDREmailServiceHandler.class.getName(),
          null,
          null
        );
      }
    }
  }
}
