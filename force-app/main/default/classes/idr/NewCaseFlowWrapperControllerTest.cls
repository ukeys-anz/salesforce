/**
 * @author saiero
 * @since 2020
 * @description Test class for {@link NewCaseFlowWrapperController}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class NewCaseFlowWrapperControllerTest {
  /**
   * @description setup is to prepare test data
   */
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    //create test account
    Id recTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAcc = new Account(
      RecordTypeId = recTypeID,
      FirstName = faker.randomString(5),
      LastName = faker.randomString(5),
      OCV_ID__c = '1234567891'
    );
    insert testAcc;
  }

  @isTest
  static void testRecordTypeDevNameFromId() {
    RecordType rt = [
      SELECT DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Customer_Complaint'
    ];
    System.assertEquals(
      'Customer_Complaint',
      NewCaseFlowWrapperController.getCaseRecordTypeDevNameById(rt.Id),
      'Developer name should be Customer_Complaint'
    );
  }

  /**
   * @description Method to test getActiveChatTopicIDsByCustomer() method when 'no Chat Topics are available'
   */
  @isTest
  static void testGetActiveChatTopicsNoData() {
    // Fetching test data
    Account acc = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = '1234567891'
      LIMIT 1
    ];

    Test.setMock(HttpCalloutMock.class, new MockValidButNoChatTopics());
    TestHelper.addTokensForApiCallout('1234567891');

    String response;
    Test.startTest();

    response = NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(
      acc.Id
    );

    Test.stopTest();

    // Validating results
    System.assertEquals(
      '',
      response,
      'Response should be empty if no Chat Topics were found against an Account record'
    );
  }

  class MockValidButNoChatTopics implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid but empty response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"channels": null,"_links": {"_links": {"self": "xxxxx"} } }'
      );
      return res;
    }
  }

  /**
   * @description Method to test getActiveChatTopicIDsByCustomer() method when 'one Active Chat Topics are available'
   */
  @isTest
  static void testGetActiveChatTopicsOneActive() {
    // Fetching test data
    Account acc = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = '1234567891'
      LIMIT 1
    ];

    Test.setMock(HttpCalloutMock.class, new MockValidOneChatTopics());
    TestHelper.addTokensForApiCallout('1234567891');

    String response;
    Test.startTest();

    response = NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(
      acc.Id
    );

    Test.stopTest();

    // Validating results
    System.assertEquals(
      'CH2c3d77ee8301494986657b57ffdxxxxx',
      response,
      'Response should have a single Chat Topic Channel SID if one Active Chat Topic was found against an Account record'
    );
  }

  class MockValidOneChatTopics implements HttpCalloutMock {
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
   * @description Method to test getActiveChatTopicIDsByCustomer() method when 'multiple Active Chat Topics are available'
   */
  @isTest
  static void testGetActiveChatTopicsMultipleActive() {
    // Fetching test data
    Account acc = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = '1234567891'
      LIMIT 1
    ];

    Test.setMock(HttpCalloutMock.class, new MockValidMultipleChatTopics());
    TestHelper.addTokensForApiCallout('1234567891');

    String response;
    Test.startTest();

    response = NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(
      acc.Id
    );

    Test.stopTest();

    // Validating results
    System.assertEquals(
      'CH2c3dxxxxx|CH2c3eyyyyy',
      response,
      'Response should have a list of Channel SIDs when multiple Active Chat Topics were found against an Account record'
    );

    List<Application_Log__c> logs = [
      SELECT Id, Function_Name__c
      FROM Application_Log__c
      WHERE Function_Name__c = 'getActiveChatTopicIDsByCustomer'
    ];
    System.assert(
      !logs.isEmpty(),
      'An Application Log entry was not added when multiple Active Chat Topics were found against an Account record'
    );
  }

  class MockValidMultipleChatTopics implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid having more than one Chat Topics in the response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (
        req.getEndpoint()
          .endsWith(String.valueOf(CallCenterAPIRepository.OFFSET_LIMIT))
      ) {
        // Mock response with offset param set as "AAAA" on "next" attribute
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
          '{"channels": [{"id": "CH2c3dxxxxx","name": "home-loan","status": "active","chatFlowStatus": "ACCEPTED","lastModified": "2021-01-13T04:51:16Z"}],"_links": {"_links": {"next": "/chat/users/1234567891/channels?status=active&chatFlowStatus=ACCEPTED&limit=2&sortBy=lastModified&order=desc&offset=AAAA", "self": "xxxxx"} } }'
        );
      } else if (req.getEndpoint().endsWith('AAAA')) {
        // Mock response to subsequent API call requesting the next record set
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
          '{"channels": [{"id": "CH2c3eyyyyy","name": "card-rates","status": "active","chatFlowStatus": "ACCEPTED","lastModified": "2021-01-11T04:51:16Z"}],"_links": {"_links": {"self": "xxxxx"} } }'
        );
      }

      return res;
    }
  }

  /**
   * @description Method to test getActiveChatTopicIDsByCustomer() method when API error occurs
   */
  @isTest
  static void testGetActiveChatTopicsAPIError() {
    // Fetching test data
    Account acc = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = '1234567891'
      LIMIT 1
    ];

    Test.setMock(
      HttpCalloutMock.class,
      new MockInvalidChatTopicsByCustomerCallout()
    );
    TestHelper.addTokensForApiCallout('1234567891');

    String expMessage;

    Test.startTest();
    try {
      NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(acc.Id);
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    // Validating results
    System.assertEquals('Get Active Chat Topics failed', expMessage);

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
      res.setHeader('Content-Type', 'application/json');
      res.setBody('Get Active Chat Topics failed');
      return res;
    }
  }

  // Test getting available record type Ids for Case
  @isTest
  private static void testGetAvailableRecordTypeIdsForSObject() {
    List<Id> caseRecordTypeIdsByQuery = new List<Id>();
    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypes();
    Test.stopTest();
    System.assertNotEquals(
      0,
      ((List<RecordType>) JSON.deserializeStrict(
          resultString,
          List<RecordType>.class
        ))
        .size(),
      'Record type Ids were returned'
    );
  }
}
