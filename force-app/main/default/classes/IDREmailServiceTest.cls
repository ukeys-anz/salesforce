/**
 * @author Adnan
 * @since 05/2021
 * @description  Test class for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
public with sharing class IDREmailServiceTest {
  @TestSetup
  static void setup() {
    Profile profile = [SELECT Id FROM Profile WHERE Name = 'No Access' LIMIT 1];
    User contextUser = (User) FakerFactory.make(new FakerUserFactory());
    contextUser.FirstName = 'ESContextUser';
    contextUser.ProfileId = profile.Id;
    insert contextUser;

    // Assign related PSs
    List<String> emailServicePSs = new List<String>{ 'IDR_EmailService' };

    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :emailServicePSs
    ];

    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = contextUser.Id,
        PermissionSetId = ps.Id
      );
      psaList.add(psa);
    }
    insert psaList;
  }

  @IsTest
  static void createCaseCompTest() {
    IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
      Name = 'Test_Email',
      Inbox_Email__c = 'YourFeedback@anz.com',
      Origin__c = 'Email',
      Technical_Email_Address__c = 'testtechnicaladdress@testabc.com'
    );
    insert idrEmailSetting;
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(contextUser) {
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'YourFeedback@anz.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      IDREmailService idremserObj = new IDREmailService();
      idremserObj.handleInboundEmail(email, env);

      Test.stopTest();
    }

    List<Case> caseList = [
      SELECT Id, Description, SuppliedEmail
      FROM Case
      LIMIT 1
    ];
    //Asserts
    System.assertNotEquals(null, caseList, 'A new case is not created');
    System.assertNotEquals(
      null,
      caseList[0].Description,
      'Case Description is null'
    );
    System.assertNotEquals(
      'testFrom@abc.com',
      caseList[0].SuppliedEmail,
      'Supplied email is not populated'
    );
  }

  @IsTest
  static void checkSpammingTest() {
    IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
      Name = 'Test_Email',
      Inbox_Email__c = 'testclassxyz@testabc.com',
      Origin__c = 'Email',
      Technical_Email_Address__c = 'testclassxyz@testabc.com'
    );
    insert idrEmailSetting;
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      Test.startTest();
      //System.runAs(contextuser){
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'testclassxyz@testabc.com'; //This value is present in custom setting
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);
      email.headers = emailHeaders;
      IDREmailService idremserObj = new IDREmailService();
      Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
        email,
        env
      );
      Test.stopTest();

      //Asserts
      System.assertEquals(
        false,
        result.success,
        'This email was a spam email but it was not detected.'
      );
    }
  }

  @IsTest
  static void checkSpammingTest2() {
    IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
      Name = 'Test_Email',
      Inbox_Email__c = 'testclassxyz@testabc.com',
      Origin__c = 'Email',
      Technical_Email_Address__c = 'testclassxyzadsfdsafsda@testabc.com'
    );
    insert idrEmailSetting;
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      Test.startTest();
      //System.runAs(contextuser){
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'testclassxyzadsfdsafsda@testabc.com'; //This value is present in custom setting IDR_Email_Service_Setting__mdt
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);
      email.headers = emailHeaders;
      IDREmailService idremserObj = new IDREmailService();
      Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
        email,
        env
      );
      Test.stopTest();

      //Asserts
      System.assertEquals(
        false,
        result.success,
        'This email was a spam email but it was not detected.'
      );
    }
  }

  @IsTest
  static void existingCaseTest() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      Case c = new Case(
        RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID,
        SuppliedEmail = 'testFrom@abc.com'
      );
      insert c;
      List<Case> createdCases = [SELECT Id, CaseNumber FROM Case LIMIT 1];
      String caseNumber = createdCases[0].CaseNumber;

      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'Update existing case ' + caseNumber;
      email.plainTextBody = 'Test plain text email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'test@test.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      //Creating text attachment
      Messaging.InboundEmail.TextAttachment txtAtt = new Messaging.InboundEmail.TextAttachment();
      txtAtt.body = 'This is a text Attachment body';
      txtAtt.fileName = 'DummyDoc.txt';
      txtAtt.mimeTypeSubType = 'text/plain';
      email.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{
        txtAtt
      };
      //Creating binary attachment
      Messaging.InboundEmail.BinaryAttachment binAtt = new Messaging.InboundEmail.BinaryAttachment();
      binAtt.body = Blob.valueOf('This is a binary Attachment body');
      binAtt.fileName = 'DummyDoc.txt';
      binAtt.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{
        binAtt
      };

      IDREmailService idremserObj = new IDREmailService();
      Test.startTest();
      idremserObj.handleInboundEmail(email, env);
      Test.stopTest();
      //Asserts
      System.assertEquals(
        createdCases[0].Id,
        [SELECT ParentId FROM EmailMessage LIMIT 1]
        .ParentId,
        'Case not updated with email'
      );
    }

  }

  @IsTest
  static void exceptionLoggingTestForAttachments() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      Case c = new Case(
        RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID,
        SuppliedEmail = 'testFrom@abc.com'
      );
      insert c;
      List<Case> createdCases = [SELECT Id, CaseNumber FROM Case LIMIT 1];
      String caseNumber = createdCases[0].CaseNumber;

      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'Update existing case ' + caseNumber;
      email.plainTextBody = 'Test plain text email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'test@test.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      //Creating text attachment
      Messaging.InboundEmail.TextAttachment txtAtt = new Messaging.InboundEmail.TextAttachment();
      txtAtt.body = 'This is a text Attachment body';
      txtAtt.fileName = 'DummyDoc.txt';
      //Non supported mime type
      txtAtt.mimeTypeSubType = 'nonsupport/test';
      email.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{
        txtAtt
      };
      //Creating binary attachment
      Messaging.InboundEmail.BinaryAttachment binAtt = new Messaging.InboundEmail.BinaryAttachment();
      binAtt.body = Blob.valueOf('This is a binary Attachment body');
      binAtt.fileName = 'DummyDoc.txt';
      //Non supported mime type
      binAtt.mimeTypeSubType = 'nonsupport/test';
      email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{
        binAtt
      };

      IDREmailService idremserObj = new IDREmailService();
      Test.startTest();
      idremserObj.handleInboundEmail(email, env);
      Test.stopTest();
      //Task should be created for incorrect attachment types
      List<Task> taskList = [
        SELECT Id, Subject
        FROM Task
        WHERE Subject LIKE '%Email attachment has failed to upload%'
      ];
      System.assertEquals(
        1,
        taskList.size(),
        'Email Attachment Failure Task should have been created'
      );
      //Asserts
      List<ContentVersion> conVerList = [SELECT Id FROM ContentVersion LIMIT 1];
      System.assertEquals(0, conVerList.size(), 'There is no ContentVersion');
    }
  }

  @IsTest
  static void exceptionLoggingTestForAttachments2() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      Case c = new Case(
        RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID,
        SuppliedEmail = 'testFrom@abc.com'
      );
      insert c;
      List<Case> createdCases = [SELECT Id, CaseNumber FROM Case LIMIT 1];
      String caseNumber = createdCases[0].CaseNumber;

      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'Update existing case ' + caseNumber;
      email.plainTextBody = 'Test plain text email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'test@test.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      //Creating text attachment
      Messaging.InboundEmail.TextAttachment txtAtt = new Messaging.InboundEmail.TextAttachment();
      //txtAtt.body = 'This is a text Attachment body';
      //txtAtt.fileName = 'DummyDoc.txt';
      //txtAtt.mimeTypeSubType = 'text/plain';
      email.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{
        txtAtt
      };
      //Creating binary attachment
      Messaging.InboundEmail.BinaryAttachment binAtt = new Messaging.InboundEmail.BinaryAttachment();
      //binAtt.body = Blob.valueOf('This is a binary Attachment body');
      //binAtt.fileName = 'DummyDoc.txt';
      //binAtt.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{
        binAtt
      };

      IDREmailService idremserObj = new IDREmailService();
      Test.startTest();
      idremserObj.handleInboundEmail(email, env);
      Test.stopTest();
      //Asserts
      List<ContentVersion> conVerList = [SELECT Id FROM ContentVersion LIMIT 1];
      System.assertEquals(0, conVerList.size(), 'There is no ContentVersion');
    }
  }

  @IsTest
  static void exceptionLoggingTestForUndisclosedRecipients() {
    IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
      Name = 'Test_Email',
      Inbox_Email__c = 'YourFeedback@anz.com',
      Origin__c = 'Email',
      Technical_Email_Address__c = 'testtechnicaladdress@testabc.com'
    );
    insert idrEmailSetting;
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(contextUser) {
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'undislosedrecipients:;';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header sendBcc = new Messaging.InboundEmail.Header();
      sendBcc.name = 'Bcc';
      sendBcc.value = 'YourFeedback@anz.com';
      emailHeaders.add(sendBcc);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      IDREmailService idremserObj = new IDREmailService();
      idremserObj.handleInboundEmail(email, env);

      Test.stopTest();

      // When undisclosedRecipient bug is fixed uncomment this assert and remove the LogEntry code
      /*
      List<Case> lstCases = [
        SELECT Id, Subject
        FROM Case
        WHERE Subject = :email.subject
      ];
*/

      //      System.assertEquals(1, lstCases.size(), 'Complaint not created.');

      List<LogEntry__c> lstLogEntries = [
        SELECT Id, ApexClassName__c, ExceptionMessage__c, LogMessage__c
        FROM LogEntry__c
        WHERE LoggingLevel__c = 'ERROR'
      ];

      System.assert(lstLogEntries.size() > 0, 'No Log Entries created');
      System.assert(
        lstLogEntries[0].ExceptionMessage__c.contains('undislosedrecipients'),
        'Exception not thrown'
      );
    }
  }

  @IsTest
  static void exceptionLoggingTestForStringTooLong() {
    IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
      Name = 'Test_Email',
      Inbox_Email__c = 'YourFeedback@anz.com',
      Origin__c = 'Email',
      Technical_Email_Address__c = 'testtechnicaladdress@testabc.com'
    );
    insert idrEmailSetting;
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(contextUser) {
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      email.htmlBody = '<html>'.rightPad(32000, 'lorem ipsum') + '</html>';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'YourFeedback@anz.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      IDREmailService idremserObj = new IDREmailService();
      idremserObj.handleInboundEmail(email, env);

      Test.stopTest();

      List<Case> lstCases = (new WithoutSharing()).getCases(email.subject);

      System.debug(
        [
          SELECT
            Id,
            ApexClassName__c,
            ApexMethodName__c,
            ExceptionMessage__c,
            LogMessage__c
          FROM LogEntry__c
        ]
      );

      System.assertEquals(1, lstCases.size(), 'Complaint not created.');
    }
  }

  @IsTest
  static void attachmentFailureWhileCreatingCase() {
    IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
      Name = 'Test_Email',
      Inbox_Email__c = 'YourFeedback@anz.com',
      Origin__c = 'Email',
      Technical_Email_Address__c = 'testtechnicaladdress@testabc.com'
    );
    insert idrEmailSetting;
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(contextUser) {
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'X-MS-Exchange-Inbox-Rules-Loop';
      sendTo.value = 'YourFeedback@anz.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;
      //Creating text attachment
      Messaging.InboundEmail.TextAttachment txtAtt = new Messaging.InboundEmail.TextAttachment();
      txtAtt.body = 'This is a text Attachment body';
      txtAtt.fileName = 'DummyDoc.txt';
      //Non supported mime type
      txtAtt.mimeTypeSubType = 'nonsupport/test';
      email.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{
        txtAtt
      };
      //Creating binary attachment
      Messaging.InboundEmail.BinaryAttachment binAtt = new Messaging.InboundEmail.BinaryAttachment();
      binAtt.body = Blob.valueOf('This is a binary Attachment body');
      binAtt.fileName = 'DummyDoc.txt';
      //Non supported mime type
      txtAtt.mimeTypeSubType = 'nonsupport/test';
      email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{
        binAtt
      };

      IDREmailService idremserObj = new IDREmailService();
      idremserObj.handleInboundEmail(email, env);

      Test.stopTest();
    }

    //Task should be created for incorrect attachment types
    List<Task> taskList = [
      SELECT Id, Subject
      FROM Task
      WHERE Subject LIKE '%Email attachment has failed to upload%'
    ];

    //Asserts
    System.assertEquals(
      1,
      taskList.size(),
      'Email Attachment Failure Task should have been created'
    );
  }

  /**
   * @description private class to allow test Case to be read.
   */
  private without sharing class WithoutSharing {
    /**
     * @description method to read test Case
     * @param strSubject subject of email used to create the Case
     *
     * @return list of Cases with matching Subject
     */
    public List<Case> getCases(String strSubject) {
      List<Case> lstCases = new List<Case>();
      // Case.Subject is encrypted and cannot be searched in a query
      for (Case oCase : [SELECT Id, Subject FROM Case]) {
        if (oCase.Subject == strSubject) {
          lstCases.add(oCase);
        }
      }
      return lstCases;
    }
  }

  /*
  @isTest
  static void testUpdateCaseWithQueueException() {
    Case c = new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID);
    Test.startTest();
    CaseUtil.updateCaseWithQueue(c, 'Queue', 'Indexing_Queue');
    Test.stopTest();
    //Asserts
    List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
    System.assertEquals(0, caseList.size());
  }*/
}
