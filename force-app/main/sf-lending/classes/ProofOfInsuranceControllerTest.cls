/**
 * @description Test class for ProofOfInsuranceController.
 * @author Peter Charalambous
 * @since 08/2025
 */
@isTest
public class ProofOfInsuranceControllerTest {
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
    Settlement_ID__c = '1c792b92-626f-47ab-a7ae-9b576cd66039', // must match mock_proofOfInsurance.json
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

    // Load mock JSON from static resource
    String mockPOIJson = Service.getStaticResource('mock_proofOfInsurance');
    Map<String, Object> mockMap = (Map<String, Object>) JSON.deserializeUntyped(
      mockPOIJson
    );
    List<Object> poisRaw = (List<Object>) mockMap.get('proofOfInsurances');
    List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument> mockPOIs = (List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument>) JSON.deserialize(
      JSON.serialize(poisRaw),
      List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument>.class
    );

    // Mock repository responses
    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('getProofOfInsurance', mockPOIs);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      ProofOfInsuranceController controller = new ProofOfInsuranceController();

      Map<String, Object> paramMap = new Map<String, Object>{
        'recordId' => mockSettlement.Id
      };
      String paramJson = JSON.serialize(paramMap);

      Test.startTest();
      Object result = controller.getData(paramJson);
      Test.stopTest();

      // Cast result to expected type
      List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument> resultList = (List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument>) result;

      // Assert against actual values from mock_proofOfInsurance.json
      LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument expected = mockPOIs[0];
      LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument actual = resultList[0];

      System.assertEquals(
        '1c792b92-626f-47ab-a7ae-9b576cd66039',
        actual.settlementId,
        'SettlementId should match'
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
      ProofOfInsuranceController controller = new ProofOfInsuranceController();

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
            .contains('Failed to retrieve Proof Of Insurance details'),
          'Should throw custom error message'
        );
      }
      System.assert(thrown, 'Exception should be thrown on repository failure');
    }
  }

  @isTest
  static void testSuccessVerifyInsurance() {
    registerMocks();

    // Prepare mock response
    VerifyInsuranceModel mockResponse = new VerifyInsuranceModel();
    VerifyInsuranceModel.ProofOfInsuranceVerification verification = new VerifyInsuranceModel.ProofOfInsuranceVerification();
    verification.state = 'STATE_VERIFIED';
    mockResponse.proofOfInsuranceVerification = verification;

    settlementRepoMock.mock('getSettlement', mockSettlement);
    lexApiRepoMock.mock('verifyInsurance', mockResponse);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      Test.startTest();
      VerifyInsuranceModel response = ProofOfInsuranceController.verifyInsurance(
        mockSettlement.Settlement_ID__c,
        faker.randomString(10),
        faker.randomString(10),
        faker.randomString(10),
        faker.randomString(10)
      );
      Test.stopTest();

      System.assertEquals(
        'STATE_VERIFIED',
        response.proofOfInsuranceVerification.state,
        'State should be verified'
      );
    }
  }

  @isTest
  static void testInvalidVerifyInsurance() {
    registerMocks();
    settlementRepoMock.mock('getSettlement', mockSettlement);

    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      Test.startTest();
      Boolean thrown = false;
      try {
        ProofOfInsuranceController.verifyInsurance('', '', '', '', '');
      } catch (AuraHandledException e) {
        thrown = true;
        System.assert(
          e.getMessage().contains(ProofOfInsuranceController.TECH_ASSIST_ERROR),
          'Exception message should be thrown for missing data'
        );
      }
      Test.stopTest();
      System.assert(thrown, 'Exception should be thrown for missing data');
    }
  }
}
