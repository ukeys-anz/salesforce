/*
 * @author Shivraj Kadam
 * @since  10/2023
 * @description EmailTriggerHandlerTest is the test class to cover tests for {@link EmailTriggerHandler}
 */
@isTest
private class EmailTriggerHandlerTest {
  @isTest
  static void testEmail() {
    Test.startTest();
    Case c = new Case();
    c.Subject = 'Test';
    c.Status = 'New';
    c.Priority = 'Medium';
    c.Origin = 'Email';
    insert c;

    //Insert emailmessage for case
    EmailMessage email = new EmailMessage();
    email.FromAddress = 'test@abc.org';
    email.Incoming = true;
    email.ToAddress = 'test@xyz.org';
    email.Subject = 'Test email PP is PP12345678';
    email.HtmlBody = 'Test email PP is PP12345678';
    email.ParentId = c.Id;
    insert email;

    email.TextBody = 'Test email PP is PP12345678';
    update email;

    System.assertEquals(
      [SELECT Id, TextBody, HtmlBody FROM EmailMessage WHERE Id = :email.Id][0]
      .HtmlBody,
      'Test email PP is PP****5678',
      'Expected email to be masked'
    );
    Test.stopTest();
  }
}