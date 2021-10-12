/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is used to create or update cases(IDR Complaints), It fetches email addresses
 *               from IDREmailService email services.
<<<<<<< HEAD
=======
 * @group IDR(Internal Dispute Resolution)
>>>>>>> develop
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
<<<<<<< HEAD
    return null;
=======
    /***** Variable Declarations Start *****/
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    Messaging.InboundEmail.Header[] emailHeaders = email.headers;
    Map<String, String> headerMap = new Map<String, String>();
    for (Messaging.InboundEmail.Header emailHeader : emailHeaders) {
      headerMap.put(emailHeader.name, emailHeader.value);
    }
    String senderEmail = IDREmailServiceHelper.filterStringUsingRegEx(
      IDRConstants.CASE_EMAIL_REGEX,
      headerMap.get('To')
    );
    String fromEmail = IDREmailServiceHelper.filterStringUsingRegEx(
      IDRConstants.CASE_EMAIL_REGEX,
      headerMap.get('From')
    );
    /***** Variable Declarations End *****/

    String caseOrigin = '';
    String technicalEmailAddress = '';
    Map<String, IDR_Email_Settings__c> idrSettingWithSenderEmailMap = IDREmailServiceHandler.getIDREmailServiceSetting();
    if (idrSettingWithSenderEmailMap.size() > 0) {
      technicalEmailAddress = idrSettingWithSenderEmailMap.get(senderEmail)
        ?.Technical_Email_Address__c;
      caseOrigin = idrSettingWithSenderEmailMap.get(senderEmail)?.Origin__c;
      if (technicalEmailAddress == null) {
        for (
          IDR_Email_Settings__c idrem : idrSettingWithSenderEmailMap.values()
        ) {
          technicalEmailAddress += idrem.Technical_Email_Address__c + ' , ';
        }
      }
    }

    //Check for Spamming
    Boolean isSpam = IDREmailServiceHandler.checkSpamming(
      senderEmail,
      fromEmail,
      email.subject,
      technicalEmailAddress
    );

    //Extracting case number from subject
    String caseNumber = IDREmailServiceHelper.filterStringUsingRegEx(
      IDRConstants.CASE_NO_REGEX,
      email.subject
    );

    if (!isSpam) {
      Boolean createNewCase;
      if (caseNumber != email.subject || email.subject.isNumeric()) {
        createNewCase = IDREmailServiceHandler.updateExistingEmail(
          email,
          fromEmail,
          caseNumber,
          senderEmail
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
>>>>>>> develop
  }
}
