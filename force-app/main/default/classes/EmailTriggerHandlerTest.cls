/*
 * @author Shivraj Kadam
 * @since  10/2023
 * @description EmailTriggerHandlerTest is the test class to cover tests for {@link EmailTriggerHandler}
 */
@isTest
private class EmailTriggerHandlerTest {
  /**
   * @description create test data
   * @return EmailMessage
   */
  static EmailMessage getEmail() {
    return new EmailMessage(
      Subject = 'Test email PP is PP12345678',
      HtmlBody = 'Test email PP is PP12345678',
      TextBody = 'Test email PP is PP12345678'
    );
  }

  /**
   * @description test method for BeforeInsert in Handler
   */
  @isTest
  static void testBeforeInsert() {
    //create EmailMessage record
    EmailMessage email = getEmail();

    Test.startTest();
    EmailTriggerHandler handler = new EmailTriggerHandler();
    handler.records = new List<EmailMessage>{ email };
    handler.onBeforeInsert();
    Test.stopTest();

    //assert
    Assert.areEqual(
      email.HtmlBody,
      'Test email PP is PP****5678',
      'Expected email to be masked'
    );
    Assert.areEqual(
      email.TextBody,
      'Test email PP is PP****5678',
      'Expected email to be masked'
    );
    Assert.areEqual(
      email.Subject,
      'Test email PP is PP****5678',
      'Expected email to be masked'
    );
  }

  /**
   * @description test method for BeforeUpdate in Handler
   */
  @isTest
  static void testBeforeUpdate() {
    //create EmailMessage record
    EmailMessage email = getEmail();
    email.TextBody = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    email.Subject = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    email.HtmlBody = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';

    //setting oldmap
    Map<Id, EmailMessage> oldMap = new Map<Id, EmailMessage>{
      email.Id => email
    };

    Test.startTest();
    EmailTriggerHandler handler = new EmailTriggerHandler();
    handler.records = new List<EmailMessage>{ email };
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //assert
    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      email.HtmlBody,
      'Expected email to be masked'
    );
    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      email.TextBody,
      'Expected email to be masked'
    );
    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      email.Subject,
      'Expected email to be masked'
    );
  }
}
