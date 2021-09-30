/**
 * @author Shermal Warnakula
 * @since  11/2020
 * @description Test class to cover tests for {@link ChatContextService}
 */
@isTest
public with sharing class ChatContextServiceTest {
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
          'FirstName' => 'APIUserTest',
          'ProfileId' => p.Id,
          'UserRoleId' => role.Id
        }
      );
      insert apiUser;

      // Assign Case related PS on API User
      List<String> psNames = new List<String>{
        'Chat_Read_Write',
        'API_Access_Twilio',
        'API_Only'
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
      List<String> companyNames = faker.text.realWords(2);
      Account testAccount = new Account(
        Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
        OCV_ID__c = 'OCVID887766',
        ANZx_Customer__c = true,
        External_Id__c = 'OCVID887766CAPSYSID123',
        // Criteria based sharing rules cannot be tested in APEX unit tests.
        // Therefore, sharing the test Account record with user by assigning ownership.
        OwnerId = apiUser.Id
      );
      insert testAccount;
    }
  }

  @isTest
  static void testSuccessCaseCreation() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTest');

    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    List<ChatContextService.ChatContextRequest> contextRequests = prepareRequest(
      'OCVID887766',
      'CH' + faker.randomString(32),
      'About ANZ Plus',
      '1231'
    );

    Test.startTest();
    System.runAs(usr) {
      ChatContextService.doPost(contextRequests);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Case should be created against the customer related to the Chat Topic (Channel)
    List<Case> newCases = [
      SELECT Id, CaseNumber, Account.OCV_ID__c
      FROM Case
      WHERE Account.OCV_ID__c = 'OCVID887766'
    ];
    System.assert(
      newCases.size() > 0,
      'Auto case creation failed via ChatContextRequests REST service'
    );

    System.assertEquals(200, RestContext.response.statusCode);
    List<ChatContextService.ChatContextResponse> responseDto = (List<ChatContextService.ChatContextResponse>) JSON.deserialize(
      RestContext.response.responseBody.toString(),
      List<ChatContextService.ChatContextResponse>.class
    );
    System.assertEquals(true, responseDto[0].success);
    System.assertEquals('OCVID887766', responseDto[0].ocvId);
    System.assertEquals(
      newCases[0].CaseNumber,
      responseDto[0].sfdcSearchString
    );
    System.assertEquals('About ANZ Plus', responseDto[0].chatLabel);
  }

  @isTest
  static void testInvalidRequest() {
    // GIVEN Twilo API user has required acces to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTest');

    // WHEN Twilio API user send an invalid request
    // Prepare request test data (not setting Channel SID on purpose to make the request invalid)
    List<ChatContextService.ChatContextRequest> contextRequests = prepareRequest(
      'OCVID887766',
      '',
      'About ANZ Plus',
      '1231'
    );

    Test.startTest();
    System.runAs(usr) {
      ChatContextService.doPost(contextRequests);
    }
    Test.stopTest();

    // THEN the request must fail, and a new Case should not be created against the customer
    List<ChatContextService.ChatContextResponse> responseDto = (List<ChatContextService.ChatContextResponse>) JSON.deserialize(
      RestContext.response.responseBody.toString(),
      List<ChatContextService.ChatContextResponse>.class
    );
    System.assertEquals(
      false,
      responseDto[0].success,
      'Request should fail if request params were invalid'
    );
    System.assertEquals(400, RestContext.response.statusCode);
    System.assertEquals('OCVID887766', responseDto[0].ocvId);
    System.assertEquals('', responseDto[0].sfdcSearchString);
    System.assert(
      responseDto[0]
        .errorMessage.contains('Invalid or insufficient request parameters')
    );
    System.assert(
      [SELECT COUNT() FROM Case WHERE Account.OCV_ID__c = 'OCVID887766'] == 0
    );
  }

  @isTest
  static void testInvalidOCVID() {
    Faker faker = new Faker('AU');

    // GIVEN Twilo API user has required acces to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTest');

    // WHEN Twilio API user send a request with an invalid OCV ID
    // Prepare request test data (setting an invalid OCV ID)
    List<ChatContextService.ChatContextRequest> contextRequests = prepareRequest(
      'OCVID888888',
      'CH' + faker.randomString(32),
      'About ANZ Plus',
      '1231'
    );

    Test.startTest();
    System.runAs(usr) {
      ChatContextService.doPost(contextRequests);
    }
    Test.stopTest();

    // THEN the request must fail with a valid error message in the response
    List<ChatContextService.ChatContextResponse> responseDto = (List<ChatContextService.ChatContextResponse>) JSON.deserialize(
      RestContext.response.responseBody.toString(),
      List<ChatContextService.ChatContextResponse>.class
    );
    System.assertEquals(
      false,
      responseDto[0].success,
      'Request should fail if the OCV ID is invalid'
    );
    System.assertEquals(400, RestContext.response.statusCode);
    System.assertEquals('OCVID888888', responseDto[0].ocvId);
    System.assertEquals('', responseDto[0].sfdcSearchString);
    System.assert(
      responseDto[0]
        .errorMessage.contains(
          'Could not find a matching ANZx customer record based on OCV ID'
        )
    );
  }

  @isTest
  static void testCaseAlreadyExists() {
    // GIVEN Twilo API user has required acces to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTest');

    // Create a test Case with a known Channel SID
    Account acc = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = 'OCVID887766'
      LIMIT 1
    ];
    Case newCase = new Case(
      Twilio_Channel_SID__c = 'CH12345678910111213141516171819202',
      AccountId = acc.Id,
      Origin = 'Chat',
      RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
      Type = 'About Us',
      Sub_Type__c = 'About ANZ Plus'
    );
    insert newCase;

    // WHEN Twilio API user send a request with an invalid OCV ID
    // Prepare request test data (setting a known Channel SID)
    List<ChatContextService.ChatContextRequest> contextRequests = prepareRequest(
      'OCVID887766',
      'CH12345678910111213141516171819202',
      'About ANZ Plus',
      '1231'
    );

    Test.startTest();
    System.runAs(usr) {
      ChatContextService.doPost(contextRequests);
    }
    Test.stopTest();

    // THEN the request must succeed, and Case will not be created against the customer (existing CaseNumber will be returned).
    List<Case> newCases = [
      SELECT Id, CaseNumber, Account.OCV_ID__c
      FROM Case
      WHERE Account.OCV_ID__c = 'OCVID887766'
    ];
    System.assert(
      newCases.size() == 1,
      'A new Case should not be created by ChatContextService REST service, if a Case already exist'
    );

    List<ChatContextService.ChatContextResponse> responseDto = (List<ChatContextService.ChatContextResponse>) JSON.deserialize(
      RestContext.response.responseBody.toString(),
      List<ChatContextService.ChatContextResponse>.class
    );
    System.assertEquals(true, responseDto[0].success);
    System.assertEquals(200, RestContext.response.statusCode);
    System.assertEquals('OCVID887766', responseDto[0].ocvId);
    System.assertEquals(
      newCases[0].CaseNumber,
      responseDto[0].sfdcSearchString
    );
    System.assertEquals('About ANZ Plus', responseDto[0].chatLabel);
  }

  @isTest
  static void testNoCaseFoundOrCreated() {
    Faker faker = new Faker('AU');
    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTest');

    // WHEN Twilio API user sends a request with valid OCV ID and Channel SID, but with an invalid Case Sub Type (no existing Cases against the same customer and Channel SID).
    // Prepare request test data
    // NOTE: About ANZ Plus is purposely misspelt here to be an invalid sub type
    List<ChatContextService.ChatContextRequest> contextRequests = prepareRequest(
      'OCVID887766',
      'CH' + faker.randomString(32),
      'About ANZ Plu',
      '1231'
    );

    Test.startTest();
    System.runAs(usr) {
      ChatContextService.doPost(contextRequests);
    }
    Test.stopTest();

    // THEN the request must succeed. Value on Account 'External ID' field will be returned.
    List<Case> newCases = [
      SELECT Id, CaseNumber, Account.OCV_ID__c
      FROM Case
      WHERE Account.OCV_ID__c = 'OCVID887766'
    ];

    List<ChatContextService.ChatContextResponse> responseDto = (List<ChatContextService.ChatContextResponse>) JSON.deserialize(
      RestContext.response.responseBody.toString(),
      List<ChatContextService.ChatContextResponse>.class
    );
    System.assertEquals(false, responseDto[0].success);
    System.assertEquals(400, responseDto[0].statusCode);
    System.assertEquals('OCVID887766', responseDto[0].ocvId);
    System.assertEquals(
      'OCVID887766CAPSYSID123',
      responseDto[0].sfdcSearchString
    );
    System.assertEquals(
      'Unable to find a matching Type for sub type "About ANZ Plu".',
      responseDto[0].errorMessage
    );
  }

  @isTest
  static void testSuccessCaseCreationNoSubType() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTest');

    // WHEN Twilio API user send a request with valid OCV ID and no Sub Type
    // Prepare request test data
    List<ChatContextService.ChatContextRequest> contextRequests = prepareRequest(
      'OCVID887766',
      'CH' + faker.randomString(32),
      '',
      '1231'
    );

    Test.startTest();
    System.runAs(usr) {
      ChatContextService.doPost(contextRequests);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Case should be created against the customer related to the Chat Topic (Channel)
    // with a Type of Other Enquiries
    List<Case> newCases = [
      SELECT Id, CaseNumber, Account.OCV_ID__c, Type
      FROM Case
      WHERE Account.OCV_ID__c = 'OCVID887766'
    ];

    System.assertEquals(200, RestContext.response.statusCode);
    List<ChatContextService.ChatContextResponse> responseDto = (List<ChatContextService.ChatContextResponse>) JSON.deserialize(
      RestContext.response.responseBody.toString(),
      List<ChatContextService.ChatContextResponse>.class
    );
    System.assertEquals(true, responseDto[0].success);
    System.assertEquals('OCVID887766', responseDto[0].ocvId);
    System.assertEquals(
      newCases[0].CaseNumber,
      responseDto[0].sfdcSearchString
    );
    System.assertEquals(newCases[0].Type, 'Other Enquiries');
    System.assertEquals('Other Enquiries', responseDto[0].chatLabel);
  }

  /**
   * @description Method to prepare REST requests for test scenarios.
   * @param ocvId OCV Id
   * @param channelSid Twilio Channel SID
   * @param caseSubtype Case Sub Type
   * @param ppid PPID
   * @return `List<ChatContextService.ChatContextRequest>` List of 'ChatContextService.ChatContextRequest'
   */
  //Suppress warnings for parameters to prepare request
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static List<ChatContextService.ChatContextRequest> prepareRequest(
    String ocvId,
    String channelSid,
    String caseSubtype,
    String ppid
  ) {
    List<ChatContextService.ChatContextRequest> contextRequests = new List<ChatContextService.ChatContextRequest>();
    ChatContextService.ChatContextRequest contextReq = new ChatContextService.ChatContextRequest();
    contextReq.ocvId = ocvId;
    contextReq.channelSID = channelSid;
    contextReq.caseSubtype = caseSubtype;
    contextReq.PPID = ppid;
    contextRequests.add(contextReq);

    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/ChatContextRequests/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    return contextRequests;
  }
}
