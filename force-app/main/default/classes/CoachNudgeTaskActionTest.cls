/**
 * @author Kopal Goswami
 * @since 07/2024
 * @description CoachNudgeTaskActionTest is the test class for CoachNudgeTaskAction Class functionality.
 */
@isTest
public with sharing class CoachNudgeTaskActionTest {
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );

  private static final Id COACH_NUDGE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Coach_Nudge')
    .getRecordTypeId();

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider coachNudgeRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    coachNudgeRepoMock = Lib_MockProvider.forType(CoachNudgeRepository.class)
      .mock('queryTaskWithRLA', createMockTaskRelatedToRla());
  }

  @TestSetup
  static void setup() {
    Map<String, User> userMap = new Map<String, User>();
    /*----------Create users for tests----------*/

    Profile integrationProfile = CommonUtil.getProfileByName(
      'Integration User'
    );
    UserRole anzxRole = CommonUtil.getUserRoleByDevName('ANZx');
    // Create an Integration User
    User integrationUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'TestUserCoachNudgeTaskAction',
        'ProfileId' => integrationProfile.Id,
        'UserRoleId' => anzxRole.Id
      }
    );
    userMap.put('integrationUser', integrationUser);

    insert userMap.values();

    /*----------Assign permission sets to users----------*/

    // Integration User permission sets
    List<String> integrationPsets = new List<String>{
      'View_And_Edit_Tasks',
      'BoH_Read_Write',
      'Coach_Nudge_Integration',
      'Read_Only_Admin'
    };

    List<PermissionSet> integrationPsList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :integrationPsets
    ];

    List<PermissionSetAssignment> integrationPsaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : integrationPsList) {
      integrationPsaList.add(
        TestUtil.createPSAssignment(userMap.get('integrationUser').Id, ps.Id)
      );
    }
    insert integrationPsaList;
  }

  @isTest
  private static void testprocessResidentialLoanApplicationRecords() {
    registerMocks();

    User integrationUser = TestUtil.getUserByFirstName(
      'TestUserCoachNudgeTaskAction'
    );

    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };
    List<Task> taskRecordBeforeUpdate = createMockTaskRelatedToRla();
    System.assertEquals(
      'Not Started',
      taskRecordBeforeUpdate[0].Status,
      'The task record status should be created with "Not Started" status'
    );

    Test.startTest();
    System.runAs(integrationUser) {
      CoachNudgeTaskAction.processResidentialLoanApplicationRecords(
        newRlaRecords,
        oldRlaRecords
      );
    }
    Test.stopTest();

    List<Task> taskRecordAfterUpdate = (List<Task>) dmlRepoMock.getHistory(
        'updateRecords'
      )
      .getParam('records');

    System.assertEquals(
      'Expired',
      taskRecordAfterUpdate[0].Status,
      'The task record status should update to Expired'
    );
  }

  @isTest
  private static void testfilterRlaAndReturnCancelledStatusRecordsPositive() {
    Set<Id> rlaRecordIds = new Set<Id>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecordIds = CoachNudgeTaskAction.filterRlaAndReturnCancelledStatusRecords(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    System.assertEquals(
      true,
      !rlaRecordIds.isEmpty(),
      'Residential Loan Application records should be returned'
    );
  }

  @isTest
  private static void testfilterRlaAndReturnCancelledStatusRecordsNegative() {
    Set<Id> rlaRecordIds = new Set<Id>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_UNSPECIFIED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecordIds = CoachNudgeTaskAction.filterRlaAndReturnCancelledStatusRecords(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    System.assertEquals(
      true,
      rlaRecordIds.isEmpty(),
      'Residential Loan Application records should not be returned'
    );
  }

  @isTest
  private static void testprepareTaskWithFieldsUpdatePositive() {
    List<Task> masterTaskList = createMockTaskRelatedToRla();
    List<Task> taskRecordsToBeUpdated = new List<Task>();
    System.assertEquals(
      'Not Started',
      masterTaskList[0].Status,
      'The task record status should be Not Started'
    );

    Test.startTest();
    taskRecordsToBeUpdated = CoachNudgeTaskAction.prepareTaskWithFieldsUpdate(
      masterTaskList
    );

    Test.stopTest();

    System.assertEquals(
      'Expired',
      taskRecordsToBeUpdated[0].Status,
      'The task record status should have status as Expired'
    );
  }

  @isTest
  private static void testprepareTaskWithFieldsUpdateNegative() {
    List<Task> masterTaskList = new List<Task>();
    List<Task> taskRecordsToBeUpdated = CoachNudgeTaskAction.prepareTaskWithFieldsUpdate(
      masterTaskList
    );
    System.assertEquals(
      true,
      taskRecordsToBeUpdated.isEmpty(),
      'Task records should not be returned'
    );
  }

  private static List<ResidentialLoanApplication> createMockRlaRecord(
    String status
  ) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication();
    rlaRecord.Id = FAKER_RLA_ID;
    rlaRecord.Status = status;

    rlaRecordsList.add(rlaRecord);
    return rlaRecordsList;
  }

  private static List<Task> createMockTaskRelatedToRla() {
    List<Task> strTasklist = new List<Task>();

    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      COACH_NUDGE_RT_ID,
      null,
      FAKER_RLA_ID,
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    strTasklist.add(coachNudgeTask);
    return strTasklist;
  }
}
