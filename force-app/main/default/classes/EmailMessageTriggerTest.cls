/*
 * @author Pragya Awasthi
 * @since  09/2025
 * @description test class for EmailMessageTrigger
 */
@isTest
public class EmailMessageTriggerTest {
  @isTest
  static void createEmail() {
    EmailMessage testEmail = new EmailMessage();
    testEmail.Subject = 'Test email PP is PP12345678';
    testEmail.HtmlBody = 'Test email PP is PP12345678';
    testEmail.TextBody = 'Test email PP is PP12345678';

    try {
      Test.startTest();
      insert testEmail;
      Test.stopTest();
    } catch (Exception e) {
      Assert.fail('Should be no Exception');
    }
  }
}
