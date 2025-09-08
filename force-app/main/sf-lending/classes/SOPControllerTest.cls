/**
 * @author Lance Shi
 * @since Nov 2024
 * @description Test class for SOP GetConsolidated V1b2 model
 */
@IsTest
public class SOPControllerTest {
  static Lib_MockProvider rlarRepoMock;
  static Lib_MockProvider rlaApiMock;
  static Lib_MockProvider accRepoMock;
  static Lib_MockProvider expControlRepoMock;

  static void registerMocks() {
    rlarRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock('queryRLAById', relatedRla)
      .mock(
        'queryRelatedProperties',
        new List<LoanApplicationProperty>{ relatedProperty }
      )
      .mock(
        'getLoanApplicationLiability',
        new List<LoanApplicationLiability>{ loanAppLiabilities }
      )
      .mock(
        'getLoanApplicants',
        new List<LoanApplicant>{ applicants, applicantB }
      );
    accRepoMock = Lib_MockProvider.forType(LendingAccountRepository.class)
      .mock('queryAccountsByOcvIds', relatedCustomers);
    expControlRepoMock = Lib_MockProvider.forType(
        ExpenseControlRepository.class
      )
      .mock(
        'getExpenseControlByExpenseCode',
        new List<Expense_Control__c>{ relatedExpenseControl }
      );
  }
  static Id lapIds = Lib_FakeIdGenerator.getMockId(
    LoanApplicationProperty.SObjectType
  );
  static Id rlaIds = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );

  static List<Account> relatedCustomers {
    get {
      Account a = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        FirstName = 'FakeNameA',
        OCV_ID__c = '1000991493'
      );
      Account b = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        FirstName = 'FakeNameB',
        OCV_ID__c = '276543221'
      );
      return new List<Account>{ a, b };
    }
  }

  static LoanApplicationProperty relatedProperty {
    get {
      return new LoanApplicationProperty(
        Id = Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType),
        Property_ID__c = lapIds,
        PropertyValue = 5000000.01,
        LoanApplicationId = rlaIds,
        Name = '639 collins st docklands vic 3000'
      );
    }
  }

  static Expense_Control__c relatedExpenseControl {
    get {
      return new Expense_Control__c(
        Id = Lib_FakeIdGenerator.getMockId(Expense_Control__c.SObjectType),
        Justification_Code__c = 'JGR03',
        Justification_Description__c = 'Intend to cut down spending'
      );
    }
  }

  static ResidentialLoanApplication relatedRla {
    get {
      ResidentialLoanApplication rla = new ResidentialLoanApplication(
        Id = rlaIds,
        Assessment_Outcome__c = 'Approved',
        Status = 'STATE_REFERRED',
        Credit_ID__c = 'Test',
        SOP_Id__c = 'TestId',
        Name = 'TestRla',
        Account = new Account(
          Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          FirstName = 'FakeNameB',
          OCV_ID__c = '276543221'
        )
      );
      return rla;
    }
  }

  static LoanApplicationLiability loanAppLiabilities {
    get {
      return new LoanApplicationLiability(
        Id = Lib_FakeIdGenerator.getMockId(
          LoanApplicationLiability.SObjectType
        ),
        Name = '639 collins st docklands vic 3000',
        LoanApplicationId = rlaIds
      );
    }
  }

  static LoanApplicant applicants {
    get {
      Faker faker = new Faker('AU');
      return new LoanApplicant(
        Id = Lib_FakeIdGenerator.getMockId(LoanApplicant.SObjectType),
        Name = faker.person.name(),
        LoanApplicationId = rlaIds,
        Account__c = relatedCustomers[0].Id
      );
    }
  }

  static LoanApplicant applicantB {
    get {
      Faker faker = new Faker('AU');
      return new LoanApplicant(
        Id = Lib_FakeIdGenerator.getMockId(LoanApplicant.SObjectType),
        Name = faker.person.name(),
        LoanApplicationId = rlaIds,
        Account__c = relatedCustomers[1].Id
      );
    }
  }

  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    // Create coach user
    System.runAs(TestDataFactory.thisUser) {
      User coachUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'TestCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coachUser;
      //Assign Permission set group as coach
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
  static void testGetConsolidatedSOP() {
    registerMocks();
    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      SOPGetConsolidatedViewModel viewModel = SOPController.getConsolidatedSOP(
        rlaIds
      );
      System.assertEquals(
        true,
        viewModel.sopSummaryViewModel.allPartiesConsented,
        'All parties consented should be true'
      );
    }
  }

  @isTest
  static void testGetBelongsToOptions() {
    Faker faker = new Faker('AU');
    registerMocks();
    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      List<Map<String, String>> parties = new List<Map<String, String>>();
      parties.add(
        new Map<String, String>{
          'ocvId' => '1000991493',
          'partyId' => faker.randomString(10)
        }
      );
      parties.add(
        new Map<String, String>{
          'ocvId' => '276543221',
          'partyId' => faker.randomString(10)
        }
      );
      List<Map<String, String>> uiOptions = new List<Map<String, String>>();

      Test.startTest();
      uiOptions = SOPController.getBelongsToOptions(parties, rlaIds);
      Test.stopTest();

      Assert.areEqual(3, uiOptions.size(), 'Expected option size to be 3');
    }
  }

  @isTest
  static void testAddDebt() {
    registerMocks();
    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      SOPAddEditDebtModel debtDetails = new SOPAddEditDebtModel();

      Test.startTest();
      Boolean result = SOPController.addEditDebt(rlaIds, debtDetails, 'Add');
      Test.stopTest();

      Assert.isTrue(result, 'Expected result to be true');
    }
  }

  @isTest
  static void testEditDebt() {
    registerMocks();
    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      SOPAddEditDebtModel debtDetails = new SOPAddEditDebtModel();

      Test.startTest();
      Boolean result = SOPController.addEditDebt(rlaIds, debtDetails, 'Edit');
      Test.stopTest();

      Assert.isTrue(result, 'Expected result to be true');
    }
  }

  @isTest
  static void testAddIncome() {
    registerMocks();
    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      SOPAddEditIncomeModel incomeDetails = new SOPAddEditIncomeModel();
      incomeDetails.incomeVerified = true;
      Test.startTest();
      String result = SOPController.addIncome(rlaIds, incomeDetails);
      Test.stopTest();

      Assert.areEqual('Success', result, 'Expected result to be success');
    }
  }

  @isTest
  static void testEditIncome() {
    registerMocks();

    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      SOPAddEditIncomeModel incomeDetails = new SOPAddEditIncomeModel();
      incomeDetails.incomeVerified = false;

      Test.startTest();
      String result = SOPController.editIncome(rlaIds, incomeDetails);
      Test.stopTest();

      Assert.areEqual('Success', result, 'Expected result to be success');
    }
  }

  @isTest
  static void testDeleteIncome() {
    registerMocks();

    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      Test.startTest();
      Boolean result = SOPController.deleteIncome(
        rlaIds,
        'TestIncome',
        'TestEtag'
      );
      Test.stopTest();

      Assert.isTrue(result, 'Expected result to be true');
    }
  }

  @isTest
  static void testDeleteDebt() {
    registerMocks();

    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      Test.startTest();
      Boolean result = SOPController.deleteDebt(rlaIds, 'TestDebt', 'TestEtag');
      Test.stopTest();

      Assert.isTrue(result, 'Expected result to be true');
    }
  }
}
