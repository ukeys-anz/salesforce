/**
 * @author Nilesh Kalal
 * @since May 2026
 * @description Test class for CTI_InteractionHandler
 */
@IsTest
public with sharing class CTI_InteractionHandlerTest {
  private static final Id FAKER_INTERACTION_ID = Lib_FakeIdGenerator.getMockId(
    Interaction.getSObjectType()
  );

  private static final String FAKER_CONTACT_ID = '1234567890';
  private static final String FAKER_ORIGINAL_CONTACT_ID = '0987654321';

  static Lib_MockProvider ctiRepoMock;

  static void registerMocks() {
    ctiRepoMock = Lib_MockProvider.forType(CTI_InteractionRepository.class);
  }

  /**
   * @description Test onCallAccepted method with valid interaction found
   */
  @isTest
  static void testOnCallAcceptedWithValidInteraction() {
    registerMocks();
    ctiRepoMock.mock('queryInteractionBySID', mockInteractionRecord());

    String jsonData = mockCTIJsonData(
      FAKER_ORIGINAL_CONTACT_ID,
      FAKER_CONTACT_ID
    );

    Test.startTest();
    String interactionId = CTI_InteractionHandler.onCallAccepted(jsonData);
    Test.stopTest();

    Assert.areEqual(
      FAKER_INTERACTION_ID,
      interactionId,
      'Interaction Id should match the mock interaction id'
    );
  }

  /**
   * @description Test onCallAccepted method when interaction is not found
   */
  @isTest
  static void testOnCallAcceptedWithNoInteraction() {
    registerMocks();
    ctiRepoMock.mock('queryInteractionBySID', null);

    String jsonData = mockCTIJsonData(
      FAKER_ORIGINAL_CONTACT_ID,
      FAKER_CONTACT_ID
    );

    Test.startTest();
    String interactionId = CTI_InteractionHandler.onCallAccepted(jsonData);
    Test.stopTest();

    Assert.isNull(
      interactionId,
      'Interaction Id should be null when no interaction is found'
    );
  }

  /**
   * @description Test onCallAccepted method with only contactId (no originalContactId)
   */
  @isTest
  static void testOnCallAcceptedWithContactIdOnly() {
    registerMocks();
    ctiRepoMock.mock('queryInteractionBySID', mockInteractionRecord());

    String jsonData = mockCTIJsonData(null, FAKER_CONTACT_ID);

    Test.startTest();
    String interactionId = CTI_InteractionHandler.onCallAccepted(jsonData);
    Test.stopTest();

    Assert.areEqual(
      FAKER_INTERACTION_ID,
      interactionId,
      'Interaction Id should be found using contactId when originalContactId is null'
    );
  }

  /**
   * @description Test getAmazonConnectUrl method when URL field is null
   */
  @isTest
  static void testGetAmazonConnectUrlNullUrlField() {
    Test.startTest();
    String connectUrl = CTI_InteractionHandler.getAmazonConnectUrl();
    Test.stopTest();

    Assert.areEqual(
      null,
      connectUrl,
      'Amazon Connect URL should be null when URL field is null'
    );
  }

  /**
   * @description Helper method to create mock CTI JSON data
   * @param originalContactId The original contact ID
   * @param contactId The contact ID
   * @return JSON string representing CTI details
   */
  private static String mockCTIJsonData(
    String originalContactId,
    String contactId
  ) {
    Map<String, Object> ctiData = new Map<String, Object>{
      'originalContactId' => originalContactId,
      'contactId' => contactId
    };
    return JSON.serialize(ctiData);
  }

  /**
   * @description Helper method to create a mock Interaction record
   * @return Mock Interaction record
   */
  private static Interaction mockInteractionRecord() {
    Interaction mockInteraction = new Interaction();
    mockInteraction.Id = FAKER_INTERACTION_ID;
    mockInteraction.OwnerId = UserInfo.getUserId();
    return mockInteraction;
  }
}
