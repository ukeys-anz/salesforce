/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is contains handler methods for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDREmailServiceTest
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
  public static Boolean checkSpamming(
    String senderEmail,
    String fromEmail,
    String subject,
    String technicalEmailAddress
  ) {
    Boolean isSpam = false;
    if (senderEmail != null && technicalEmailAddress.contains(senderEmail)) {
      Logger.error(
        'Received email from : ' +
        fromEmail +
        ' Subject of email : ' +
        subject +
        ' Email sent to : ' +
        senderEmail
      );
      Logger.saveLog();
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
  public static Boolean updateExistingEmail(
    Messaging.InboundEmail email,
    String fromEmail,
    String caseNo,
    String senderEmail
  ) {
    Case caseToUpd;
    List<Case> caseToUpdList;
    if (Case.SObjectType.getDescribe().isQueryable()) {
      String queryString = 'SELECT Id, CaseNumber, OwnerId, IDR_NC_First_Name__c, IDR_NC_Last_Name__c FROM Case WHERE CaseNumber = :caseNo AND Status != \'Closed\' AND Status!= \'Provisionally Closed\' ';
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
      if (fromEmail != System.Label.XpressionSenderAddress) {
        IDRBankerNotificationBuilder.sendNotification(
          new List<IDRBankerNotificationWrapper>{
            IDRCaseNotificationManager.createNotification(
              'Email Response Attached',
              caseToUpd,
              null
            )
          }
        );
      }
      //Create files from attachments
      IDREmailServiceHelper.createAttachmentFiles(email, caseToUpd.Id);

      return false;
    } else {
      return true;
    }
  }

  /**
   * @description Creates a new case, email message, attachments and updates case with queue.
   * @param email Inbound email object
   * @param senderEmail The email address sent to
   * @param fromEmail The email address recieved from
   * @param caseOrigin The case origin
   */
  public static void createNewCaseAndEmailMsg(
    Messaging.InboundEmail email,
    String senderEmail,
    String fromEmail,
    String caseOrigin
  ) {
    //Create new case
    Case newCase = IDREmailServiceHelper.createNewCase(
      email,
      senderEmail,
      fromEmail,
      caseOrigin
    );
    if (newCase.Id != null) {
      IDREmailServiceHelper.createEmailMessage(email, newCase.Id);
      IDREmailServiceHelper.createAttachmentFiles(email, newCase.Id);
      IDREmailServiceHelper.updateCaseWithQueue(
        newCase,
        'Queue',
        'Indexing_Queue'
      );
    }
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
