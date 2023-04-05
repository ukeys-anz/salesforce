/**
 * @description Test class for {@link COBCaseStatusValidator}
 * @author Batya Aisman Sufrin
 * @since 02/2023
 */
@isTest
public with sharing class COBCaseStatusValidatorTest {
  @testSetup
  static void setup() {
    // Create test Users running as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      List<User> testUsers = createTestUsers();

      assignRelatedPSs(testUsers);

      List<CustomerOnboardingApplication__c> cobApps = createCOBApp();

      createIDOpsCases(cobApps);

      createFraudCheckCases();
    }
  }

  private static List<User> createTestUsers() {
    Profile profile = CommonUtil.getProfileByName('ANZx Standard User');

    // Create a Join Lead and FraudX Agent users with respective 'Join Lead' and 'FraudX Agent' roles
    List<User> testUsers = new List<User>();
    List<UserRole> roles = new List<UserRole>{
      CommonUtil.getUserRoleByDevName('Join_Lead'),
      CommonUtil.getUserRoleByDevName('FraudX_Agent')
    };
    for (UserRole role : roles) {
      User usr = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => role.DeveloperName + '_Test',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      testUsers.add(usr);
    }

    insert testUsers;
    return testUsers;
  }

  private static void assignRelatedPSs(List<User> testUsers) {
    // Assign related PSs
    List<String> fraudXPSs = new List<String>{
      'Case_Read_Write_Fraud_Agent',
      'Case_Read_Write_Customer_Onboarding'
    };
    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :fraudXPSs
    ];

    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      for (User usr : testUsers) {
        psaList.add(TestUtil.createPSAssignment(usr.Id, ps.Id));
      }
    }

    insert psaList;
  }

  private static List<CustomerOnboardingApplication__c> createCOBApp() {
    // Create Customer Onboarding applications with DVS results 'PASS' and 'FAIL'
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<String> dvsResults = new List<String>{ 'PASS', 'FAIL' };
    for (String dvsResult : dvsResults) {
      CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
        EquifaxDVSResult__c = dvsResult
      );
      cobApps.add(cobApp);
    }

    insert cobApps;
    return cobApps;
  }

  private static void createIDOpsCases(
    List<CustomerOnboardingApplication__c> cobApps
  ) {
    // Create ID Ops cases with COB Applications
    List<Case> idOpsCases = new List<Case>();
    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      Case idOpsCaseWithCobApp = new Case(
        Status = GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
        RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
        CustomerOnboardingApplication__c = cobApp.id
      );
      idOpsCases.add(idOpsCaseWithCobApp);
    }

    // Create ID Ops case without COB Applications
    Case idOpsCase = createCobCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    idOpsCases.add(idOpsCase);

    insert idOpsCases;
  }

  private static void createFraudCheckCases() {
    // Create Fraud Check cases
    List<Case> cobFraudCheckCases = new List<Case>();
    List<String> caseStatus = new List<String>{
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    };

    for (String status : caseStatus) {
      Case fraudCheckCase = createCobCase(
        status,
        GetHelpConstants.FRAUD_CHECK_RT_ID
      );
      cobFraudCheckCases.add(fraudCheckCase);
    }

    insert cobFraudCheckCases;
  }

  private static Case createCobCase(String status, String recordTypeId) {
    return new Case(Status = status, RecordTypeId = recordTypeId);
  }

  private static Case getCOBCase(String status, String recordtype) {
    return [
      SELECT
        Id,
        Status,
        RecordTypeId,
        ParentId,
        OwnerId,
        CustomerOnboardingApplication__c
      FROM Case
      WHERE
        Status = :status
        AND RecordTypeId = :recordtype
        AND CustomerOnboardingApplication__c = NULL
    ];
  }

  private static Case getCOBCaseWithCobApp(
    String status,
    String recordtype,
    String dvsResult
  ) {
    return [
      SELECT
        Id,
        Status,
        RecordTypeId,
        ParentId,
        CustomerOnboardingApplication__r.EquifaxDVSResult__c,
        OwnerId,
        Owner.FirstName
      FROM Case
      WHERE
        Status = :status
        AND RecordTypeId = :recordtype
        AND CustomerOnboardingApplication__r.EquifaxDVSResult__c = :dvsResult
    ];
  }

  @isTest
  private static void testGetParentCaseWithOpenChildren() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Case fraudCheckCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.ParentId = idOpsCase.Id;

    update fraudCheckCase;

    Test.startTest();
    Case parentCase = COBCaseStatusValidator.getParentCaseWithOpenChildren(
      idOpsCase.id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      parentCase,
      'There should be only one parent case'
    );

    Assert.areEqual(
      1,
      parentCase.Cases.size(),
      'There should be only one child case'
    );
  }

  @isTest
  private static void testGetParentCaseWithoutChildCase() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Test.startTest();
    Case parentCase = COBCaseStatusValidator.getParentCaseWithOpenChildren(
      idOpsCase.id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      parentCase,
      'There should be only one parent case'
    );

    Assert.isTrue(parentCase.Cases.isEmpty(), 'There should be no child cases');
  }

  @isTest
  private static void testGetParentCaseWithClosedChildCase() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Case fraudCheckCase = getCOBCase(
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.ParentId = idOpsCase.Id;

    update fraudCheckCase;

    Test.startTest();
    Case parentCase = COBCaseStatusValidator.getParentCaseWithOpenChildren(
      idOpsCase.id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      parentCase,
      'There should be only one parent case'
    );

    Assert.isTrue(parentCase.Cases.isEmpty(), 'There should be no child cases');
  }

  @isTest
  private static void testValidateStatusOnParentWithOpenChild() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    String currentStatus = idOpsCase.Status;

    Case fraudCheckCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.ParentId = idOpsCase.Id;

    update fraudCheckCase;

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      idOpsCase
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseStatusValidator.BLOCKED_STATUS_UPDATE_ERROR,
      errorMsg,
      'Error message should be: ' +
      COBCaseStatusValidator.BLOCKED_STATUS_UPDATE_ERROR
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeValidTransion() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    String currentStatus = idOpsCase.Status;
    idOpsCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    idOpsCase.OnboardingVerificationFailedReason__c = 'Selfie fail - selfie image is not clear enough to match';

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      idOpsCase
    );
    Test.stopTest();

    Assert.areEqual(
      '',
      errorMsg,
      'No error message should be generated for valid case status transion.'
    );
  }

  @isTest
  private static void testCaseStatusChangeInvalidTransitionIDOps() {
    String errorTemplate = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'{2}.';

    Map<String, List<String>> invalidTransitionMap = COBCaseStatusValidator.ID_OPS_STATUSES_INVALID_TRANSITION_MAP;

    for (String sourceStatus : invalidTransitionMap.keySet()) {
      Case idOpsCase = createCobCase(
        sourceStatus,
        GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
      );

      for (String destinationStatus : invalidTransitionMap.get(sourceStatus)) {
        idOpsCase.Status = destinationStatus;

        String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
          sourceStatus,
          idOpsCase
        );

        String expectedErrorMessage = String.format(
          errorTemplate,
          new List<String>{ sourceStatus, destinationStatus, '' }
        );
        Assert.areEqual(
          expectedErrorMessage,
          errorMsg,
          'Error message should be: ' + expectedErrorMessage
        );
      }
    }
  }

  @isTest
  private static void testCaseStatusChangeInvalidTransitionFraudCheck() {
    String errorTemplate = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'{2}.';

    Map<String, List<String>> invalidTransitionMap = COBCaseStatusValidator.FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP;

    for (String sourceStatus : invalidTransitionMap.keySet()) {
      Case fraudCheckCase = createCobCase(
        sourceStatus,
        GetHelpConstants.FRAUD_CHECK_RT_ID
      );

      for (String destinationStatus : invalidTransitionMap.get(sourceStatus)) {
        fraudCheckCase.Status = destinationStatus;

        String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
          sourceStatus,
          fraudCheckCase
        );

        String expectedErrorMessage = String.format(
          errorTemplate,
          new List<String>{ sourceStatus, destinationStatus, '' }
        );
        Assert.areEqual(
          expectedErrorMessage,
          errorMsg,
          'Error message should be: ' + expectedErrorMessage
        );
      }
    }
  }

  @isTest
  private static void testCaseStatusChangeDVSPassFraudXAgent() {
    //user with fraudX role
    User fraudXUsr = TestUtil.getUserByFirstName('FraudX_Agent_Test');

    //cob with DVS = PASS
    Case idOpsCase = getCOBCaseWithCobApp(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      'PASS'
    );
    idOpsCase.OwnerId = fraudXUsr.Id;
    update idOpsCase;

    String currentStatus = idOpsCase.Status;
    idOpsCase.Status = GetHelpConstants.COB_EQUIFAX_PASSED_STATUS;

    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c();
    cobApp.Id = idOpsCase.CustomerOnboardingApplication__c;
    cobApp.OwnerId = fraudXUsr.Id;

    String errorMsg = '';
    System.runAs(fraudXUsr) {
      update cobApp;

      Test.startTest();
      errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        currentStatus,
        idOpsCase
      );
      Test.stopTest();
    }

    Assert.areEqual(
      '',
      errorMsg,
      'FraudX Agent should be able to bypass Equifax when DVS PASS.'
    );
  }

  @isTest
  private static void testCaseStatusChangeDVSFailedJoinLead() {
    //user with Join Lead role
    User joinLeadUsr = TestUtil.getUserByFirstName('Join_Lead_Test');

    //cob with DVS = FAIL
    Case idOpsCase = getCOBCaseWithCobApp(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      'FAIL'
    );

    idOpsCase.OwnerId = joinLeadUsr.Id;
    update idOpsCase;

    String currentStatus = idOpsCase.Status;
    idOpsCase.Status = GetHelpConstants.COB_EQUIFAX_PASSED_STATUS;

    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c();
    cobApp.Id = idOpsCase.CustomerOnboardingApplication__c;
    cobApp.OwnerId = joinLeadUsr.Id;

    String errorMsg = '';
    System.runAs(joinLeadUsr) {
      update cobApp;

      Test.startTest();
      errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        currentStatus,
        idOpsCase
      );
      Test.stopTest();
    }

    Assert.areEqual(
      '',
      errorMsg,
      'Join Lead should be able to bypass Equifax when DVS FAIL.'
    );
  }

  @isTest
  private static void testCaseStatusChangeDVSFailedFraudXAgent() {
    String errorTemplate = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'{2}.';

    //user with fraudX role
    User fraudXUsr = TestUtil.getUserByFirstName('FraudX_Agent_Test');

    String sourceStatus = GetHelpConstants.COB_EQUIFAX_FAILED_STATUS;
    String destinationStatus = GetHelpConstants.COB_EQUIFAX_PASSED_STATUS;
    //cob with DVS = FAIL
    Case idOpsCase = getCOBCaseWithCobApp(
      sourceStatus,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      'FAIL'
    );

    idOpsCase.OwnerId = fraudXUsr.Id;
    update idOpsCase;

    idOpsCase.Status = destinationStatus;

    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c();
    cobApp.Id = idOpsCase.CustomerOnboardingApplication__c;
    cobApp.OwnerId = fraudXUsr.Id;

    String errorMsg = '';
    System.runAs(fraudXUsr) {
      update cobApp;

      Test.startTest();
      errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        idOpsCase
      );
      Test.stopTest();
    }

    String expectedErrorMessage = String.format(
      errorTemplate,
      new List<String>{
        sourceStatus,
        destinationStatus,
        COBCaseStatusValidator.FAILED_DVS_MESSAGE
      }
    );
    Assert.areEqual(
      expectedErrorMessage,
      errorMsg,
      'Error message should be: ' + expectedErrorMessage
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeClosedIDOps() {
    List<String> closedStatuses = COBCaseStatusValidator.ID_OPS_CLOSED_STATUSES;

    for (String sourceStatus : closedStatuses) {
      Case idOpsCase = createCobCase(
        sourceStatus,
        GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
      );
      idOpsCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;

      String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        idOpsCase
      );

      Assert.areEqual(
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR,
        errorMsg,
        'Error message should be: ' +
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR
      );
    }
  }

  @isTest
  private static void testValidateCaseStatusChangeClosedFraudCheck() {
    List<String> closedStatuses = COBCaseStatusValidator.FRAUD_CHECK_CLOSED_STATUSES;

    for (String sourceStatus : closedStatuses) {
      Case fraudCheckCase = createCobCase(
        sourceStatus,
        GetHelpConstants.FRAUD_CHECK_RT_ID
      );
      fraudCheckCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;

      String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        fraudCheckCase
      );

      Assert.areEqual(
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR,
        errorMsg,
        'Error message should be: ' +
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR
      );
    }
  }
}
