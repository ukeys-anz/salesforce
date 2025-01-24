/**
 * @author Sanskriti Routray
 * @since 12/2024
 * @description CoachCollaborationControllerTest is the test class for CoachCollaborationController Class functionality.
 */
@isTest
public with sharing class CoachCollaborationControllerTest {
  private static final Id FAKER_INTERACTION_ID = Lib_FakeIdGenerator.getMockId(
    Interaction.getSObjectType()
  );
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  private static final String ACCOUNT_OCV_ID = '2200993355';

  private static String interactionRecord =
    '{"Id":"' +
    FAKER_INTERACTION_ID +
    '","AccountId":"' +
    FAKER_ACCOUNT_ID +
    '","RecordTypeId":"1213213123123","Account":{"attributes":{"type":"Account","url":"/services/data/v60.0/sobjects/Account/' +
    FAKER_ACCOUNT_ID +
    '"},"Id":"' +
    FAKER_ACCOUNT_ID +
    '","PersonContactId":"003Bm00000GCPnqIAH","OCV_Id__c":"' +
    ACCOUNT_OCV_ID +
    '","Source_System_ID__c":"111111000000"}}';

  private static String accountRecord =
    '{"Id":"' +
    FAKER_ACCOUNT_ID +
    '","PersonContactId":"003Bm00000GCPnqIAH","OCV_Id__c":"' +
    ACCOUNT_OCV_ID +
    '","Source_System_ID__c":"111111000000"}';

  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    Lib_MockProvider.forType(InteractionRepository.class)
      .mock('fetchOCVId', fetchOCVIdFromInteraction());

    Lib_MockProvider.forType(CoachCollaborationController.class)
      .mock('getStaffRequestModelByOcvId', getStaffRequestModelByOcvId());
    Lib_MockProvider.forType(InteractionRepository.class)
      .mock('findAccountByOCVId', findAccountByOCVId());
  }

  /**
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
    //Create anzxTestUser with ANZx Standard User Profile
    Profile anzxProfile = CommonUtil.getProfileByName('ANZx Standard User');
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      User anzxTestUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'ANZx_Test_User',
          'ProfileId' => anzxProfile.Id
        }
      );
      insert anzxTestUser;
    }

  }

  @isTest
  private static void fetchJWETokenFromFrigTest() {
    registerMocks();
    String result = '';
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');
    Test.startTest();
    System.runAs(anzxTestUser) {
      result = CoachCollaborationController.fetchJWETokenFromFrig(
        'Interaction',
        FAKER_INTERACTION_ID
      );
    }
    Test.stopTest();
    Task taskRecord = (Task) dmlRepoMock.getHistory('doInsert')
      .getParam('record');
    Assert.isTrue(
      result.startsWith('https'),
      'The accessToken should be as expected.'
    );
    Assert.isTrue(taskRecord != null, 'One Task Record Should be Created');
  }

  private static SObject fetchOCVIdFromInteraction() {
    return (SObject) JSON.deserialize(interactionRecord, Interaction.class);
  }

  private static StaffTokenRequestModel getStaffRequestModelByOcvId() {
    StaffTokenRequestModel staffModelWrapper = new StaffTokenRequestModel();
    staffModelWrapper.idType = Service.IdType.OCVID;
    staffModelWrapper.idValue = '1111';
    String hashedKey = AuthTokenCacheUtil.getHashedKey(
      'forgeJWTToken' +
        staffModelWrapper.idValue +
        staffModelWrapper.apiScopesRequested
    );
    Cache.Session.put(
      'local.ForgeToken.' + hashedKey,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    return staffModelWrapper;
  }

  private static Account findAccountByOCVId() {
    return (Account) JSON.deserialize(accountRecord, Account.class);
  }
}
