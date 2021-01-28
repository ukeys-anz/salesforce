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
  static String ocvId;
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    ocvId = faker.randomString(10);
    Account accnt = new Account(
      Name = 'TestAccount',
      OCV_ID__c = ocvId,
      ANZx_Customer__c = true
    );
    insert accnt;
    Case newCase = new Case(
      RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
      AccountId = accnt.Id,
      Twilio_Channel_SID__c = 'CH123456789',
      Origin = 'Chat'
    );
    insert newCase;
  }
  /**
   * @description test method for getChatTopicsOnAccount when Forge response is successful
   */
  @isTest
  public static void validResponseChatTopicsOnAccount() {
    Test.setMock(HttpCalloutMock.class, new MockValidChatTopicsOnAccount());
    TestHelper.addTokensForApiCallout(ocvId);
    // Query for pre-inserted Account record
    Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
    Test.startTest();
    String respBody = ChatTopicRelatedListController.getChatTopicsOnAccount(
      acc.Id,
      ''
    );
    System.assert(respBody.contains('CH2c3d77ee8301494986657b57ffdxxxxx'));
    Test.stopTest();
  }
  class MockValidChatTopicsOnAccount implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid having one Chat Topic in the response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"channels": [{"id": "CH2c3d77ee8301494986657b57ffdxxxxx","name": "home-loan","status": "active","chatFlowStatus": "ACCEPTED","lastModified": "2021-01-13T04:51:16Z"}],"_links": {"_links": {"self": "xxxxx"} } }'
      );
      return res;
    }
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
    TestHelper.addTokensForApiCallout(ocvId);
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
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/Plaintext');
      res.setBody('Get ChatTopicsByCustomer failed');
      return res;
    }
  }
  /**
   * @description test method for getChatTopicInfoOnCase when successful
   */
  @isTest
  public static void validResponseChatTopicOnCase() {
    Test.setMock(HttpCalloutMock.class, new MockValidChatTopicsOnCase());
    TestHelper.addTokensForApiCallout(ocvId);
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
    System.assert(respBody.contains('CH2c3d77ee8301494986657b57ffdyyyyy'));
    Test.stopTest();
  }

  class MockValidChatTopicsOnCase implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid having one Chat Topic in the response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"channels": [{"id": "CH2c3d77ee8301494986657b57ffdyyyyy","name": "home-loan","status": "active","chatFlowStatus": "ACCEPTED","lastModified": "2021-01-13T04:51:16Z"}],"_links": {"_links": {"self": "xxxxx"} } }'
      );

      return res;
    }
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
    TestHelper.addTokensForApiCallout(ocvId);
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
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/Plaintext');
      res.setBody('Get ChatTopicsByChannelSID failed');
      return res;
    }
  }
}
