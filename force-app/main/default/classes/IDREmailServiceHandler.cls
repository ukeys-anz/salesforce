/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains handler methods for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 */
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
    if (senderEmail != null && technicalEmailAddress.contains(senderEmail)) {
      Lib_SystemLog log = new Lib_SystemLog(
        IDREmailServiceHandler.class.getName(),
        'checkSpamming'
      );
      log.error(
        'Spam detected from IDR apex email service',
        'Recieved email from --' +
        fromEmail +
        ' Subject --' +
        subject
      );
      log.publishEvent();
      isSpam = true;
    }
    return isSpam;
  }

  /**
   * @description Updates exisitng case with email
   * @param email Inbound email object
   * @param fromEmail The email address recieved from
   * @param caseNo Case number retrieved from subject line
   * @param senderEmail The email address to whom the email was sent to
   * @return Boolean if the case is updated or not successfully
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static Boolean updateExistingEmail(
    Messaging.InboundEmail email,
    String fromEmail,
    String caseNo,
    String senderEmail
  ) {
    Case caseToUpd;
    List<Case> caseToUpdList;
    if (Case.sObjectType.getDescribe().isQueryable()) {
      String queryString = 'SELECT Id, CaseNumber, OwnerId FROM Case WHERE CaseNumber = :caseNo AND Status != \'Closed\' AND Status != \'Resolved\' ';
      if (
        fromEmail != System.Label.XpressionSenderAddress &&
        senderEmail != System.Label.XpressionRecepientInboxAddress
      ) {
        queryString = queryString + 'AND SuppliedEmail = :fromEmail ';
      }
      queryString = queryString + 'LIMIT 1';
      caseToUpdList = Database.query(queryString);
    }
    if (caseToUpdList.size() > 0) {
      caseToUpd = caseToUpdList[0];

      //Create email message
      IDREmailServiceHelper.createEmailMessage(email, caseToUpd.Id);
      //Notify Case Owner
      IDRBankerNotificationBuilder.sendNotification(
        new List<IDRBankerNotificationWrapper>{
          IDRCaseNotificationManager.createNotification(
            'Email Response Attached',
            caseToUpd,
            null
          )
        }
      );
      //Create files from attachments
      IDREmailServiceHelper.createAttachmentFiles(email, caseToUpd.Id);

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
    'PMD.ExcessiveParameterList, PMD.ApexCRUDViolation'
  ) //Since the method is already refined to reduce complexity
  public static void createNewCase(
    Messaging.InboundEmail email,
    String senderEmail,
    String fromEmail,
    String caseOrigin
  ) {
    //Create new case
    /*************** LOGIC FOR CREATING NEW CASE - START *******************************/
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
        'User does not have create access to fields --' + acw.inAccessibleFields
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
          'Error in creating new case from email service class :' +
          err.getMessage()
        );
        log.publishEvent();
      }
    }
    /*************** LOGIC FOR CREATING NEW CASE - END *******************************/

    //Create email message
    IDREmailServiceHelper.createEmailMessage(email, newCase.Id);
    //Create files from attachments
    IDREmailServiceHelper.createAttachmentFiles(email, newCase.Id);
    //assign indexing queue to the case
    CaseUtil.updateCaseWithQueue(newCase, 'Queue', 'Indexing_Queue');
  }

  /**
   * @description Fetches all the data from IDR Email Settings Custom Setting
   * @return Custom setting map of custom setting name with its setting details
   */
  public static Map<String, IDR_Email_Settings__c> getIDREmailServiceSetting() {
    Map<String, IDR_Email_Settings__c> customSettingMap = IDR_Email_Settings__c.getAll();
    Map<String, IDR_Email_Settings__c> idrSettingWithSenderEmailMap = new Map<String, IDR_Email_Settings__c>();
    for (IDR_Email_Settings__c custSetting : customSettingMap.values()) {
      idrSettingWithSenderEmailMap.put(custSetting.Inbox_Email__c, custSetting);
    }
    return idrSettingWithSenderEmailMap;
  }
}
