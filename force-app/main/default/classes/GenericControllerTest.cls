/**
 * @description Test class for GenericController.
 * @author Mohit Tripathi
 * @since 08/2025
 */
@isTest
public class GenericControllerTest {
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
  static void testGetConfigSuccess() {
    String configName = 'config_getDrawdown';
    test.StartTest();
    Object result = GenericController.getConfig(configName);
    test.StopTest();
    Assert.isTrue(result != null, 'Config should not be null');
  }

  @isTest
  static void testGetConfigThrowsAuraHandledException2() {
    Boolean thrown = false;
    try {
      GenericController.getConfig('');
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.isTrue(
        e.getMessage().contains('Script-thrown exception'),
        'Should throw custom error message'
      );
    }
    Assert.isTrue(thrown, 'Exception should be thrown on repository failure');
  }

  @isTest
  static void testGetDataSuccess() {
    registerMocks();
    String mockDrawdownJson = Service.getStaticResource('mock_getDrawdown');
    LexSLMV1alpha2LoanManagementTypes.Drawdown mockDrawdown = (LexSLMV1alpha2LoanManagementTypes.Drawdown) JSON.deserialize(
      mockDrawdownJson,
      LexSLMV1alpha2LoanManagementTypes.Drawdown.class
    );

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getDrawdown', mockDrawdown);
    String apexControllerName = 'DrawDownTransactionController';
    Map<String, Object> paramMap = new Map<String, Object>{
      'recordId' => mockSettlement.Id,
      'id' => mockDrawdown.id
    };
    String paramJson = JSON.serialize(paramMap);
    test.StartTest();
    Object result = GenericController.getData(apexControllerName, paramJson);
    test.StopTest();
    Assert.isTrue(result != null, 'Data should not be null');
  }

  @isTest
  static void testGetDataThrowsAuraHandledException2() {
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
      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id,
        'id' => faker.randomString(10)
      };
      String paramJson = JSON.serialize(paramMap);

      Boolean thrown = false;
      try {
        GenericController.getData('', paramJson);
      } catch (AuraHandledException e) {
        thrown = true;
        Assert.isTrue(
          e.getMessage().contains('Script-thrown exception'),
          'Should throw custom error message'
        );
      }
      Assert.isTrue(thrown, 'Exception should be thrown on repository failure');
    }
  }
}
