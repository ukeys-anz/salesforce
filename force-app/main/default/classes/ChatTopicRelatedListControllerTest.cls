/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListControllerTest is the test class to cover tests for {@link ChatTopicRelatedListController}
 */
@isTest
public with sharing class ChatTopicRelatedListControllerTest {
  public static List<Account> accList;
  public static List<Case> caseList;
  /**
   * @description setup is to setup test data
   */
  static void setup() {
    Account accnt = new Account(
      Name = 'TestAccount',
      OCV_ID__c = '1234567891',
      PPID__c = '12431313',
      ANZx_Customer__c = true
    );
    Id accId = Lib_FakeIdGenerator.getMockId(accnt.getSObjectType());
    accnt.put('Id', accId);
    accList = new List<Account>{ accnt };
    Case newCase = new Case(
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      AccountId = accnt.Id,
      Account = accnt,
      Twilio_Channel_SID__c = 'CHc6ad9b34eb3e4788a12eb1caa07aefd5',
      Origin = 'Chat'
    );
    Id caseId = Lib_FakeIdGenerator.getMockId(newCase.getSObjectType());
    newCase.put('Id', caseId);
    caseList = new List<Case>{ newCase };

    AccountQueryHelper mockAccountHelper = (AccountQueryHelper) Lib_MockService.createMock(
      AccountQueryHelper.class,
      new Map<String, Object>{ 'findAccountsByAccountId' => accList }
    );

    CaseQueryHelper mockCaseHelper = (CaseQueryHelper) Lib_MockService.createMock(
      CaseQueryHelper.class,
      new Map<String, Object>{ 'findChatCaseByCaseId' => caseList }
    );

    ChatTopicRelatedListController.accountHelper = mockAccountHelper;
    ChatTopicRelatedListController.caseHelper = mockCaseHelper;
  }

  /**
   * @description test method for getChatTopicsOnAccount when successful
   */
  @isTest
  public static void validResponseChatTopicsOnAccount() {
    setup();
    // Query for pre-inserted Account record
    Test.startTest();
    ChatChannelModel response = ChatTopicRelatedListController.getChatTopicsOnAccount(
      accList[0].Id,
      ''
    );
    Test.stopTest();

    System.assertEquals(
      3,
      response.channels.size(),
      'Number of chat topics returned does not match with mock values size.'
    );
    System.assertEquals(
      'CH147c6128b4864e0aaadc58d87d74e50c',
      response.channels[0].id,
      'Id of 1st chat topic does not match.'
    );
  }

  /**
   * @description test method for getChatTopicsOnAccount when response is null
   */
  @isTest
  public static void nullsResponseChatTopicsOnAccount() {
    setup();
    AccountQueryHelper mockAccountHelperNull = (AccountQueryHelper) Lib_MockService.createMock(
      AccountQueryHelper.class,
      new Map<String, Object>{
        'findAccountsByAccountId' => (new List<Account>())
      }
    );
    ChatTopicRelatedListController.accountHelper = mockAccountHelperNull;
    Test.startTest();
    ChatChannelModel response = ChatTopicRelatedListController.getChatTopicsOnAccount(
      null,
      ''
    );
    Test.stopTest();

    System.assertEquals(null, response, 'Response is not null.');
  }

  /**
   * @description test method for getChatTopicInfoOnCase when successful
   */
  @isTest
  public static void validResponseChatTopicOnCase() {
    setup();
    // Query for pre-inserted Case record
    Test.startTest();
    ChatChannelModel.Channel response = ChatTopicRelatedListController.getChatTopicInfoOnCase(
      caseList[0].Id
    );
    Test.stopTest();

    System.assertEquals(
      'CHc6ad9b34eb3e4788a12eb1caa07aefd5',
      response.id,
      'Channel Id does not match'
    );
    System.assertEquals(
      'April2021',
      response.name,
      'Channel name does not match.'
    );
  }

  /**
   * @description test method for getChatTopicInfoOnCase when response is null
   */
  @isTest
  public static void nullsResponseChatTopicsOnCase() {
    setup();
    CaseQueryHelper mockCaseHelperNull = (CaseQueryHelper) Lib_MockService.createMock(
      CaseQueryHelper.class,
      new Map<String, Object>{ 'findChatCaseByCaseId' => (new List<Case>()) }
    );
    ChatTopicRelatedListController.caseHelper = mockCaseHelperNull;
    Test.startTest();
    ChatChannelModel.Channel response = ChatTopicRelatedListController.getChatTopicInfoOnCase(
      ''
    );
    Test.stopTest();

    System.assertEquals(null, response, 'Response is not null.');
  }
}
