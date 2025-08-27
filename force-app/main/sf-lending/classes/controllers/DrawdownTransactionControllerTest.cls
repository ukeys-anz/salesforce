/**
 * @description Test class for DrawDownTransactionController.
 * @author Peter Charalambous
 * @since 08/2025
 */
@isTest
public class DrawdownTransactionControllerTest {
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

    // Load mock drawdown from static resource
    String mockDrawdownJson = Service.getStaticResource('mock_getDrawdown');
    LexSLMV1alpha2LoanManagementTypes.Drawdown mockDrawdown = (LexSLMV1alpha2LoanManagementTypes.Drawdown) JSON.deserialize(
      mockDrawdownJson,
      LexSLMV1alpha2LoanManagementTypes.Drawdown.class
    );

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getDrawdown', mockDrawdown);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      DrawDownTransactionController controller = new DrawDownTransactionController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id,
        'id' => mockDrawdown.id
      };
      String paramJson = JSON.serialize(paramMap);

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      LexSLMV1alpha2LoanManagementTypes.Drawdown resultDrawdown = (LexSLMV1alpha2LoanManagementTypes.Drawdown) result;

      System.assertEquals(
        mockDrawdown.id,
        resultDrawdown.id,
        'Drawdown id should match mock'
      );
      System.assertEquals(
        mockDrawdown.drawdownType,
        resultDrawdown.drawdownType,
        'Drawdown type should match mock'
      );
    }
  }

  @isTest
  static void testGetDataNotScheduled() {
    registerMocks();

    // Mock response with state not scheduled
    LexSLMV1alpha2LoanManagementTypes.Drawdown mockDrawdown = new LexSLMV1alpha2LoanManagementTypes.Drawdown();
    mockDrawdown.id = faker.randomString(10);
    mockDrawdown.state = 'STATE_COMPLETED';
    mockDrawdown.scheduledReason = 'SCHEDULED_REASON_PENDING_TRANSACTIONS_DETECTED';

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getDrawdown', mockDrawdown);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      DrawDownTransactionController controller = new DrawDownTransactionController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id,
        'id' => mockDrawdown.id
      };
      String paramJson = JSON.serialize(paramMap);

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      LexSLMV1alpha2LoanManagementTypes.Drawdown resultDrawdown = (LexSLMV1alpha2LoanManagementTypes.Drawdown) result;

      // Assert that the scheduledReason is not the original mock value
      System.assertNotEquals(
        'SCHEDULED_REASON_PENDING_TRANSACTIONS_DETECTED',
        resultDrawdown.scheduledReason,
        'Scheduled reason should not match the mock value if not scheduled'
      );
      // Assert that the scheduledReason is actually an empty string
      System.assertEquals(
        '',
        resultDrawdown.scheduledReason,
        'Scheduled reason should be empty string if not scheduled'
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
      DrawDownTransactionController controller = new DrawDownTransactionController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id,
        'id' => faker.randomString(10)
      };
      String paramJson = JSON.serialize(paramMap);

      Boolean thrown = false;
      try {
        controller.getData(paramJson);
      } catch (AuraHandledException e) {
        thrown = true;
        System.assert(
          e.getMessage().contains('Failed to retrieve Drawdown details'),
          'Should throw custom error message'
        );
      }
      System.assert(thrown, 'Exception should be thrown on repository failure');
    }
  }
}
