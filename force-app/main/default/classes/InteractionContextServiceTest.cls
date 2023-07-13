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
        'Interaction_Integration'
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
      Account testAccount1 = createTestAccount(
        'Joe',
        'Bloggs',
        'OCVID887766',
        apiUser.Id,
        '123457',
        'OCVID887766CAPSYSID123'
      );
      testAccountList.add(testAccount1);
      Account testAccount2 = createTestAccount(
        'Joe',
        'Bloggs',
        'OCVID887767',
        apiUser.Id,
        '123456',
        'OCVID887766CAPSYSID124'
      );
      testAccountList.add(testAccount2);
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
    List<InteractionContextService.InteractionContextRequest> intContexts = prepareRequest(
      'OCVID887766',
      'CH' + faker.randomString(32),
      'Fraud',
      '1231',
      'Inbound',
      '123457',
      'Chat',
      'TW' + faker.randomString(10),
      'CR' + faker.randomString(10),
      'Created'
    );

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

    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    List<InteractionContextService.InteractionContextRequest> intContexts = prepareRequest(
      'OCVID887766',
      'CH' + faker.randomString(32),
      'Fraud',
      '1231',
      '',
      '123457',
      'Chat',
      'TW' + faker.randomString(10),
      'CR' + faker.randomString(10),
      'Created'
    );

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
    List<InteractionContextService.InteractionContextRequest> intContexts = prepareRequest(
      '',
      'CH' + faker.randomString(32),
      '',
      '',
      'Inbound',
      '123456',
      'Call',
      'TW' + faker.randomString(10),
      'CR' + faker.randomString(10),
      'Created'
    );

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
  static void testInvalidCallInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    // WHEN Twilio API user send a request without valid OCV ID
    // Prepare request test data
    List<InteractionContextService.InteractionContextRequest> intContexts = prepareRequest(
      '',
      'CH' + faker.randomString(32),
      '',
      '',
      'Inbound',
      '',
      'Call',
      'TW' + faker.randomString(10),
      'CR' + faker.randomString(10),
      'Created'
    );

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
   * @param ocvId OCV Id
   * @param chatOrCallId Twilio Channel SID
   * @param issueSubtype Support Topics for inbount chat
   * @param ppid PPID
   * @param direction Direction
   * @param phoneNumber For Phone Number
   * @param type to identify type of interaction
   * @param twilioId twilio id from twilio
   * @param callRecordingId call recording id
   * @param chatOrCallStatus chat or call status from Twilio
   * @return `List<InteractionContextService.InteractionContextRequest>` List of 'InteractionContextService.InteractionContextRequest'
   */
  //Suppress warnings for parameters to prepare request
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static List<InteractionContextService.InteractionContextRequest> prepareRequest(
    String ocvId,
    String chatOrCallId,
    String issueSubtype,
    String ppid,
    String direction,
    String phoneNumber,
    String type,
    String twilioId,
    String callRecordingId,
    String chatOrCallStatus
  ) {
    List<InteractionContextService.InteractionContextRequest> contextRequests = new List<InteractionContextService.InteractionContextRequest>();
    InteractionContextService.InteractionContextRequest contextReq = new InteractionContextService.InteractionContextRequest();
    contextReq.ocvId = ocvId;
    contextReq.chatOrCallId = chatOrCallId;
    contextReq.issueSubtype = issueSubtype;
    contextReq.ppid = ppid;
    contextReq.direction = direction;
    contextReq.phoneNumber = phoneNumber;
    contextReq.type = type;
    contextReq.twilioId = twilioId;
    contextReq.callRecordingId = callRecordingId;
    contextReq.chatOrCallStatus = chatOrCallStatus;
    contextRequests.add(contextReq);

    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/InteractionContextRequests/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    return contextRequests;
  }

  /**
   * @description helper method to create a person account
   * @param firstName String the first name of the person
   * @param lastName String the last name of the person
   * @param ocvId the OCVId
   * @param userId the OCVId
   * @param phoneNumber the OCVId
   * @param externalId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  static Account createTestAccount(
    String firstName,
    String lastName,
    String ocvId,
    Id userId,
    String phoneNumber,
    String externalId
  ) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.PersonMobilePhone = phoneNumber;
    testAccount.RecordTypeId = personAccountRecordTypeId;
    testAccount.OwnerId = userId;
    testAccount.External_Id__c = externalId;
    testAccount.ANZx_Customer__c = true;

    return testAccount;
  }
}
