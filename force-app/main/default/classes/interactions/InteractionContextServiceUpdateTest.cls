/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Test class to cover tests for {@link InteractionContextServiceUpdate}
 */

@isTest
public with sharing class InteractionContextServiceUpdateTest {
  private static final Id FAKER_TWILIO_ID = Lib_FakeIdGenerator.getMockId(
    Twilio_Details__c.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider interactionRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    interactionRepoMock = Lib_MockProvider.forType(InteractionRepository.class);
    interactionRepoMock.mock(
      'fetchTwilioStatusMapping',
      new List<InteractionStatusMappingForTwilio__mdt>{
        new InteractionStatusMappingForTwilio__mdt(
          Twilio_Status__c = 'assigned',
          Interaction_Status__c = 'Active'
        )
      }
    );
  }

  @isTest
  static void testValidInput() {
    String mockChatOrCallId = 'CH1123141516161616';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );

    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
        InteractionConstants.CHAT,
        mockChatOrCallId
      )
    );

    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'assigned',
      ''
    );

    Test.startTest();
    InteractionContextServiceUpdate.doPost(twilioContext);
    Test.stopTest();

    Interaction interactionUpdated = (Interaction) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    Assert.isTrue(
      interactionUpdated.Status__c == 'Active',
      'Interaction Should be updated Active status value'
    );
  }

  @isTest
  static void testInvalidInput() {
    String mockChatOrCallId = 'CH1123141516161616';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );
    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );
    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
        InteractionConstants.CHAT,
        mockChatOrCallId
      )
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'Created1',
      ''
    );

    Test.startTest();
    try {
      InteractionContextServiceUpdate.doPost(twilioContext);
    } catch (Exception objectException) {
      Assert.isTrue(
        objectException.getMessage()
          .contains(
            'bad value for restricted picklist field: Created1: [Status__c]'
          ),
        'Interaction should not be updated for invalid status value'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testValidInputWithAgentEmail() {
    String mockChatOrCallId = 'CH1123141516161617';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );
    Id agentUserId = Lib_FakeIdGenerator.getMockId(User.getSObjectType());
    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );
    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        InteractionConstants.CALL,
        mockChatOrCallId
      )
    );
    interactionRepoMock.mock(
      'fetchAgentUserId',
      createMockAgent(agentUserId, 'TestAgent@abc.com')
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'assigned',
      'TestAgent@abc.com'
    );

    Test.startTest();
    InteractionContextServiceUpdate.doPost(twilioContext);
    Test.stopTest();

    Interaction interactionUpdated = (Interaction) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    Assert.isTrue(
      interactionUpdated.OwnerId == agentUserId,
      'Interaction Should be updated with the given agent user id '
    );
  }

  @isTest
  static void testConferenceAttendeeCreationInternal() {
    String mockChatOrCallId = 'CH1123141516161617';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );
    Id agentUserId = Lib_FakeIdGenerator.getMockId(User.getSObjectType());
    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );

    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        InteractionConstants.CALL,
        mockChatOrCallId
      )
    );
    interactionRepoMock.mock(
      'fetchAgentUserId',
      createMockAgent(agentUserId, 'TestAgent@abc.com')
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'assigned',
      'TestAgent@abc.com'
    );
    twilioContext.isConference = true;
    twilioContext.transfer = '';
    twilioContext.attendeeName = 'Test Attendee';
    twilioContext.attendeePhoneNumber = '9797997779';

    Test.startTest();
    InteractionContextServiceUpdate.doPost(twilioContext);
    Test.stopTest();

    Interaction interactionUpdated = (Interaction) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    InteractionAttendee interactionAttendee = (interactionAttendee) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isFalse(
      interactionUpdated.OwnerId == agentUserId,
      'Interaction Should be updated with the given agent user id '
    );

    Assert.isTrue(
      interactionAttendee.AttendeeType == InteractionConstants.INTERNAL,
      'InteractionAttendee Should be created with the given agent user id '
    );
  }
  @isTest
  static void testConferenceAttendeeCreationExternal() {
    String mockChatOrCallId = 'CH1123141516161617';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );
    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );

    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        InteractionConstants.CALL,
        mockChatOrCallId
      )
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'assigned',
      ''
    );
    twilioContext.isConference = true;
    twilioContext.transfer = '';
    twilioContext.attendeeName = 'Test Attendee';
    twilioContext.attendeePhoneNumber = '9797997779';

    Test.startTest();
    InteractionContextServiceUpdate.doPost(twilioContext);
    Test.stopTest();

    InteractionAttendee interactionAttendee = (interactionAttendee) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isTrue(
      interactionAttendee.AttendeeType == InteractionConstants.EXTERNAL,
      'InteractionAttendee Should be created with the given agent user id '
    );
  }

  @isTest
  static void testIsChatTransferPositive() {
    String mockChatOrCallId = 'CH1123141516161616';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );
    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );
    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
        InteractionConstants.CHAT,
        mockChatOrCallId
      )
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'assigned',
      ''
    );
    twilioContext.queueName = 'ChatQueue';
    twilioContext.transfer = 'To Agent';

    Test.startTest();
    InteractionContextServiceUpdate.doPost(twilioContext);
    Test.stopTest();

    Interaction interactionUpdated = (Interaction) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    Assert.isTrue(
      interactionUpdated.Transfer__c == 'To Agent',
      'Value of Transfer__c should be updated with the given value in Interaction'
    );

    Assert.isTrue(
      interactionUpdated.Chat_Queue__c == 'ChatQueue',
      'Value of Chat_Queue__c should be updated with the given value in Interaction'
    );
  }

  @isTest
  static void testIsChatTransferNegative() {
    String mockChatOrCallId = 'CH1123141516161616';
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );
    dmlRepoMock.mock(
      'doUpsert',
      TestUtil.getMockUpsertResult(
        '{"success":true,"id":"' + FAKER_TWILIO_ID + '"}'
      )
    );
    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
        InteractionConstants.CHAT,
        mockChatOrCallId
      )
    );

    UpdateInteractionByTwilioPayload twilioContext = prepareRequest(
      interactionId,
      mockChatOrCallId,
      'assigned',
      ''
    );
    twilioContext.queueName = 'ChatQueue';
    Test.startTest();
    InteractionContextServiceUpdate.doPost(twilioContext);
    Test.stopTest();

    Interaction interactionUpdated = (Interaction) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    Assert.isTrue(
      interactionUpdated.Transfer__c == null,
      'Value of Transfer__c should not be updated with the given value in Interaction'
    );
  }

  /**
   * @description Method to prepare REST requests for test scenarios.
   * @param interactionId InteractionId
   * @param chatOrCallId Twilio Channel SID
   * @param chatOrCallStatus chat or call status from Twilio
   * @param agentEmail agentEmail from Twilio
   * @return `List<UpdateInteractionByTwilioPayload>` List of 'UpdateInteractionByTwilioPayload'
   */
  private static UpdateInteractionByTwilioPayload prepareRequest(
    String interactionId,
    String chatOrCallId,
    String chatOrCallStatus,
    String agentEmail
  ) {
    Faker faker = new Faker('AU');
    UpdateInteractionByTwilioPayload contextReq = new UpdateInteractionByTwilioPayload();
    contextReq.interactionId = interactionId;
    contextReq.chatOrCallId = chatOrCallId;
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = chatOrCallStatus;
    contextReq.agentEmail = agentEmail;

    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/InteractionContextRequestUpdates/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;
    return contextReq;
  }
  /**
   * @description helper method to create a mock interaction
   * @param interactionId faker interactionId
   * @param recordTypeId the recordTypeId of the Interaction
   * @param interactionType Interaction Purpose
   * @param chatOrCallSid mock Chat Or Call SID from Twilio
   * @return Mock Interaction
   */
  static Interaction createMockInteraction(
    Id interactionId,
    Id recordTypeId,
    String interactionType,
    String chatOrCallSid
  ) {
    Interaction mockInteraction = TestDataFactory.createInteraction(
      recordTypeId,
      InteractionConstants.CUSTOMER,
      'New Interaction',
      System.now(),
      false
    );

    mockInteraction.InteractionType = interactionType;
    mockInteraction.Direction__c = 'Inbound';
    mockInteraction.TwilioDetailsID__c = FAKER_TWILIO_ID;
    mockInteraction.Id = interactionId;
    mockInteraction.Chat_or_Call_SID__c = chatOrCallSid;
    mockInteraction.Status__c = 'New';
    return mockInteraction;
  }
  /**
   * @description helper method to create a mock interaction
   * @param agentId faker User Id
   * @param agentEmail mock Federation Identifier
   * @return Mock User Record as per agent email
   */
  static User createMockAgent(Id agentId, String agentEmail) {
    User mockAgent = TestUtil.createTestUser();
    mockAgent.FederationIdentifier = agentEmail;
    mockAgent.Id = agentId;
    return mockAgent;
  }
}
