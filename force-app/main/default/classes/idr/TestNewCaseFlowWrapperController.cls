@isTest
private with sharing class TestNewCaseFlowWrapperController {
  /**
   * @description setup is to prepare test data
   */
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    //create test accounts
    List<Account> accounts = new List<Account>();
    Id recTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    for (Integer i = 0; i < 2; i++) {
      Account testAcc = new Account(
        RecordTypeId = recTypeID,
        FirstName = faker.randomString(5),
        LastName = faker.randomString(5),
        OCV_ID__c = 'test123' + i
      );
      accounts.add(testAcc);
    }

    insert accounts;

    //insert multiple Chat Topic records against accounts[0]
    List<Chat_Topic__c> topics = new List<Chat_Topic__c>();
    for (Integer i = 0; i < 3; i++) {
      Chat_Topic__c topic = new Chat_Topic__c(
        Name = faker.randomString(8),
        Status__c = 'Closed',
        Related_Customer__c = accounts[0].Id,
        Twilio_Channel_SID__c = faker.randomString(34)
      );
      topics.add(topic);
    }

    //one 'Active' Chat Topic against accounts[0]
    topics[0].Status__c = 'Active';

    insert topics;
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
  static void testGetActiveChatTopics_No_Data() {
    // Fetching test data
    Account acc1 = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = 'test1231'
      LIMIT 1
    ];

    String response;
    Test.startTest();

    response = NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(
      acc1.Id
    );

    Test.stopTest();

    // Validating results
    System.assertEquals(
      '',
      response,
      'Response should be empty if no Chat Topics were found against an Account record'
    );
  }

  /**
   * @description Method to test getActiveChatTopicIDsByCustomer() method when 'one Active Chat Topics are available'
   */
  @isTest
  static void testGetActiveChatTopics_One_Active() {
    // Fetching test data
    Account acc0 = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = 'test1230'
      LIMIT 1
    ];

    String response;
    Test.startTest();

    response = NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(
      acc0.Id
    );

    Test.stopTest();

    // Validating results
    System.assert(
      !String.isEmpty(response),
      'Response should not be empty if one Active Chat Topic was found against an Account record'
    );

    Chat_Topic__c activeTopic = [
      SELECT Id
      FROM Chat_Topic__c
      WHERE Status__c = 'Active'
      LIMIT 1
    ];
    System.assertEquals(
      String.valueOf(activeTopic.Id),
      response,
      'Response should have a single Chat Topic ID if one Active Chat Topic was found against an Account record'
    );
  }

  /**
   * @description Method to test getActiveChatTopicIDsByCustomer() method when 'multiple Active Chat Topics are available'
   */
  @isTest
  static void testGetActiveChatTopics_Multiple_Active() {
    // Fetching test data
    Account acc0 = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = 'test1230'
      LIMIT 1
    ];

    // update an additional Chat Topic record to 'Active'
    Chat_Topic__c closedTopic = [
      SELECT Id, Status__c
      FROM Chat_Topic__c
      WHERE Status__c = 'Closed'
      LIMIT 1
    ];
    closedTopic.Status__c = 'Active';
    update closedTopic;

    String response;
    Test.startTest();

    response = NewCaseFlowWrapperController.getActiveChatTopicIDsByCustomer(
      acc0.Id
    );

    Test.stopTest();

    // Validating results
    System.assert(
      !String.isEmpty(response),
      'Response should not be empty if multiple Active Chat Topics were found against an Account record'
    );

    String expectedString = '';
    for (Chat_Topic__c topic : [
      SELECT Id
      FROM Chat_Topic__c
      WHERE Status__c = 'Active'
    ]) {
      expectedString += !String.isBlank(expectedString)
        ? '|' + topic.Id
        : topic.Id;
    }
    System.assertEquals(
      expectedString,
      response,
      'Response should have a list of IDs when multiple Active Chat Topics were found against an Account record'
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
}
