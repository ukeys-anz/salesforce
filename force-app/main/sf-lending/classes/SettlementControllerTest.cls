/**
 * @description Test class for SettlementController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@isTest
public class SettlementControllerTest {
  static Lib_MockProvider settlementRepoMock;
  static Lib_MockProvider lexApiRepoMock;

  static void registerMocks() {
    settlementRepoMock = Lib_MockProvider.forType(SettlementRepository.class);
    lexApiRepoMock = Lib_MockProvider.forType(LexAPIRepository.class);
  }

  static Faker faker = new Faker('AU');

  static Account mockAccount = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    OCV_ID__c = faker.randomString(10)
  );
  static ResidentialLoanApplication mockLoanApp = new ResidentialLoanApplication(
    Id = Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType),
    Account = mockAccount
  );
  static Settlement__c mockSettlement = new Settlement__c(
    Id = Lib_FakeIdGenerator.getMockId(Settlement__c.SObjectType),
    Settlement_ID__c = faker.randomString(10),
    Loan_Application_Number__c = mockLoanApp.Id,
    Loan_Application_Number__r = mockLoanApp
  );

  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    System.runAs(TestDataFactory.thisUser) {
      User coachUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'TestCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coachUser;
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
    }
  }

  @isTest
  static void testGetDataSuccess() {
    registerMocks();

    String mockSettlementJson = Service.getStaticResource('mock_settlement');
    LexSettlementV1b1SettlementTypes.Settlement mockApiResult = (LexSettlementV1b1SettlementTypes.Settlement) JSON.deserialize(
      mockSettlementJson,
      LexSettlementV1b1SettlementTypes.Settlement.class
    );

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getSettlement', mockApiResult);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      SettlementController controller = new SettlementController();

      String paramJson = JSON.serialize(
        new Map<String, Object>{ 'recordId' => mockSettlement.Id }
      );

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      LexSettlementV1b1SettlementTypes.Settlement settlementResult = (LexSettlementV1b1SettlementTypes.Settlement) result;

      System.assertNotEquals(
        null,
        settlementResult.id,
        'Settlement id should not be null'
      );

      System.assertEquals(
        mockApiResult.id,
        settlementResult.id,
        'API result id should match mock'
      );
    }
  }

  @isTest
  static void testGetDataThrowsAuraHandledException() {
    registerMocks();
    settlementRepoMock.mockException(
      'getSettlement',
      new QueryException('Mocked failure')
    );

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      SettlementController controller = new SettlementController();
      Boolean thrown = false;

      // Prepare JSON param as expected by controller
      String paramJson = JSON.serialize(
        new Map<String, Object>{ 'recordId' => mockSettlement.Id }
      );

      try {
        controller.getData(paramJson);
      } catch (AuraHandledException e) {
        thrown = true;
        System.assert(
          e.getMessage().contains('Failed to retrieve settlement details'),
          'Should throw custom error message'
        );
      }
      System.assert(thrown, 'Exception should be thrown on repository failure');
      System.assertEquals(
        1,
        settlementRepoMock.getHistories('getSettlement').size(),
        'getSettlement should be called once'
      );
    }
  }
}
