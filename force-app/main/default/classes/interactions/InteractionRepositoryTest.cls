/**
 * @author Kopal Goswami
 * @since  Sep 2024
 * @description Test class to cover tests for {@link InteractionRepository}
 */
@isTest
public with sharing class InteractionRepositoryTest {
  static void registerMocks() {
    Lib_MockProvider.forType(InteractionRepository.class)
      .mock('queryExistingInteractionFromCallOrChatSID', mockInteractionMap());
    Lib_MockProvider.forType(InteractionRepository.class)
      .mock('fetchTwilioDetailIdFromInteraction', mockInteraction());
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
      'Interaction_Integration',
      'FinancialServicesCloudExtension'
    };
    TestUtil.addPermissionSets(psNames);
  }

  //Test method to validate that an interaction record is created when context request sent from Twilio has new ChatOrCallId
  @isTest
  private static void testpreventDuplicateInteractionNegative() {
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

    List<Interaction> intList = [
      SELECT Id, InteractionType
      FROM Interaction
      WHERE InteractionType = 'Call'
      LIMIT 1
    ];
    System.assertEquals(
      1,
      intList.size(),
      'Interaction should be created with new ChatOrCallSID'
    );
  }

  //Test method to validate that an interaction record is not created when context request sent from Twilio has existing ChatOrCallId
  @isTest
  private static void testpreventDuplicateInteractionPositive() {
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
    List<Interaction> intList = [
      SELECT Id, Support_Topics__c, InteractionType
      FROM Interaction
      WHERE InteractionType = 'Call'
      LIMIT 1
    ];
    System.assertEquals(
      0,
      intList.size(),
      'Interaction should not be created with existing ChatOrCallSID'
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
      Id = Lib_FakeIdGenerator.getMockId(
        Interaction.getSObjectType()
      ),
      TwilioDetailsID__c = Lib_FakeIdGenerator.getMockId(
        Twilio_Details__c.getSObjectType()
      )     
    );
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
    contextReq.type = 'Voice';
    contextReq.chatOrCallStatus = '';
    contextReq.isAuthenticated = false;

    InteractionContextRequest intContext = InteractionContextServiceTest.prepareRequest(
      contextReq
    );
    return intContext;
  }
}
