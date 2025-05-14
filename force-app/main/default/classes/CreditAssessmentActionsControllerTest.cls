/**
 * @author Peter Charalambous
 * @since June 2023
 * @description Test class for CreditAssessmentActionsController
 */
@isTest
public with sharing class CreditAssessmentActionsControllerTest {
  private static final String TECH_ASSIST_ERROR = 'An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String REASSESSMENT_CALLOUT_ERROR = 'Failed to complete reassessment.';
  private static final String REASSESS_REQUIRED_ERROR = 'The loan application has been updated and you must resubmit this credit referral case for reassessment.';
  private static final String ASSESSMENT_ERROR = 'This credit referral case is currently being assessed. You can\'t finalise the referral case until this has been completed.';
  private static final String FINALISE_CALLOUT_ERROR = 'Failed to complete finalisation.';
  private static final String FRAUD_RELATED_ERROR = 'There’s a fraud case related to this credit referral case still open. You can’t finalise this case until the fraud case is closed.';

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider creditRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    creditRepoMock = Lib_MockProvider.forType(
      CreditAsssessmentRepository.class
    );
  }
  static Faker faker = new Faker('AU');
  static Account accnt = new Account(
    OCV_ID__c = faker.randomString(10),
    Id = Lib_FakeIdGenerator.getMockId(Account.getSObjectType())
  );

  static ResidentialLoanApplication loanApp = new ResidentialLoanApplication(
    AccountId = accnt.Id,
    Id = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.getSObjectType()
    ),
    Status = 'STATE_DECLINED'
  );

  static Case creditRefCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
    RecordTypeID = GetHelpConstants.CREDIT_REFERRAL_RT_ID,
    Subject = 'Test Credit Referral',
    Status = 'Open',
    AccountId = accnt.Id,
    Credit_Id__c = '000-000-000-001',
    Assessment_Id__c = '123456789'
  );
  /**
   * @description Setup data for test classes
   */
  @testSetup
  public static void setup() {
    Account acc = TestDataFactory.createAccount(true);
    ResidentialLoanApplication[] newRLA = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i)
      );
      rla.Credit_ID__c = '000-000-000-00' + String.valueOf(i);
      rla.AccountId = acc.Id;

      newRLA.add(rla);
    }
    insert newRLA;

    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.CREDIT_REFERRAL_RT_ID,
          Credit_Id__c = '000-000-000-00' + String.valueOf(i),
          AccountId = acc.Id,
          Status = 'Open'
        )
      );
    }
    insert newCases;

    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole bohRole = CommonUtil.getUserRoleByDevName('BOH_Coach');
    // Create boh coach user
    System.runAs(TestDataFactory.thisUser) {
      User bohUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'TestBOHCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => bohRole.Id
        }
      );
      insert bohUser;
      //Assign Permission set group as coach
      PermissionSetGroup psgCoach = [
        SELECT Id
        FROM PermissionSetGroup
        WHERE DeveloperName = 'BOH_Coach'
        LIMIT 1
      ];
      Test.calculatePermissionSetGroup(new List<String>{ psgCoach.Id });
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = bohUser.Id,
        PermissionSetGroupId = psgCoach.Id
      );
      insert psa;
    }
  }

  @isTest
  static void testSuccessReassess() {
    registerMocks();
    creditRepoMock.mock('getCaseRecord', creditRefCase);
    creditRepoMock.mock('getResidentialLoanApplicationRecord', loanApp);
    User bohUser = [SELECT Id FROM User WHERE FirstName = 'TestBOHCoachUser'];

    System.runAs(bohUser) {
      Test.startTest();
      Boolean resp = CreditAssessmentActionsController.reassess(
        creditRefCase.Id
      );

      Test.stopTest();
      Assert.isTrue(resp, 'Reassessment should be true');
    }

  }

  @isTest
  static void testSuccessFinalise() {
    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    c.Assessment_Outcome__c = 'Approved';
    update c;

    Test.startTest();
    Boolean resp = CreditAssessmentActionsController.finalise(c.Id);
    c = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
    Test.stopTest();
    Assert.isTrue(resp, 'Finalise should be true');
    Assert.areEqual(
      'Closed - Approved',
      c.Status,
      'Status should be Closed - Approved'
    );
  }

  @isTest
  static void testReassesRequiredForFinalise() {
    ResidentialLoanApplication rla = [
      SELECT Id
      FROM ResidentialLoanApplication
      LIMIT 1
    ];
    rla.Credit_Reassess_Required__c = true;
    update rla;

    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    Test.startTest();
    try {
      CreditAssessmentActionsController.finalise(c.Id);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(REASSESS_REQUIRED_ERROR),
        'Exception message should be thrown to reassess'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testFinaliseInProgressOutcome() {
    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    c.Assessment_Outcome__c = 'Processing';
    update c;

    Test.startTest();
    try {
      CreditAssessmentActionsController.finalise(c.Id);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(ASSESSMENT_ERROR),
        'Exception message should be thrown for invalid outcome'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testRelatedFraudCaseStopFinalise() {
    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c, AccountId
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];
    c.Assessment_Outcome__c = 'Approved';
    update c;
    Case fraudCase = new Case(
      ParentId = c.Id,
      AccountId = c.AccountId,
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      Type = 'Fraud',
      Sub_Type__c = 'Home loan document verification',
      Status = 'Open',
      CaseNumber__c = '334343'
    );
    insert fraudCase;

    Test.startTest();
    try {
      CreditAssessmentActionsController.finalise(c.Id);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(FRAUD_RELATED_ERROR),
        'Exception message should be thrown because of related open fraud case'
      );
    }
    Test.stopTest();
  }
}
