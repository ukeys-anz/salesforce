/**
 * @author Kopal Goswami
 * @since  Sep 2024
 * @description Test class to cover tests for {@link InteractionRepository}
 */
@isTest
public with sharing class InteractionRepositoryTest {
      private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
    
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider interactionRepoMock;
    
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    interactionRepoMock = Lib_MockProvider.forType(InteractionRepository.class);
    interactionRepoMock.mock(
      'queryExistingInteractionFromCallOrChatSID',
      mockInteractionMap()
    );
    interactionRepoMock.mock(
      'fetchTwilioDetailIdFromInteraction',
      mockInteraction()
    );
    interactionRepoMock.mock('fetchExistingAccountByOCVId', mockAccount());
  }

  @testSetup
  static void testSetup() {
    // Assign Interaction related PS on current User
    List<String> psNames = new List<String>{
      'Chat_Read_Write',
      'Interaction_Read_Write',
      'API_Access_Twilio',
      'Enforce_mTLS',
      'Twilio_Detail_Read_Write',
      'Interaction_Integration'
    };
    TestUtil.addPermissionSets(psNames);
  }

  //Test method to validate that an interaction record is created when context request sent from Twilio has new ChatOrCallId
  @isTest
  private static void testPreventDuplicateInteractionNegative() {
    registerMocks();
	
    InteractionContextRequest intContext = createMockInteractionContextRequest(
      'CH12345678'
    );
    User thisUser = new User(Id = UserInfo.getUserId());
    Test.startTest();
    System.runAs(thisUser) {
      InteractionContextService.doPost(intContext);
    }
    Test.stopTest();
	Interaction interactionCreated = (Interaction) dmlRepoMock.getHistory(
        'doInsert'
      )
    .getParam('record');
     Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );
    
    Assert.areEqual(
      interactionCreated.Chat_or_Call_SID__c,
      'CH12345678',
      'Interaction Created Successfully'
    );
  }

  //Test method to validate that an interaction record is not created when context request sent from Twilio has existing ChatOrCallId
  @isTest
  private static void testPreventDuplicateInteractionPositive() {
    registerMocks();
    InteractionContextRequest intContext = createMockInteractionContextRequest(
      'CH1234567'
    );
    User thisUser = new User(Id = UserInfo.getUserId());
    Test.startTest();
    System.runAs(thisUser) {
      InteractionContextService.doPost(intContext);
    }
    Test.stopTest();
      
    Assert.isNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should not have been invoked'
    );
  }

  private static Map<String, Interaction> mockInteractionMap() {
    Map<String, Interaction> existingInteractionsBySID = new Map<String, Interaction>();
    Interaction testInteraction = new Interaction(
      Chat_or_Call_SID__c = 'CH1234567',
      Id = Lib_FakeIdGenerator.getMockId(Interaction.getSObjectType())
    );
    existingInteractionsBySID.put(
      testInteraction.Chat_or_Call_SID__c,
      testInteraction
    );
    return existingInteractionsBySID;
  }
    
   private static Interaction mockInteraction() {
    return new Interaction(
      Chat_or_Call_SID__c = 'CH1234567',
      Id = Lib_FakeIdGenerator.getMockId(Interaction.getSObjectType()),
      TwilioDetailsID__c = Lib_FakeIdGenerator.getMockId(
        Twilio_Details__c.getSObjectType()
      )     
    );
  }
    
    private static Account mockAccount() {
    Account testAccount = TestDataFactory.createPersonAccount('OCVID887766', false);
    testAccount.Id = FAKER_ACCOUNT_ID;
    return testAccount;
  }

  private static InteractionContextRequest createMockInteractionContextRequest(
    String chatOrCallSID
  ) {
    InteractionContextRequest contextReq = new InteractionContextRequest();
    contextReq.ocvId = 'OCVID887766';
    contextReq.chatOrCallId = chatOrCallSID;
    contextReq.issueSubtype = 'Coach - Call Us';
    contextReq.ppid = '';
    contextReq.direction = 'Inbound';
    contextReq.phoneNumber = '123456';
    contextReq.type = 'voice';
    contextReq.chatOrCallStatus = '';
    contextReq.isAuthenticated = false;

    InteractionContextRequest intContext = prepareRequest(contextReq);
    return intContext;
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
}
