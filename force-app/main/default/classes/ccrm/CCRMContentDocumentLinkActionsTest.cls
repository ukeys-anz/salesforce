/**
 * @author Naman Garg
 * @since 06/2024
 * @description CCRM Content Document Link Actions Test is the test class for CCRM Content Document Link Actions Class.
 */

@isTest
public class CCRMContentDocumentLinkActionsTest {
  static Lib_MockProvider cdlRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    cdlRepoMock = Lib_MockProvider.forType(
      CCRMContentDocumentLinkRepository.class
    );
  }

  private static ContentDocumentLink createMockData(Id emId) {
    ContentDocumentLink cdlRecord = new ContentDocumentLink(
      Id = Lib_FakeIdGenerator.getMockId(ContentDocumentLink.getSobjectType()),
      LinkedEntityId = emId,
      ContentDocumentId = Lib_FakeIdGenerator.getMockId(
        ContentDocument.getSobjectType()
      ),
      shareType = 'V',
      Visibility = 'AllUsers'
    );
    return cdlRecord;
  }

  @isTest
  static void testGetAllEmailMessageFromCdl() {
    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());

    //GIVEN Content Document Link List
    ContentDocumentLink cdlRecord = createMockData(emId);
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
      cdlRecord
    };

    //WHEN calling a method
    Test.startTest();
    Set<Id> emIds = CommonUtil.getIds(
      cdlList,
      ContentDocumentLink.LinkedEntityId
    );
    Test.stopTest();

    //THEN it should be able to fetch 1 Email Message record
    Assert.areEqual(
      1,
      emIds.size(),
      'Not able to find any Email Message record link to CDL.'
    );
  }

  @isTest
  static void testSegregateContentDocumentEmpty() {
    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());
    //GIVEN List of Content Document Link and Empty emailMessageMap
    ContentDocumentLink cdlRecord = createMockData(emId);
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
      cdlRecord
    };
    Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>();

    //WHEN calling a method
    Test.startTest();
    CCRMContentDocumentLinkActions.CdEmailMessageWrapper cdEmWrapper = CCRMContentDocumentLinkActions.segregateContentDocument(
      cdlList,
      emailMessageMap
    );
    Test.stopTest();

    //THEN it shouldn't able to fetch any record as emailMessageMap is Empty
    Assert.areEqual(
      0,
      cdEmWrapper.ccrmContentDocsToDelete.size(),
      'There exist a Content Document related to CDL.'
    );
  }

  @isTest
  static void testSegregateContentDocument() {
    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());

    //GIVEN Email Message record, List of Content Document Link and emailMessageMap
    ContentDocumentLink cdlRecord = createMockData(emId);
    EmailMessage emRecord = CCRMTestDataFactory.createEmailMessageInstance(
      emId
    );
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
      cdlRecord
    };
    Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>{
      emId => emRecord
    };

    //WHEN calling a method
    Test.startTest();
    CCRMContentDocumentLinkActions.CdEmailMessageWrapper cdEmWrapper = CCRMContentDocumentLinkActions.segregateContentDocument(
      cdlList,
      emailMessageMap
    );
    Test.stopTest();

    //THEN it should be able to fetch 1 record
    Assert.areEqual(
      1,
      cdEmWrapper.ccrmContentDocsToDelete.size(),
      'Not able to segregate content document.'
    );
  }

  @isTest
  static void testGetCountOfAttachment() {
    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());

    //GIVEN Email Message record, List of Content Document Link and emailMessageMap
    ContentDocumentLink cdlRecord = createMockData(emId);
    EmailMessage emRecord = CCRMTestDataFactory.createEmailMessageInstance(
      emId
    );
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
      cdlRecord
    };
    Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>{
      emId => emRecord
    };

    //WHEN calling a method
    Test.startTest();
    Map<Id, Integer> emToAttachmentCountMap = CCRMContentDocumentLinkActions.getCountOfAttachment(
      cdlList,
      emailMessageMap
    );
    Test.stopTest();

    //THEN it should be able to fetch 1 record
    Assert.areEqual(
      1,
      emToAttachmentCountMap.size(),
      'Not able to get the count of attachment.'
    );
  }

  @isTest
  static void testUpdateCountOnEmailMessageEmpty() {
    //GIVEN Empty emToAttachmentMap
    Map<Id, Integer> emToAttachmentMap = new Map<Id, Integer>();

    //WHEN calling a method
    Test.startTest();
    List<EmailMessage> emToUpdateList = CCRMContentDocumentLinkActions.updateCountOnEmailMessage(
      emToAttachmentMap
    );
    Test.stopTest();

    //THEN the list should be empty
    Assert.areEqual(
      0,
      emToUpdateList.size(),
      'There exist an email message in list.'
    );
  }

  @isTest
  static void testUpdateCountOnEmailMessage() {
    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());

    //GIVEN Email Message record, emToAttachmentMap
    EmailMessage emRecord = CCRMTestDataFactory.createEmailMessageInstance(
      emId
    );
    Map<Id, Integer> emToAttachmentMap = new Map<Id, Integer>{ emId => 1 };

    //WHEN calling a method
    Test.startTest();
    List<EmailMessage> emToUpdateList = CCRMContentDocumentLinkActions.updateCountOnEmailMessage(
      emToAttachmentMap
    );
    Test.stopTest();

    //THEN 1 email message record should be ready for update.
    Assert.areEqual(
      1,
      emToUpdateList.size(),
      '1 Email Message should be ready for update.'
    );
  }

  @isTest
  static void testDeleteContentDocument() {
    //GIVEN cdEmWrapper
    CCRMContentDocumentLinkActions.CdEmailMessageWrapper cdEmWrapper = new CCRMContentDocumentLinkActions.CdEmailMessageWrapper();

    Id cdId = Lib_FakeIdGenerator.getMockId(ContentDocument.getSobjectType());
    cdEmWrapper.mlContentDocsToDelete.add(cdId);
    cdEmWrapper.ccrmContentDocsToDelete.add(cdId);

    //WHEN calling a method
    Test.startTest();
    CCRMContentDocumentLinkActions.deleteContentDocument(cdEmWrapper);
    Test.stopTest();

    //THEN there should be 1 content document for CCRM available for deletion
    Assert.areEqual(
      1,
      cdEmWrapper.ccrmContentDocsToDelete.size(),
      'No content document is there for deletion.'
    );
  }

  @isTest
  static void testRestrictOutlookAttachmentsException() {
    registerMocks();
    //GIVEN mock exception
    cdlRepoMock.mockException(
      'getEmailMessageUsingProfileName',
      new QueryException('Failed to fetch Email Message')
    );

    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());

    //GIVEN Email Message record, Content Document Link List
    ContentDocumentLink cdlRecord = createMockData(emId);
    EmailMessage emRecord = CCRMTestDataFactory.createEmailMessageInstance(
      emId
    );
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
      cdlRecord
    };

    //WHEN calling a method
    try {
      Test.startTest();
      CCRMContentDocumentLinkActions.restrictOutlookAttachments(cdlList);
      Test.stopTest();
    } catch (Exception ex) {
      //THEN error should thrown on UI
      Assert.isTrue(
        ex instanceof QueryException,
        'QueryException should have been thrown for get Email Message.'
      );
    }
  }

  @isTest
  static void testRestrictOutlookAttachments() {
    registerMocks();

    Id emId = Lib_FakeIdGenerator.getMockId(EmailMessage.getSobjectType());

    //GIVEN Email Message record, emToAttachmentMap and Content Document Link List
    ContentDocumentLink cdlRecord = createMockData(emId);
    EmailMessage emRecord = CCRMTestDataFactory.createEmailMessageInstance(
      emId
    );
    Map<Id, EmailMessage> emailMessagesMap = new Map<Id, EmailMessage>{
      emId => emRecord
    };
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
      cdlRecord
    };

    cdlRepoMock.mock('getEmailMessageUsingProfileName', emailMessagesMap);

    //WHEN calling a method
    Test.startTest();
    CCRMContentDocumentLinkActions.restrictOutlookAttachments(cdlList);
    Test.stopTest();

    List<EmailMessage> emList = (List<EmailMessage>) dmlRepoMock.getHistory(
        'updateRecords'
      )
      .getParam('records');

    //THEN it should update 1 email message record.
    Assert.areEqual(
      1,
      emList.size(),
      '1 Email Message should be updated in Integration test.'
    );
  }
}
