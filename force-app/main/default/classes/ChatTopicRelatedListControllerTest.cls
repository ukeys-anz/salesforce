/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListControllerTest is the test class to cover tests for {@link ChatTopicRelatedListController}
 */
@isTest
public with sharing class ChatTopicRelatedListControllerTest {
  /**
   * @description setup is to setup test data
   */
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account accnt = new Account(
      Name = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert accnt;

    Case newCase = new Case(
      RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
      AccountId = accnt.Id,
      Twilio_Channel_SID__c = 'CH123456789'
    );
    insert newCase;
  }

  /**
   * @description test method for getChatTopicsOnAccount when Forge response is successful
   */
  @isTest
  public static void validForgeResponseChatTopicsOnAccount() {
    Test.setMock(
      HttpCalloutMock.class,
      new ForgeTokenHandlerTest.MockForgeCallout()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    // Query for pre-inserted Account record
    Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

    Test.startTest();
    String respBody = ChatTopicRelatedListController.getChatTopicsOnAccount(
      acc.Id,
      ''
    );
    System.assertEquals('{"access_token":"xxxxx","expires_in":900}', respBody);
    Test.stopTest();
  }

  /**
   * @description test method for getChatTopicsOnAccount when forge token failed
   */
  @isTest
  public static void invalidForgeResponseChatTopicsOnAccount() {
    Test.setMock(
      HttpCalloutMock.class,
      new ForgeTokenHandlerTest.MockForgeCalloutFailed()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    // Query for pre-inserted Account record
    Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

    String expMessage;

    Test.startTest();
    try {
      ChatTopicRelatedListController.getChatTopicsOnAccount(acc.Id, '');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get access token failed', expMessage);

    Test.stopTest();
  }

  /**
   * @description test method for getChatTopicsOnAccount when failed
   */
  @isTest
  public static void invalidResponseChatTopicsOnAccount() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockInvalidChatTopicsByCustomerCallout()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    // Query for pre-inserted Account record
    Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

    String expMessage;

    Test.startTest();
    try {
      ChatTopicRelatedListController.getChatTopicsOnAccount(acc.Id, '');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get ChatTopicsByCustomer failed', expMessage);

    Test.stopTest();
  }

  class MockInvalidChatTopicsByCustomerCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (
        req.getEndpoint()
          .endsWith(String.valueOf(ChatTopicRelatedListController.OFFSET_LIMIT))
      ) {
        res.setStatusCode(500);
        res.setHeader('Content-Type', 'application/Plaintext');
        res.setBody('Get ChatTopicsByCustomer failed');
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }

  /**
   * @description test method for getChatTopicInfoOnCase when successful
   */
  @isTest
  public static void validForgeResponseChatTopicOnCase() {
    Test.setMock(
      HttpCalloutMock.class,
      new ForgeTokenHandlerTest.MockForgeCallout()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    // Query for pre-inserted Case record
    Case chatCase = [
      SELECT Id
      FROM Case
      WHERE Account.Name = 'TestAccount'
      LIMIT 1
    ];

    Test.startTest();
    String respBody = ChatTopicRelatedListController.getChatTopicInfoOnCase(
      chatCase.Id
    );
    System.assertEquals('{"access_token":"xxxxx","expires_in":900}', respBody);
    Test.stopTest();
  }

  /**
   * @description test method for getChatTopicInfoOnCase when forge token failed
   */
  @isTest
  public static void invalidForgeResponseChatTopicOnCase() {
    Test.setMock(
      HttpCalloutMock.class,
      new ForgeTokenHandlerTest.MockForgeCalloutFailed()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    // Query for pre-inserted Case record
    Case chatCase = [
      SELECT Id
      FROM Case
      WHERE Account.Name = 'TestAccount'
      LIMIT 1
    ];

    String expMessage;

    Test.startTest();
    try {
      ChatTopicRelatedListController.getChatTopicInfoOnCase(chatCase.Id);
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get access token failed', expMessage);

    Test.stopTest();
  }

  /**
   * @description test method for getChatTopicInfoOnCase when failed
   */
  @isTest
  public static void invalidResponseChatTopicOnCase() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockInvalidChatTopicByChannelCallout()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    // Query for pre-inserted Case record
    Case chatCase = [
      SELECT Id
      FROM Case
      WHERE Account.Name = 'TestAccount'
      LIMIT 1
    ];

    String expMessage;

    Test.startTest();
    try {
      ChatTopicRelatedListController.getChatTopicInfoOnCase(chatCase.Id);
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get ChatTopicsByChannelSID failed', expMessage);

    Test.stopTest();
  }

  class MockInvalidChatTopicByChannelCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().endsWith('CH123456789')) {
        res.setStatusCode(500);
        res.setHeader('Content-Type', 'application/Plaintext');
        res.setBody('Get ChatTopicsByChannelSID failed');
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }
}
