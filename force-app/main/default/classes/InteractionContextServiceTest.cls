/**
 * @author Lance Shi
 * @since  June 2022
 * @description Test class to cover tests for {@link InteractionContextService}
 * Added call and chat interaction logic to handle automatic creation of Interaction from Twilio - Shivam,July 2023 as part of ANZX-103285
 */

@isTest
public with sharing class InteractionContextServiceTest {
  @testSetup
  static void testSetup() {
    Faker faker = new Faker('AU');
    Profile p = CommonUtil.getProfileByName('Minimum Access - External Apps');
    UserRole role = CommonUtil.getUserRoleByDevName('ANZx');

    // Insert Account, Case, & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      //Create Twilio API User User
      User apiUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'APIUserTestForInteraction',
          'ProfileId' => p.Id,
          'UserRoleId' => role.Id
        }
      );
      insert apiUser;

      // Assign Interaction related PS on API User
      List<String> psNames = new List<String>{
        'Chat_Read_Write',
        'Interaction_Read_Write',
        'API_Access_Twilio',
        'API_Only',
        'Enforce_mTLS',
        'Twilio_Detail_Read_Write',
        'Interaction_Integration',
        'FinancialServicesCloudExtension'
      };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :psNames
      ];
      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(apiUser.id, ps.Id));
      }
      insert psaList;

      // Insert Account (Customer) record
      List<Account> testAccountList = new List<Account>();
      Account testAccountFirst = createTestAccount(
        'OCVID887766',
        apiUser.Id,
        '123457'
      );
      testAccountList.add(testAccountFirst);
      Account testAccountSecond = createTestAccount(
        'OCVID887767',
        apiUser.Id,
        '123456'
      );
      testAccountList.add(testAccountSecond);
      insert testAccountList;
    }
  }

  @isTest
  static void testValidChatInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = 'OCVID887766';
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = 'Fraud';
    contextReq.ppid = '1231';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = '123457';
    contextReq.type = 'Chat';
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = 'assigned';

    InteractionContextRequest intContexts = prepareRequest(contextReq);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer.
    List<Interaction> intList = [
      SELECT Id, Direction__c, Account.OCV_ID__c, Account.PersonMobilePhone
      FROM Interaction
      WHERE Account.OCV_ID__c = 'OCVID887766'
      LIMIT 1
    ];
    System.assertEquals(
      1,
      intList.size(),
      'Interaction list size should be as expected'
    );
    System.assertEquals(
      InteractionContextService.INBOUND_DIRECTION,
      intList[0].Direction__c,
      'Interaction direction should match'
    );
  }

  @isTest
  static void testInvalidChatInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request with valid OCV ID and invalid Direction
    // Prepare request test data
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = 'OCVID887766';
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = 'Fraud';
    contextReq.ppid = '1231';
    contextReq.direction = '';
    contextReq.phoneNumber = '123457';
    contextReq.type = 'Chat';
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = 'Created';

    InteractionContextRequest intContexts = prepareRequest(contextReq);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should not be created against the customer.
    List<Interaction> intList = [
      SELECT Id, Direction__c, Account.OCV_ID__c, Account.PersonMobilePhone
      FROM Interaction
      WHERE Account.OCV_ID__c = 'OCVID887766'
      LIMIT 1
    ];
    System.assertEquals(
      0,
      intList.size(),
      'Interaction list should be empty for invalid direction'
    );
  }

  @isTest
  static void testValidCallInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request with phoneNumber
    // Prepare request test data
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = '';
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = '';
    contextReq.ppid = '';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = '123456';
    contextReq.type = 'Voice';
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = '';

    InteractionContextRequest intContexts = prepareRequest(contextReq);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer related to the Call
    List<Interaction> intList = [
      SELECT Id, Direction__c, InteractionType
      FROM Interaction
      WHERE InteractionType = 'Call'
      LIMIT 1
    ];
    System.assertEquals(
      1,
      intList.size(),
      'Interaction list size should be as expected'
    );
    System.assertEquals(
      InteractionContextService.INBOUND_DIRECTION,
      intList[0].Direction__c,
      'Interaction direction should match'
    );
  }

  @isTest
  static void testValidCallInputAuthenticated() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request with phoneNumber
    // Prepare request test data
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = 'OCVID887766';
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = 'Coach - Call Us';
    contextReq.ppid = '';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = '123456';
    contextReq.type = 'Voice';
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = '';
    contextReq.isAuthenticated = true;

    InteractionContextRequest intContexts = prepareRequest(contextReq);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer related to the Call
    List<Interaction> intList = [
      SELECT Id, Direction__c, InteractionType
      FROM Interaction
      WHERE InteractionType = 'Call'
      LIMIT 1
    ];
    System.assertEquals(
      1,
      intList.size(),
      'Interaction list size should be as expected'
    );
    System.assertEquals(
      InteractionContextService.INBOUND_DIRECTION,
      intList[0].Direction__c,
      'Interaction direction should match'
    );
  }

  @isTest
  static void testValidCallInputAuthenticatedIssueSubtype() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request with phoneNumber
    // Prepare request test data
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = 'OCVID887766';
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = 'TestValue';
    contextReq.ppid = '';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = '123456';
    contextReq.type = 'Voice';
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = '';
    contextReq.isAuthenticated = true;

    InteractionContextRequest intContexts = prepareRequest(contextReq);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer related to the Call
    List<Interaction> intList = [
      SELECT Id, Support_Topics__c, InteractionType
      FROM Interaction
      WHERE InteractionType = 'Call'
      LIMIT 1
    ];
    System.assertEquals(
      1,
      intList.size(),
      'Interaction list size should be as expected'
    );
    System.assertEquals(
      'Support Enquiry',
      intList[0].Support_Topics__c,
      'Interaction support topic should be defaulted'
    );
  }

  @isTest
  static void testInvalidCallInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request without valid OCV ID
    // Prepare request test data
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = '';
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = '';
    contextReq.ppid = '';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = '';
    contextReq.type = 'Voice';
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = '';

    InteractionContextRequest intContexts = prepareRequest(contextReq);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new interaction should not be created
    List<Interaction> intList = [
      SELECT Id, Direction__c, InteractionType
      FROM Interaction
      WHERE InteractionType = 'Call'
      LIMIT 1
    ];
    System.assertEquals(
      0,
      intList.size(),
      'Interaction list should be empty if both OCV ID and Phone Number Blank'
    );
  }

  /**
   * @description Method to prepare REST requests for test scenarios.
   * @param interactionContextService InteractionContextRequest
   * @return 'InteractionContextRequest'
   */
  public static InteractionContextRequest prepareRequest(
    InteractionContextRequest interactionContextService
  ) {
    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/InteractionContextRequests/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    return interactionContextService;
  }

  /**
   * @description helper method to create a person account
   * @param ocvId the OCVId
   * @param userId the OCVId
   * @param phoneNumber the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static Account createTestAccount(
    String ocvId,
    Id userId,
    String phoneNumber
  ) {
    Account testAccount = TestDataFactory.createPersonAccount(ocvId, false);
    testAccount.PersonMobilePhone = phoneNumber;
    testAccount.OwnerId = userId;
    return testAccount;
  }
}
