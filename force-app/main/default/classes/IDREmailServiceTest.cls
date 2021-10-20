/**
 * @author Adnan
 * @since 05/2021
 * @description  Test class for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
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
        AssigneeId = contextUser.id,
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
    System.runAs(contextuser) {
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
      sendTo.name = 'To';
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
    System.runAs(contextuser) {
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
      sendTo.name = 'To';
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
    System.runAs(contextuser) {
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
      sendTo.name = 'To';
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

  @isTest
  static void existingCaseTest() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextuser) {
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
      sendTo.name = 'To';
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
      Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
        email,
        env
      );
      Test.stopTest();
      //Asserts
      System.assertEquals(
        createdCases[0].Id,
        [SELECT parentId FROM EmailMessage LIMIT 1]
        .parentId,
        'Case not updated with email'
      );
    }

  }

  @isTest
  static void exceptionLoggingTest() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextuser) {
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
      //Commenting out the html body for exception logging
      //email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'To';
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
      Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
        email,
        env
      );
      Test.stopTest();
      //Asserts
      List<EmailMessage> emailMessageList = [
        SELECT parentId
        FROM EmailMessage
        LIMIT 1
      ];
      System.assertEquals(0, emailMessageList.size());
    }
  }

  @IsTest
  static void createNewCaseExceptionTest() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(contextuser) {
      // Create a new email and envelope object.
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'New case creation subject test';
      email.plainTextBody = 'Test email body.';
      //Commenting out the html body for exception logging
      //email.htmlBody = 'Test html email body.';
      env.fromAddress = 'user@acme.com';

      //Create email header
      List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
      Messaging.InboundEmail.Header sendTo = new Messaging.InboundEmail.Header();
      sendTo.name = 'To';
      sendTo.value = 'ANZEDRNonProd@anz.com';
      emailHeaders.add(sendTo);

      Messaging.InboundEmail.Header fromEmail = new Messaging.InboundEmail.Header();
      fromEmail.name = 'From';
      fromEmail.value = 'testFrom@abc.com';
      emailHeaders.add(fromEmail);

      email.headers = emailHeaders;

      IDREmailService idremserObj = new IDREmailService();
      idremserObj.handleInboundEmail(email, env);

      Test.stopTest();
      //Asserts
      List<EmailMessage> emailMessageList = [
        SELECT parentId
        FROM EmailMessage
        LIMIT 1
      ];
      System.assertEquals(0, emailMessageList.size());
    }
  }

  @isTest
  static void exceptionLoggingTestForAttachments() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextuser) {
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
      sendTo.name = 'To';
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
      Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
        email,
        env
      );
      Test.stopTest();
      //Asserts
      List<ContentVersion> conVerList = [SELECT Id FROM ContentVersion LIMIT 1];
      System.assertEquals(0, conVerList.size());
    }
  }

  @isTest
  static void exceptionLoggingTestForAttachments2() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'ESContextUser'
      LIMIT 1
    ];
    System.runAs(contextuser) {
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
      sendTo.name = 'To';
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
      Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
        email,
        env
      );
      Test.stopTest();
      //Asserts
      List<ContentVersion> conVerList = [SELECT Id FROM ContentVersion LIMIT 1];
      System.assertEquals(0, conVerList.size());
    }
  }

  @isTest
  static void testUpdateCaseWithQueueException() {
    Case c = new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID);
    Test.startTest();
    IDREmailServiceHelper.updateCaseWithQueue(c);
    Test.stopTest();
    //Asserts
    List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
    System.assertEquals(0, caseList.size());
  }
}
