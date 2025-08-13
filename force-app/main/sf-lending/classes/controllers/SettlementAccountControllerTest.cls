/**
 * @description Test class for SettlementAccountController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@isTest
public class SettlementAccountControllerTest {
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
  static List<LexSettlementV1b1SettlementTypes.SettlementAccount> mockSettlementAccounts = new List<LexSettlementV1b1SettlementTypes.SettlementAccount>{
    new LexSettlementV1b1SettlementTypes.SettlementAccount()
  };

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

    // Prepare mock response wrapper
    LexAPIRepository.SettlementAccountResponse mockResponse = new LexAPIRepository.SettlementAccountResponse();
    mockResponse.settlementAccounts = mockSettlementAccounts;

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getSettlementAccount', mockResponse);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      SettlementAccountController controller = new SettlementAccountController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id
      };
      String paramJson = JSON.serialize(paramMap);

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      // Cast result to the expected type
      LexAPIRepository.SettlementAccountResponse resultResponse = (LexAPIRepository.SettlementAccountResponse) result;

      List<LexSettlementV1b1SettlementTypes.SettlementAccount> resultList = resultResponse.settlementAccounts;

      System.assertNotEquals(null, resultList, 'Result should not be null');
      System.assertEquals(
        mockSettlementAccounts,
        resultList,
        'Settlement accounts list should match mock'
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
      SettlementAccountController controller = new SettlementAccountController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id
      };
      String paramJson = JSON.serialize(paramMap);

      Boolean thrown = false;
      try {
        controller.getData(paramJson);
      } catch (AuraHandledException e) {
        thrown = true;
        System.assert(
          e.getMessage()
            .contains('Failed to retrieve Settlement Account details'),
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
