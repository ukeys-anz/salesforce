/**
 * @description Test class for RepaymentPreferencesController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@isTest
public class RepaymentPreferencesControllerTest {
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

    String mockRepaymentsJson = Service.getStaticResource(
      'mock_automaticrepayments'
    );
    Map<String, Object> mockMap = (Map<String, Object>) JSON.deserializeUntyped(
      mockRepaymentsJson
    );
    List<Object> prefsRaw = (List<Object>) mockMap.get(
      'automaticRepaymentPreferences'
    );
    List<LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences> mockRepaymentPreferences = (List<LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences>) JSON.deserialize(
      JSON.serialize(prefsRaw),
      List<LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences>.class
    );

    // Create the response wrapper
    LexAPIRepository.ListAutomaticRepaymentPreferencesResponse mockResponse = new LexAPIRepository.ListAutomaticRepaymentPreferencesResponse();
    mockResponse.automaticRepaymentPreferences = mockRepaymentPreferences;

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('listAutomaticRepaymentPreferences', mockResponse);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      RepaymentPreferencesController controller = new RepaymentPreferencesController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id
      };
      String paramJson = JSON.serialize(paramMap);

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      // Cast result to the expected type
      LexAPIRepository.ListAutomaticRepaymentPreferencesResponse resultResponse = (LexAPIRepository.ListAutomaticRepaymentPreferencesResponse) result;

      List<LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences> resultList = resultResponse.automaticRepaymentPreferences;

      System.assertNotEquals(null, resultList, 'Result should not be null');
      System.assert(resultList.size() > 0, 'Result list should not be empty');
      System.assertEquals(
        mockRepaymentPreferences[0].id,
        resultList[0].id,
        'Repayment preference id should match mock'
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
      RepaymentPreferencesController controller = new RepaymentPreferencesController();

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
            .contains('Failed to retrieve Automatic Repayment Preferences'),
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
