/**
 * @author Lance Shi
 * @since Nov 2024
 * @description Test class for SOP GetConsolidated model
 */
@IsTest
public class SOPGetConsolidatedViewModelTest {
  static Lib_MockProvider rlarRepoMock;
  static Lib_MockProvider expControlRepoMock;

  static void registerMocks() {
    rlarRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock(
        'queryRelatedProperties',
        new List<LoanApplicationProperty>{ relatedProperty }
      )
      .mock(
        'getLoanApplicationLiability',
        new List<LoanApplicationLiability>{ loanAppLiabilities }
      );
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
  static void testConvertModel() {
    registerMocks();
    User coachUser = [SELECT Id FROM User WHERE FirstName = 'TestCoachUser'];
    System.runAs(coachUser) {
      StaticResource sr = [
        SELECT body
        FROM StaticResource
        WHERE Name = 'mock_getConsolidateSOP'
      ];
      SOPGetConsolidatedModel obj = SOPGetConsolidatedModel.parse(
        sr.body.toString()
      );

      Map<String, String> partyIdToFirstNameMap = new Map<String, String>();
      partyIdToFirstNameMap.put('1000991493', 'FakeNameA');
      partyIdToFirstNameMap.put('276543221', 'FakeNameB');

      SOPGetConsolidatedViewModel viewModel = new SOPGetConsolidatedViewModel(
        obj,
        partyIdToFirstNameMap,
        Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType)
      );

      System.assertEquals(
        true,
        viewModel.sopSummaryViewModel.allPartiesConsented,
        'All parties consented should be true'
      );

      for (
        SOPExpenseViewModel expenseViewModel : viewModel.expenseSummaryViewModel.monthlyExpenses
      ) {
        System.assertNotEquals(
          'Other reason',
          expenseViewModel.reason,
          'Expense reason should either be some other values, or other - otherJustificationText'
        );
      }
    }
  }
}
