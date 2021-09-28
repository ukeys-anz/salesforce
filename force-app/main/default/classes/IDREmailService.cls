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
    return null;
  }
}
