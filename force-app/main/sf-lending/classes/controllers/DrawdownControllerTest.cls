/**
 * @description Test class for DrawdownController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@isTest
public class DrawdownControllerTest {
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

    String mockDrawdownsJson = Service.getStaticResource('mock_drawdowns');
    Map<String, Object> mockMap = (Map<String, Object>) JSON.deserializeUntyped(
      mockDrawdownsJson
    );
    List<Object> drawdownsRaw = (List<Object>) mockMap.get('drawdowns');
    List<LexSettlementV1b1SettlementTypes.Drawdown> mockDrawdownList = (List<LexSettlementV1b1SettlementTypes.Drawdown>) JSON.deserialize(
      JSON.serialize(drawdownsRaw),
      List<LexSettlementV1b1SettlementTypes.Drawdown>.class
    );

    // Create the response wrapper
    LexAPIRepository.DrawdownResponse mockResponse = new LexAPIRepository.DrawdownResponse();
    mockResponse.drawdowns = mockDrawdownList;

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getListDrawdowns', mockResponse);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      DrawdownController controller = new DrawdownController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id
      };
      String paramJson = JSON.serialize(paramMap);

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      // Cast result to the expected type
      LexAPIRepository.DrawdownResponse resultResponse = (LexAPIRepository.DrawdownResponse) result;

      List<LexSettlementV1b1SettlementTypes.Drawdown> resultList = resultResponse.drawdowns;

      System.assertNotEquals(null, resultList, 'Result should not be null');
      System.assert(resultList.size() > 0, 'Result list should not be empty');
      System.assertEquals(
        mockDrawdownList[0].id,
        resultList[0].id,
        'Drawdown id should match mock'
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
      DrawdownController controller = new DrawdownController();

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
          e.getMessage().contains('Failed to retrieve Drawdown details'),
          'Should throw custom error message'
        );
      }
      System.assert(thrown, 'Exception should be thrown on repository failure');
    }
  }
}
