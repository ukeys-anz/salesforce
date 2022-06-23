/**
 * @author Adnan
 * @since 05/2021
 * @description  This class is used to create or update cases(IDR Complaints), It fetches email addresses
 *               from IDREmailService email services.
 * @group IDR(Internal Dispute Resolution)
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.CyclomaticComplexity')
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
    /***** Variable Declarations Start ******/
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    Messaging.InboundEmail.Header[] emailHeaders = email.headers;
    Map<String, String> headerMap = new Map<String, String>();
    for (Messaging.InboundEmail.Header emailHeader : emailHeaders) {
      headerMap.put(
        String.escapeSingleQuotes(emailHeader.name),
        String.escapeSingleQuotes(emailHeader.value)
      );
    }
    String senderEmail = CommonUtil.filterStringUsingRegEx(
      IDRConstants.CASE_EMAIL_REGEX,
      headerMap.get('To')
    );
    String fromEmail = CommonUtil.filterStringUsingRegEx(
      IDRConstants.CASE_EMAIL_REGEX,
      headerMap.get('From')
    );
    /***** Variable Declarations End *****/

    String caseOrigin = '';
    String technicalEmailAddress = '';
    Map<String, IDR_Email_Settings__c> idrSettingWithSenderEmailMap = IDREmailServiceHandler.getIDREmailServiceSetting();
    if (idrSettingWithSenderEmailMap.size() > 0) {
      technicalEmailAddress = idrSettingWithSenderEmailMap.get(
          senderEmail.toLowerCase()
        )
        ?.Technical_Email_Address__c;
      caseOrigin = idrSettingWithSenderEmailMap.get(senderEmail.toLowerCase())
        ?.Origin__c;
      if (technicalEmailAddress == null) {
        for (
          IDR_Email_Settings__c idrem : idrSettingWithSenderEmailMap.values()
        ) {
          technicalEmailAddress += idrem.Technical_Email_Address__c + ' , ';
        }
      }
    }

    String emailSubject = String.escapeSingleQuotes(email.subject);

    //Check for Spamming
    Boolean isSpam = IDREmailServiceHandler.checkSpamming(
      senderEmail,
      fromEmail,
      emailSubject,
      technicalEmailAddress
    );

    //Extracting case number from subject
    String caseNumber = CommonUtil.filterStringUsingRegEx(
      IDRConstants.CASE_NO_REGEX,
      emailSubject
    );

    if (!isSpam) {
      Boolean createNewCase;
      if (caseNumber != emailSubject || emailSubject.isNumeric()) {
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
        IDREmailServiceHandler.createNewCaseAndEmailMsg(
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
