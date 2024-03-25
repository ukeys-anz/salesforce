/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description test class for Interaction Attendee Actions
 */
@isTest
public with sharing class InteractionAttendeeActionsTest {
  @TestSetup
  static void setup() {
    //Insert Twilio Api User
    Profile p = CommonUtil.getProfileByName('Minimum Access - External Apps');
    UserRole role = CommonUtil.getUserRoleByDevName('ANZx');

    //Create Twilio API User User
    User apiUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'APIUserTestForInteraction',
        'ProfileId' => p.Id,
        'UserRoleId' => role.Id,
        'Email' => 'testAPI@anz.com',
        'FederationIdentifier' => 'testAPI@anz.com'
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
  }
  /**
   * @description tests for insertTwilioConferenceAttendee Internal having agent email
   */
  @isTest
  static void testInsertTwilioConferenceAttendeeInternal() {
    User agentRecord = [
      SELECT Id, FederationIdentifier
      FROM User
      WHERE FirstName = 'APIUserTestForInteraction'
      LIMIT 1
    ];

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      true,
      agentRecord.FederationIdentifier
    );
    Map<String, Id> agentOwnerIdMap = new Map<String, Id>{
      agentRecord.FederationIdentifier.toLowerCase() => agentRecord.Id
    };
    Test.startTest();
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.insertTwilioConferenceAttendee(
      twilioContext,
      agentOwnerIdMap
    );
    Test.stopTest();
    System.assertEquals(
      InteractionConstants.INTERNAL,
      interactionAttendeeList[0].AttendeeType,
      'Interaction Attendee instance with Attendee Type Internal will be created'
    );
  }
  /**
   * @description tests for insertTwilioConferenceAttendee External without agent email
   */
  @isTest
  static void testInsertTwilioConferenceAttendeeExternal() {
    User agentRecord = [
      SELECT Id, FederationIdentifier
      FROM User
      WHERE FirstName = 'APIUserTestForInteraction'
      LIMIT 1
    ];

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(true, '');
    Map<String, Id> agentOwnerIdMap = new Map<String, Id>{
      agentRecord.FederationIdentifier.toLowerCase() => agentRecord.Id
    };

    Test.startTest();
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.insertTwilioConferenceAttendee(
      twilioContext,
      agentOwnerIdMap
    );
    Test.stopTest();

    System.assertEquals(
      InteractionConstants.EXTERNAL,
      interactionAttendeeList[0].AttendeeType,
      'Interaction Attendee instance with Attendee Type External will be created'
    );
  }
  /**
   * @description tests for insertTwilioConferenceAttendee if twiliocontext is not a conference
   */
  @isTest
  static void testNotInsertTwilioConferenceAttendee() {
    User agentRecord = [
      SELECT Id, FederationIdentifier
      FROM User
      WHERE FirstName = 'APIUserTestForInteraction'
      LIMIT 1
    ];

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(false, '');

    Map<String, Id> agentOwnerIdMap = new Map<String, Id>{
      agentRecord.FederationIdentifier.toLowerCase() => agentRecord.Id
    };

    Test.startTest();
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.insertTwilioConferenceAttendee(
      twilioContext,
      agentOwnerIdMap
    );
    Test.stopTest();

    System.assertEquals(
      true,
      interactionAttendeeList.isEmpty(),
      'Interaction Attendee instance will not be created'
    );
  }
  /**
   * @description tests for createInteractionAndAttendeeRoleMapInternal
   */
  @isTest
  static void testCreateInteractionAndAttendeeRoleMap() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    Test.startTest();
    Map<Id, String> createInteractionAndAttendeeRoleMap = InteractionAttendeeActions.createInteractionAndAttendeeRoleMap(
      attendeeList
    );
    Test.stopTest();

    System.assertEquals(
      true,
      createInteractionAndAttendeeRoleMap.size() == 1,
      'Internal Attendee Type Added in the Map'
    );
  }
  /**
   * @description tests for createInteractionAttendeeMap
   */
  @isTest
  static void testCreateInteractionAttendeeMap() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    Test.startTest();
    Map<Id, Set<String>> createInteractionAttendeeMap = InteractionAttendeeActions.createInteractionAttendeeMap(
      attendeeList
    );
    Test.stopTest();

    System.assertEquals(
      true,
      new Set<String>(createInteractionAttendeeMap.get('0kzBm0000001jcbIAA'))
        .contains('Shivam Swaraj'),
      'External Attendee Type Added in the Map'
    );
  }
  /**
   * @description tests for getInteractionIdFromAttendee
   */
  @isTest
  static void testGetInteractionIdFromAttendee() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    Test.startTest();
    Set<Id> interactionIds = InteractionAttendeeActions.getInteractionIdFromAttendee(
      attendeeList
    );
    Test.stopTest();

    System.assertEquals(
      true,
      interactionIds.size() > 0,
      'Interaction Ids will be added in the set of related Attendee'
    );
  }

  /**
   * @description tests for getInteractionAttendeeFromInteraction
   */
  @isTest
  static void testGetInteractionAttendeeFromInteraction() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>{
      interactionList.get(0).Id => interactionList.get(0)
    };

    Test.startTest();
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.getInteractionAttendeeFromInteraction(
      interactionMap
    );
    Test.stopTest();

    System.assertEquals(
      true,
      interactionAttendeeList.size() > 0,
      'Interaction Attendess List should be available with size greater than 0'
    );
  }
  /**
   * @description tests for UpdateAttendeeAndRoleOnInteraction
   */
  @isTest
  static void testUpdateAttendeeAndRoleOnInteraction() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>{
      interactionList.get(0).Id => interactionList.get(0)
    };
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.getInteractionAttendeeFromInteraction(
      interactionMap
    );
    Map<Id, Set<String>> createInteractionAttendeeMap = InteractionAttendeeActions.createInteractionAttendeeMap(
      interactionAttendeeList
    );
    Map<Id, String> createInteractionAndAttendeeRoleMap = InteractionAttendeeActions.createInteractionAndAttendeeRoleMap(
      interactionAttendeeList
    );

    Test.startTest();
    List<Interaction> interactionUpdatedList = InteractionAttendeeActions.updateAttendeeAndRoleOnInteraction(
      interactionMap,
      createInteractionAttendeeMap,
      createInteractionAndAttendeeRoleMap
    );
    Test.stopTest();
    System.assertEquals(
      'Test Testing lead,Shivam Swaraj,Test Coach',
      interactionUpdatedList[0].Attendees__c,
      'Attendees__c On Interaction Updated With Desiserd Values'
    );
    System.assertEquals(
      '{"005Bm000006ZzmlIAC":"Coach"}',
      interactionUpdatedList[0].Attendees_and_Roles__c,
      'Attendees_and_Roles__c On Interaction Updated With Desiserd Values'
    );
  }

  private static UpdateInteractionByTwilioPayload prepareRequest(
    Boolean isConference,
    String agentEmail
  ) {
    Faker faker = new Faker('AU');
    UpdateInteractionByTwilioPayload contextReq = new UpdateInteractionByTwilioPayload();
    contextReq.interactionId = Lib_FakeIdGenerator.getMockId(
      InteractionAttendee.getSObjectType()
    );
    contextReq.chatOrCallId = 'CH' + faker.randomString(10);
    contextReq.twilioId = 'TW' + faker.randomString(5);
    contextReq.callRecordingId = 'CR' + faker.randomString(5);
    contextReq.chatOrCallStatus = 'assigned';
    contextReq.queueName = 'QName' + faker.randomString(5);
    contextReq.agentEmail = agentEmail;
    contextReq.isConference = isConference;
    contextReq.attendeePhoneNumber = '8976868666';
    contextReq.attendeeName = faker.randomString(5);

    return contextReq;
  }
}
