/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Test class to cover tests for {@link InteractionContextService}
 * Added call and chat interaction logic to handle automatic creation of Interaction from Twilio
 */

@isTest
public with sharing class InteractionContextServiceTest {
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_TWILIO_ID = Lib_FakeIdGenerator.getMockId(
    Twilio_Details__c.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider interactionRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    interactionRepoMock = Lib_MockProvider.forType(InteractionRepository.class);
    interactionRepoMock.mock(
      'fetchExistingAccountByOCVId',
      createMockAccount('OCVID887766', '123457')
    );
    interactionRepoMock.mock(
      'fetchTwilioStatusMapping',
      new List<InteractionStatusMappingForTwilio__mdt>{
        new InteractionStatusMappingForTwilio__mdt(
          Twilio_Status__c = 'created',
          Interaction_Status__c = 'New'
        )
      }
    );
  }

  @isTest
  static void testValidChatInput() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );

    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + interactionId + '"}'
      )
    );
    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );
    interactionRepoMock.mock(
      'getInteractionDetails',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
        'Chat'
      )
    );

    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Chat',
      'OCVID887766',
      '123457',
      'Created',
      'Fraud'
    );

    Test.startTest();
    InteractionContextService.doPost(contextReq);
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer.
    Interaction interactionCreated = (Interaction) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );
    Assert.isTrue(
      interactionCreated.InteractionType == 'Chat',
      'Interaction Type should match'
    );
  }

  @isTest
  static void testInvalidChatInput() {
    registerMocks();
    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );

    // WHEN Twilio API user send a request with valid OCV ID and invalid Status
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Chat',
      'OCVID887766',
      '123457',
      'Created1',
      'Fraud'
    );
    Test.startTest();
    try {
      InteractionContextService.doPost(contextReq);
    } catch (Exception objectException) {
      Assert.isTrue(
        objectException.getMessage()
          .contains(
            'bad value for restricted picklist field: Created1: [Status__c]'
          ),
        'Interaction should not be created for invalid status value'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testValidCallInput() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );

    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + interactionId + '"}'
      )
    );
    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );
    interactionRepoMock.mock(
      'getInteractionDetails',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        'Call'
      )
    );

    // WHEN Twilio API user send a request with phoneNumber
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Voice',
      '',
      '123456',
      '',
      ''
    );

    Test.startTest();
    InteractionContextService.doPost(contextReq);
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer related to the Call
    Interaction interactionCreated = (Interaction) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );
    Assert.isTrue(
      interactionCreated.InteractionType == 'Call',
      'Interaction Type should match'
    );
  }

  @isTest
  static void testValidCallInputAuthenticated() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );

    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + interactionId + '"}'
      )
    );

    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );
    interactionRepoMock.mock(
      'getInteractionDetails',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        'Call'
      )
    );

    // WHEN Twilio API user send a request with phoneNumber
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Voice',
      'OCVID887766',
      '123456',
      '',
      'Coach - Call Us'
    );
    contextReq.isAuthenticated = true;

    Test.startTest();
    InteractionContextService.doPost(contextReq);
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer related to the Call
    Interaction interactionCreated = (Interaction) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );
    Assert.isTrue(
      interactionCreated.AccountId == FAKER_ACCOUNT_ID,
      'Interaction Should be Associated to Account'
    );
  }

  @isTest
  static void testValidCallInputAuthenticatedIssueSubtype() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );

    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + interactionId + '"}'
      )
    );

    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );
    interactionRepoMock.mock(
      'getInteractionDetails',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        'Call'
      )
    );

    // WHEN Twilio API user send a request with phoneNumber
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Voice',
      'OCVID887766',
      '123456',
      '',
      'TestValue'
    );
    contextReq.isAuthenticated = true;

    Test.startTest();
    InteractionContextService.doPost(contextReq);
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer related to the Call
    Interaction interactionCreated = (Interaction) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );

    Assert.isTrue(
      interactionCreated.Support_Topics__c == 'Support Enquiry',
      'Interaction Should be Created with Default Support Topic i.e Support Enquiry if valid value not provided'
    );
  }

  @isTest
  static void testInvalidCallInput() {
    registerMocks();
    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );

    // WHEN Twilio API user send a request without OCV Id and Phone Number
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Voice',
      '',
      '',
      '',
      ''
    );
    Test.startTest();
    InteractionContextService.doPost(contextReq);
    Test.stopTest();

    Assert.isNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should not have been invoked because both OCV ID and Phone Number are blank in request'
    );
  }

  @isTest
  static void testPushToAppTaskInput() {
    Faker faker = new Faker('AU');
    String pubSubEventId = 'Task' + faker.randomString(16);
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(
      Interaction.getSObjectType()
    );

    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + interactionId + '"}'
      )
    );
    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      new Map<String, Interaction>()
    );
    interactionRepoMock.mock(
      'queryPushToAppTaskDetails',
      createMockTask(
        RTTask.customerNudge,
        FAKER_ACCOUNT_ID,
        FAKER_CASE_ID,
        pubSubEventId
      )
    );
    interactionRepoMock.mock(
      'getInteractionDetails',
      createMockInteraction(
        interactionId,
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
        'Chat'
      )
    );

    // WHEN Twilio API user send a request with valid OCV ID
    // Prepare request test data
    InteractionContextRequest contextReq = prepareRequest(
      'Chat',
      'OCVID887766',
      '123457',
      'Created',
      'Fraud'
    );
    contextReq.pubSubEventId = pubSubEventId;

    Test.startTest();
    InteractionContextService.doPost(contextReq);
    Test.stopTest();

    // THEN the request must succeed, and a new Interaction should be created against the customer.
    Interaction interactionCreated = (Interaction) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isTrue(
      interactionCreated.CaseId__c == FAKER_CASE_ID,
      'Interaction Case should be populated because there is a task found'
    );
  }

  private static InteractionContextRequest prepareRequest(
    String interactionType,
    String ocvId,
    String phoneNumber,
    String chatOrCallStatus,
    String issueSubtype
  ) {
    Faker faker = new Faker('AU');

    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = ocvId;
    contextReq.chatOrCallId = 'CH' + faker.randomString(32);
    contextReq.issueSubtype = issueSubtype;
    contextReq.ppid = '1234';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = phoneNumber;
    contextReq.type = interactionType;
    contextReq.twilioId = 'TW' + faker.randomString(10);
    contextReq.callRecordingId = 'CR' + faker.randomString(10);
    contextReq.chatOrCallStatus = chatOrCallStatus;

    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/InteractionContextRequests/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    return contextReq;
  }

  /**
   * @description helper method to create a person account
   * @param ocvId the OCVId
   * @param phoneNumber the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static List<Account> createMockAccount(String ocvId, String phoneNumber) {
    Account testAccount = TestDataFactory.createPersonAccount(ocvId, false);
    testAccount.PersonMobilePhone = phoneNumber;
    testAccount.Id = FAKER_ACCOUNT_ID;
    return new List<Account>{ testAccount };
  }

  /**
   * @description helper method to create a mock interaction
   * @param interactionId faker interactionId
   * @param recordTypeId the recordTypeId of the Interaction
   * @param interactionType Interaction Purpose
   * @return Mock Interaction
   */
  static Interaction createMockInteraction(
    Id interactionId,
    Id recordTypeId,
    String interactionType
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
    mockInteraction.CaseId__c = FAKER_CASE_ID;
    mockInteraction.Id = interactionId;
    return mockInteraction;
  }

  /**
   * @description helper method to create a mock task
   * @param recordTypeId the recordTypeId of the Interaction
   * @param whoId mock account id
   * @param whatId mock caseId
   * @param pubSubEventId mock pubsubEventId
   * @return Mock Task
   */
  static List<Task> createMockTask(
    Id recordTypeId,
    Id whoId,
    Id whatId,
    String pubSubEventId
  ) {
    Id ownerId = UserInfo.getUserId();
    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      recordTypeId,
      whoId,
      whatId,
      ownerId,
      false
    );

    mockPushToAppTask.Pub_Sub_Event_Id__c = pubSubEventId;
    return new List<Task>{ mockPushToAppTask };
  }
}
