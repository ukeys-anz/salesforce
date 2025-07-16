/**
 * @author Adnan
 * @since 05/2021
 * @description  Test class for IDREmailService class
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
public with sharing class IDREmailServiceTest {
  static Lib_MockProvider emailServiceHandlerMock;
  static Lib_MockProvider emailServiceHelperMock;

  static Faker faker = new Faker('AU');
  static String anzEmail = faker.internet.anzEmail();
  static String fromEmail = faker.internet.safeEmail();

  static IDR_Email_Settings__c idrEmailSetting = new IDR_Email_Settings__c(
    Id = Lib_FakeIdGenerator.getMockId(IDR_Email_Settings__c.SObjectType),
    Name = 'Test_Email',
    Inbox_Email__c = anzEmail,
    Origin__c = 'Email',
    Technical_Email_Address__c = faker.internet.safeEmail()
  );

  static void registerMocks() {
    emailServiceHandlerMock = Lib_MockProvider.forType(
      IDREmailServiceHandler.class
    );
    emailServiceHelperMock = Lib_MockProvider.forType(
      IDREmailServiceHelper.class
    );
  }

  private static Messaging.InboundEmail inboundEmail(
    String subject,
    String textBody,
    String htmlBody
  ) {
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    email.subject = subject;
    email.plainTextBody = textBody;
    email.htmlBody = htmlBody;
    return email;
  }

  private static Messaging.InboundEnvelope envelope() {
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    env.fromAddress = faker.internet.freeEmail();
    return env;
  }

  private static Messaging.InboundEmail.Header header(
    String name,
    String value
  ) {
    Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
    header.name = name;
    header.value = value;
    return header;
  }

  @isTest
  static void testHandleInboundEmail() {
    registerMocks();
    emailServiceHandlerMock
      .mock(
        'getIDREmailServiceSetting',
        new Map<String, IDR_Email_Settings__c>{
          idrEmailSetting.Inbox_Email__c => idrEmailSetting
        }
      )
      .mock('updateExistingEmail', false);
    emailServiceHelperMock
      .mock(
        'createNewCase',
        new Case(
          Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
          Priority = IDRConstants.CASE_PRIORITY_STANDARD,
          RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID
        )
      );
    Messaging.InboundEmail email = inboundEmail(
      'New case creation subject test',
      'The attached message was sent a user who has Send-As or Send-On-Behalf-Of rights for this mailbox',
      'Test html email body.'
    );
    Messaging.InboundEnvelope env = envelope();
    List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
    emailHeaders.add(header('To', faker.internet.companyEmail()));
    emailHeaders.add(header('From', fromEmail));
    email.headers = emailHeaders;
    IDREmailService idremserObj = new IDREmailService();
    Test.startTest();
    Messaging.InboundEmailResult result = idremserObj.handleInboundEmail(
      email,
      env
    );
    Test.stopTest();
    Assert.isTrue(result.success, 'Inbound email successfully processed.');
  }

  @isTest
  static void testIsSpam() {
    Test.startTest();
    Boolean isSpam = IDREmailServiceHandler.checkSpamming(
      idrEmailSetting.Inbox_Email__c,
      null,
      null,
      idrEmailSetting.Technical_Email_Address__c
    );
    Test.stopTest();
    Assert.isFalse(isSpam, 'Spam mail');
  }

  @isTest
  static void testUpdateExistingEmail() {
    Messaging.InboundEmail email = inboundEmail(
      'New case creation subject test',
      'The attached message was sent a user who has Send-As or Send-On-Behalf-Of rights for this mailbox',
      'Test html email body.'
    );
    List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
    emailHeaders.add(header('To', anzEmail));
    emailHeaders.add(header('From', fromEmail));
    email.headers = emailHeaders;
    Test.startTest();
    Boolean isCaseUpdated = IDREmailServiceHandler.updateExistingEmail(
      email,
      fromEmail,
      String.valueOf(faker.randomInteger(6)),
      anzEmail
    );
    Test.stopTest();
    Assert.isTrue(isCaseUpdated, 'Case updated');
  }

  @isTest
  static void testCreateNewCase() {
    registerMocks();
    Messaging.InboundEmail email = inboundEmail(
      'New case creation subject test',
      'The attached message was sent a user who has Send-As or Send-On-Behalf-Of rights for this mailbox',
      'Test html email body.'
    );
    List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
    emailHeaders.add(header('To', anzEmail));
    emailHeaders.add(header('From', fromEmail));
    email.headers = emailHeaders;
    Test.startTest();
    Case newCase = IDREmailServiceHelper.createNewCase(
      email,
      anzEmail,
      fromEmail,
      idrEmailSetting.Origin__c
    );
    Test.stopTest();
    Assert.areEqual(
      new Case(
        Description = 'The attached message was sent a user who has Send-As or Send-On-Behalf-Of rights for this mailbox',
        Priority = IDRConstants.CASE_PRIORITY_STANDARD,
        Subject = 'New case creation subject test',
        SuppliedEmail = fromEmail,
        IDR_Inbox_Email_Address__c = anzEmail,
        RecordTypeId = RTCase.generalInquiryCmos,
        Origin = 'Email'
      ),
      newCase,
      'Case are Equal'
    );
  }

  @isTest
  static void testGetTextFileAttachments() {
    Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
    textAttachment.body = 'This is a text Attachment body';
    textAttachment.fileName = 'DummyDoc.txt';
    textAttachment.mimeTypeSubType = 'text/plain';
    Test.startTest();
    List<ContentVersion> contentVersionList = IDREmailServiceHelper.getTextFileAttachments(
      new List<Messaging.InboundEmail.TextAttachment>{ textAttachment },
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      String.valueOf(faker.randomInteger(6))
    );
    Test.stopTest();
    Assert.areEqual(
      new List<ContentVersion>{
        IDREmailServiceHelper.createContentVersion(
          'DummyDoc.txt',
          Blob.valueOf('This is a text Attachment body')
        )
      },
      contentVersionList,
      'Content Version list are Equal'
    );
  }

  @isTest
  static void testNullGetTextFileAttachments() {
    Test.startTest();
    List<ContentVersion> contentVersionList = IDREmailServiceHelper.getTextFileAttachments(
      null,
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      String.valueOf(faker.randomInteger(6))
    );
    Test.stopTest();
    Assert.areEqual(
      new List<ContentVersion>(),
      contentVersionList,
      'Content Version list is Empty'
    );
  }

  @isTest
  static void testGetTextBinaryAttachments() {
    Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
    binaryAttachment.body = Blob.valueOf('Binary Attachment');
    binaryAttachment.fileName = 'DummyDoc.txt';
    binaryAttachment.mimeTypeSubType = 'text/plain';
    Test.startTest();
    List<ContentVersion> contentVersionList = IDREmailServiceHelper.getTextBinaryAttachments(
      new List<Messaging.InboundEmail.BinaryAttachment>{ binaryAttachment },
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      String.valueOf(faker.randomInteger(6))
    );
    Test.stopTest();
    Assert.areEqual(
      new List<ContentVersion>{
        IDREmailServiceHelper.createContentVersion(
          'DummyDoc.txt',
          Blob.valueOf('Binary Attachment')
        )
      },
      contentVersionList,
      'Content Version list are equal'
    );
  }

  @isTest
  static void testNullGetTextBinaryAttachments() {
    Test.startTest();
    List<ContentVersion> contentVersionList = IDREmailServiceHelper.getTextBinaryAttachments(
      null,
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      String.valueOf(faker.randomInteger(6))
    );
    Test.stopTest();
    Assert.areEqual(
      new List<ContentVersion>(),
      contentVersionList,
      'Content Version list is Empty'
    );
  }

  @isTest
  static void testCreateContentVersion() {
    Test.startTest();
    ContentVersion cv = IDREmailServiceHelper.createContentVersion(
      'DummyDoc.txt',
      Blob.valueOf('Attachment')
    );
    Test.stopTest();
    Assert.areEqual(
      new contentVersion(
        Title = 'DummyDoc.txt',
        PathOnClient = 'DummyDoc.txt',
        VersionData = Blob.valueOf('Attachment'),
        RecordTypeId = RTContentVersion.idrAttachment
      ),
      cv,
      'Both ContentVersion record are same'
    );
  }

  @isTest
  static void testInvalidGetTextBinaryAttachments() {
    Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
    binaryAttachment.body = Blob.valueOf('Binary Attachment');
    binaryAttachment.fileName = 'DummyDoc.txt';
    binaryAttachment.mimeTypeSubType = 'application/x-binary';
    Test.startTest();
    List<ContentVersion> contentVersionList = IDREmailServiceHelper.getTextBinaryAttachments(
      new List<Messaging.InboundEmail.BinaryAttachment>{ binaryAttachment },
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      String.valueOf(faker.randomInteger(6))
    );
    Test.stopTest();
    Assert.areEqual(
      new List<ContentVersion>(),
      contentVersionList,
      'Content Version list is Empty for invalid file type'
    );
  }

  @isTest
  static void testInvalidGetTextFileAttachments() {
    Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
    textAttachment.body = 'This is a text Attachment body';
    textAttachment.fileName = 'DummyDoc.txt';
    textAttachment.mimeTypeSubType = 'text/html';
    Test.startTest();
    List<ContentVersion> contentVersionList = IDREmailServiceHelper.getTextFileAttachments(
      new List<Messaging.InboundEmail.TextAttachment>{ textAttachment },
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      String.valueOf(faker.randomInteger(6))
    );
    Test.stopTest();
    Assert.areEqual(
      new List<ContentVersion>(),
      contentVersionList,
      'Content Version list is Empty for invalid file type'
    );
  }
}
