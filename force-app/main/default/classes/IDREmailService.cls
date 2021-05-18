/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is used to create or update cases(IDR Complaints), It fetches email addresses
 *               from IDREmailService email services.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IDREmailService implements Messaging.InboundEmailHandler {
  /**
   * @description handles the inbound email from IDREmailService
   * @param email Inbound email object
   * @param envelope Inbound envelope object
   * @return result If the email ingestion is successful or not
   */
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    /***** Variable Declarations Start *****/
    Boolean isSpam = false;
    Boolean createNewCase = false;
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    Messaging.InboundEmail.Header[] emailHeaders = email.headers;
    Map<String, String> headerMap = new Map<String, String>();
    for (Messaging.InboundEmail.Header emailHeader : emailHeaders) {
      headerMap.put(emailHeader.name, emailHeader.value);
    }
    String senderEmail = headerMap.get('To');
    Matcher m1 = Pattern.compile(IDRConstants.CASE_EMAIL_REGEX)
      .matcher(headerMap.get('To'));
    if (m1.find()) {
      senderEmail = m1.group();
    }
    String fromEmail = headerMap.get('From');
    Matcher m2 = Pattern.compile(IDRConstants.CASE_EMAIL_REGEX)
      .matcher(headerMap.get('From'));
    if (m2.find()) {
      fromEmail = m2.group();
    }
    /***** Variable Declarations End *****/
    String caseOrigin = '';
    String technicalEmailAddress = '';
    IDR_Email_Service_Setting__mdt emailServiceMdt;
    if (
      IDR_Email_Service_Setting__mdt.sObjectType.getDescribe().isQueryable()
    ) {
      emailServiceMdt = [
        SELECT Id, DeveloperName, Email_Address__c, Inbox_Address__c, Origin__c
        FROM IDR_Email_Service_Setting__mdt
        WHERE Inbox_Address__c = :senderEmail
        LIMIT 1
      ];
    }
    if (emailServiceMdt != null) {
      technicalEmailAddress = emailServiceMdt.Email_Address__c;
      caseOrigin = emailServiceMdt.Origin__c;
    }

    //Check for Spamming
    isSpam = IDREmailServiceHandler.checkSpamming(
      senderEmail,
      fromEmail,
      email.subject,
      technicalEmailAddress
    );

    //Extracting case number from subject
    String caseNumber = null;
    Matcher m = Pattern.compile(IDRConstants.CASE_NO_REGEX)
      .matcher(email.subject);
    if (m.find()) {
      caseNumber = m.group();
    }

    if (!isSpam) {
      if (caseNumber != null) {
        createNewCase = IDREmailServiceHandler.updateExistingEmail(
          email,
          fromEmail,
          caseNumber
        );
      } else {
        createNewCase = true;
      }
      if (createNewCase) {
        IDREmailServiceHandler.createNewCase(
          email,
          senderEmail,
          fromEmail,
          caseOrigin
        );
      }
      result.success = true;
    } else {
      result.success = false;
    }
    return result;
  }
}
