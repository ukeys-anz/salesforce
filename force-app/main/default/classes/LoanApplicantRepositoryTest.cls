/**
 * @author Satish Badiger
 * @since August 2025
 * @description
 */
@isTest
public with sharing class LoanApplicantRepositoryTest {
  static Lib_MockProvider loanApplicantMock;
  public final static Faker TESTFAKER = new Faker('AU');
  static String personaId = TESTFAKER.randomString(10);
  static void registerMocks() {
    loanApplicantMock = Lib_MockProvider.forType(LoanApplicant.class);
  }

  static LoanApplicant getLA {
    get {
      return new LoanApplicant(
        Id = Lib_FakeIdGenerator.getMockId(LoanApplicant.SObjectType),
        Name = 'Test Loan Applicant',
        LoanApplicationId = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        ),
        Account__c = getAccount.Id,
        Persona_Id__c = personaId
      );
    }
  }

  static Account getAccount {
    get {
      return new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Account'
      );
    }
  }

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
  static void testQueryLoanApplicationOfApplicants() {
    Set<Id> loanApplicantIds = new Set<Id>();
    LoanApplicant la = getLA;
    loanApplicantIds.add(la.Id);
    LoanApplicantRepository loanApplicantRepo = new LoanApplicantRepository();

    Test.startTest();
    List<LoanApplicant> response = loanApplicantRepo.queryLoanApplicationOfApplicants(
      loanApplicantIds
    );
    Test.stopTest();

    Assert.areEqual(
      la.name,
      'Test Loan Applicant',
      'Loan Applicant name should be same'
    );
  }

  @isTest
  static void testGetLoanApplicantByPersonaId() {
    LoanApplicantRepository loanApplicantRepo = new LoanApplicantRepository();
    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      Test.startTest();
      LoanApplicant response = loanApplicantRepo.getLoanApplicantByPersonaId(
        personaId
      );
      Test.stopTest();
    }

    Assert.areEqual(getLA.Persona_Id__c, personaId, 'PersonaId should be same');
  }
}
