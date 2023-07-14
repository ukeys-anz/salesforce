/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Test class to cover tests for {@link InteractionContextServiceUpdate}
 * A
 */

@isTest
public with sharing class InteractionContextServiceUpdateTest {
  @testSetup
  static void testSetup() {
    Faker faker = new Faker('AU');
    //Insert Agent User
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZ Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    // Create coach user
    User coachUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'Coach Test ICT012',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => coachRole.Id,
        'Email' => 'testCoach@anz.com'
      }
    );

    insert coachUser;
    //Assign Permission set group as coach
    PermissionSetGroup psgCoach = [
      SELECT Id
      FROM PermissionSetGroup
      WHERE DeveloperName = 'Coach'
      LIMIT 1
    ];
    Test.calculatePermissionSetGroup(new List<String>{ psgCoach.Id });
    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = coachUser.Id,
      PermissionSetGroupId = psgCoach.Id
    );
    insert psa;

    //Insert Twilio Api User
    Profile p = CommonUtil.getProfileByName('Minimum Access - External Apps');
    UserRole role = CommonUtil.getUserRoleByDevName('ANZx');

    //Create Twilio API User User
    User apiUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'APIUserTestForInteraction',
        'ProfileId' => p.Id,
        'UserRoleId' => role.Id,
        'Email' => 'testAPI@anz.com'
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

    System.runAs(apiUser) {
      List<Twilio_Details__c> twilioDetailsList = new List<Twilio_Details__c>();
      Twilio_Details__c twilioDetailRecord1 = new Twilio_Details__c();
      twilioDetailRecord1.Twilio_ID__c = faker.randomString(10);
      twilioDetailRecord1.Chat_or_Call_SID__c = 'CH1123141516161616';
      twilioDetailRecord1.Status__c = 'Linked';
      twilioDetailRecord1.Call_Recording_Id__c = faker.randomString(10);
      twilioDetailRecord1.ANZ_Queue__c = faker.randomString(10);
      twilioDetailsList.add(twilioDetailRecord1);

      Twilio_Details__c twilioDetailRecord2 = new Twilio_Details__c();
      twilioDetailRecord2.Twilio_ID__c = faker.randomString(10);
      twilioDetailRecord2.Chat_or_Call_SID__c = 'CH1123141516161617';
      twilioDetailRecord2.Status__c = 'Created';
      twilioDetailRecord2.Call_Recording_Id__c = faker.randomString(10);
      twilioDetailRecord2.ANZ_Queue__c = faker.randomString(10);
      twilioDetailsList.add(twilioDetailRecord2);

      insert twilioDetailsList;

      //Creating Test Interactions
      List<Interaction> listOfInteractions = new List<Interaction>();
      Interaction interactNew1 = new Interaction();
      interactNew1.RecordTypeId = GetHelpConstants.INTERACTION_MESSAGE_RT_ID;
      String randInteractName1 = faker.randomString(10);
      interactNew1.Name = randInteractName1;
      interactNew1.StartTime = System.now().addDays(30);
      interactNew1.EndTime = interactNew1.StartTime.addMinutes(30);
      interactNew1.TwilioDetailsID__c = twilioDetailsList[0].Id;
      interactNew1.Chat_or_Call_SID__c = 'CH1123141516161616';
      listOfInteractions.add(interactNew1);

      Interaction interactNew2 = new Interaction();
      interactNew2.RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID;
      String randInteractName2 = faker.randomString(10);
      interactNew2.Name = randInteractName2;
      interactNew2.StartTime = System.now().addDays(30);
      interactNew2.EndTime = interactNew2.StartTime.addMinutes(30);
      interactNew2.TwilioDetailsID__c = twilioDetailsList[1].Id;
      interactNew2.Chat_or_Call_SID__c = 'CH1123141516161617';
      listOfInteractions.add(interactNew2);

      insert listOfInteractions;
    }

  }

  @isTest
  static void testValidInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    Interaction interactionRecord = [
      SELECT Id, Chat_or_Call_SID__c, RecordTypeId, OwnerId
      FROM Interaction
      WHERE RecordTypeId = :GetHelpConstants.INTERACTION_MESSAGE_RT_ID
      LIMIT 1
    ];
    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> twilioContexts = prepareRequest(
      interactionRecord.Id,
      'TW' + faker.randomString(10),
      'CH1123141516161616',
      'Created',
      'CR' + faker.randomString(10),
      'QName' + faker.randomString(8),
      ''
    );

    Test.startTest();
    System.runAs(usr) {
      InteractionContextServiceUpdate.doPost(twilioContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Case should be created against the customer related to the Chat Topic (Channel)
    List<Interaction> interactionList = [
      SELECT Id, Chat_or_Call_SID__c, OwnerId
      FROM Interaction
      WHERE Chat_or_Call_SID__c = 'CH1123141516161616'
      LIMIT 1
    ];

    System.assertEquals(
      interactionList[0].OwnerId,
      interactionRecord.OwnerId,
      'Interaction Owner will remain same'
    );
  }

  @isTest
  static void testInvalidInput() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    Interaction interactionRecord = [
      SELECT Id, Chat_or_Call_SID__c, RecordTypeId, OwnerId
      FROM Interaction
      WHERE RecordTypeId = :GetHelpConstants.INTERACTION_MESSAGE_RT_ID
      LIMIT 1
    ];
    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data

    User agentRecord = [
      SELECT Id, Email
      FROM User
      WHERE FirstName = 'Coach Test ICT012'
      LIMIT 1
    ];

    List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> twilioContexts = prepareRequest(
      interactionRecord.Id,
      'TW' + faker.randomString(10),
      'CH1123141516161616',
      'Created1',
      'CR' + faker.randomString(10),
      'QName' + faker.randomString(8),
      agentRecord.Email
    );

    Test.startTest();
    System.runAs(usr) {
      InteractionContextServiceUpdate.doPost(twilioContexts);
    }
    Test.stopTest();

    // THEN the request must succeed, and a new Case should be created against the customer related to the Chat Topic (Channel)
    List<Interaction> interactionList = [
      SELECT Id, Chat_or_Call_SID__c, OwnerId
      FROM Interaction
      WHERE Chat_or_Call_SID__c = 'CH1123141516161616'
      LIMIT 1
    ];

    System.assertEquals(
      interactionList[0].OwnerId,
      interactionRecord.OwnerId,
      'Interaction Owner will not be updated because status value is wrong'
    );
  }

  @isTest
  static void testValidInputWithAgentEmail() {
    Faker faker = new Faker('AU');

    // GIVEN Twilio API user has required access to Salesforce API
    // Query for API User
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');

    Interaction interactionRecord = [
      SELECT Id, Chat_or_Call_SID__c, RecordTypeId, OwnerId
      FROM Interaction
      WHERE RecordTypeId = :GetHelpConstants.INTERACTION_GENERAL_RT_ID
      LIMIT 1
    ];

    User agentRecord = [
      SELECT Id, Email
      FROM User
      WHERE FirstName = 'Coach Test ICT012'
      LIMIT 1
    ];

    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> twilioContexts = prepareRequest(
      interactionRecord.Id,
      'TW' + faker.randomString(10),
      'CH1123141516161617',
      'Created',
      'CR' + faker.randomString(10),
      'QName' + faker.randomString(8),
      agentRecord.Email
    );

    Test.startTest();
    System.runAs(usr) {
      InteractionContextServiceUpdate.doPost(twilioContexts);
    }
    Test.stopTest();

    List<Interaction> interactionList = [
      SELECT Id, Chat_or_Call_SID__c, OwnerId
      FROM Interaction
      WHERE Chat_or_Call_SID__c = 'CH1123141516161617'
      LIMIT 1
    ];

    System.assertNotEquals(
      interactionList[0].OwnerId,
      interactionRecord.OwnerId,
      'Interaction Owner will not remain same'
    );
  }

  /**
   * @description Method to prepare REST requests for test scenarios.
   * @param interactionId InteractionId
   * @param twilioId twilioID
   * @param chatOrCallId Twilio Channel SID
   * @param chatOrCallStatus chat or call status from Twilio
   * @param callRecordingId call recording id
   * @param queueName queueName from Twilio
   * @param agentEmail agentEmail from Twilio
   * @return `List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload>` List of 'InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload'
   */
  //Suppress warnings for parameters to prepare request
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> prepareRequest(
    String interactionId,
    String twilioId,
    String chatOrCallId,
    String chatOrCallStatus,
    String callRecordingId,
    String queueName,
    String agentEmail
  ) {
    List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> contextRequests = new List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload>();
    InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload contextReq = new InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload();
    contextReq.interactionId = interactionId;
    contextReq.chatOrCallId = chatOrCallId;
    contextReq.twilioId = twilioId;
    contextReq.callRecordingId = callRecordingId;
    contextReq.chatOrCallStatus = chatOrCallStatus;
    contextReq.queueName = queueName;
    contextReq.agentEmail = agentEmail;
    contextRequests.add(contextReq);

    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/InteractionContextRequestUpdates/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    return contextRequests;
  }
}
