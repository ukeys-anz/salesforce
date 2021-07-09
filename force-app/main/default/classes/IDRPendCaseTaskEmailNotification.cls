/**
 * @author Adnan
 * @since  09/2021
 * @description Email class for IDRPendCaseTaskRemindersBatch and for creating and sending task email notifications
 */
public with sharing class IDRPendCaseTaskEmailNotification {
  /**
   * @description method to get task owner details
   * @param verifiedPendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper, which contains email details
   * @param whichNotification specifies which notification for eg Task Creation/Task Reminder etc
   * @return Map<Id, User> returns map of task owner user record with its id
   */
  public static void sendEmailNotification(
    List<IDRPendCaseTaskReminderWrapper> verifiedPendCaseTaskWrapperList,
    String whichNotification
  ) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    for (
      IDRPendCaseTaskReminderWrapper pctw : verifiedPendCaseTaskWrapperList
    ) {
      if (
        pctw.emailNotificationRequired && whichNotification == 'Task Reminder'
      ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(pctw.taskOwnerUserRecord.Email);
        mail.setToAddresses(sendTo);
        //set from address...
        mail.setSubject('Your task is due by tomorrow');
        String body =
          'Dear ' +
          pctw.taskOwnerUserRecord.FirstName +
          ', <br/><br/>';
        body +=
          'Your task <b>' +
          pctw.taskRecord.Subject +
          '</b> for complaint <b>' +
          pctw.caseRecord.CaseNumber +
          '</b> ';
        body += 'is due in tomorrow. <br/><br/>';
        body += 'Thanks,<br/> CMOS Team';
        mail.setHtmlBody(body);
        mails.add(mail);
      }
    }
    Messaging.sendEmail(mails);
  }
}
