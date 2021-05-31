/**
 * @author Shermal Warnakula
 * @since  May 2021
 * @description Test class to cover tests for {@link AccessRequestTriggerHandler}
 */
@isTest
public with sharing class AccessRequestCommonActionsTest {
  /**
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
    List<User> testUserList = new List<User>();
    List<PermissionSetAssignment> psAssigments = new List<PermissionSetAssignment>();

    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole anzxRole = CommonUtil.getUserRoleByDevName('ANZx');

    // Create global approver user
    User approver = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'PAM_Global_Approver',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => anzxRole.Id
      }
    );
    testUserList.add(approver);

    // Create global approver's manager user
    User manager = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'PAM_Global_Manager',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => anzxRole.Id
      }
    );
    testUserList.add(manager);

    // Create an Engineer user
    Profile noAccessProfile = CommonUtil.getProfileByName('No Access');
    UserRole engineerRole = CommonUtil.getUserRoleByDevName('Engineer');
    User engineerUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'PAM_Engineer',
        'ProfileId' => noAccessProfile.Id,
        'UserRoleId' => engineerRole.Id
      }
    );
    testUserList.add(engineerUser);

    insert testUserList;

    // Add PAM related object permissions on test users
    PermissionSet ps = CommonUtil.getPermissionSetByName('PAM_Requestor');
    psAssigments.add(TestUtil.createPSAssignment(approver.id, ps.Id));
    psAssigments.add(TestUtil.createPSAssignment(engineerUser.id, ps.Id));
    insert psAssigments;

    // Insert custom setting record as the current user, to get around MIXED_DML_OPERATION error
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      // Insert PAM approver global settings
      List<PAM_Global_Approver__c> settings = new List<PAM_Global_Approver__c>();
      PAM_Global_Approver__c orgCS = new PAM_Global_Approver__c(
        PAM_Approver_Username__c = approver.UserName
      );
      settings.add(orgCS);
      PAM_Global_Approver__c approverCS = new PAM_Global_Approver__c(
        PAM_Approver_Username__c = manager.UserName,
        SetupOwnerId = approver.Id
      );
      settings.add(approverCS);
      insert settings;
    }

    // Insert Access Request and Privileged Access Request records as engineer user, to get around MIXED_DML_OPERATION error
    System.runAs(engineerUser) {
      // Create an access request
      Access_Request__c ar = new Access_Request__c();
      ar.Requestor__c = engineerUser.Id;
      ar.Reason__c = 'Get Admin Access for X-Ray Test';
      ar.Reference_Number__c = 'AC-001';
      ar.Access_Type__c = 'System Administrator';
      ar.When__c = 'Immediate';
      ar.Duration_hrs__c = '2';
      insert ar;

      // Create a privileged access request
      Privileged_Access_Request__c par = new Privileged_Access_Request__c();
      par.Access_Request__c = ar.Id;
      par.Previous_Profile_Id__c = stdUserProfile.Id;
      par.Start_Date_Time__c = DateTime.valueOf('2021-05-26 08:25:00');
      par.Revoke_Time__c = DateTime.valueOf('2021-05-26 10:25:00');
      insert par;
    }
  }

  /**
   * @description Common method to generate an Access_Request__c instance with default values
   * @param requesterId User Id of the Requestor user
   * @return Access_Request__c
   */
  private static Access_Request__c getAccessRequest(Id requesterId) {
    Access_Request__c accessReq = new Access_Request__c(
      Requestor__c = requesterId,
      Reason__c = 'Production deployment',
      Reference_Number__c = 'CR-987987',
      Access_Type__c = 'System Administrator',
      When__c = 'Future',
      Expected_Start__c = Datetime.now().addDays(2),
      Duration_hrs__c = '4'
    );

    return accessReq;
  }

  /**
   * @description Test happy path when an Engineer submits a PAM request
   */
  @isTest
  static void pamRequestByEngineer() {
    // GIVEN
    // an Engineer user has necessary permissions to PAM related objects
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');

    // WHEN
    // an Engineer user requests Privileged Access
    Access_Request__c pamRequest = getAccessRequest(engineerUser.Id);

    System.runAs(engineerUser) {
      Test.startTest();
      insert pamRequest;
      Test.stopTest();
    }

    // THEN
    // the global PAM approver should be set as the Approver
    Access_Request__c updatedPAM = [
      SELECT Approver__r.UserName
      FROM Access_Request__c
      WHERE Id = :pamRequest.Id
      LIMIT 1
    ];
    System.assertEquals(
      PAM_Global_Approver__c.getOrgDefaults()
        .PAM_Approver_Username__c.toLowerCase(),
      updatedPAM.Approver__r.UserName,
      'Failed to auto populate global approver for PAM requests'
    );
  }

  /**
   * @description Test the scenario where global PAM approver submits a PAM request for himself
   */
  @isTest
  static void pamRequestByApprover() {
    // GIVEN
    // the global Approver wishes to make a PAM request
    User approverUser = TestUtil.getUserByFirstName('PAM_Global_Approver');
    Access_Request__c pamRequest = getAccessRequest(approverUser.Id);

    // WHEN
    // the the Global Approver creates an Access Request record
    Test.startTest();

    System.runAs(approverUser) {
      AccessRequestCommonActions.calculateApprover(
        new List<Access_Request__c>{ pamRequest }
      );
    }

    Test.stopTest();

    // THEN
    // the global PAM approver's manager should be set as the Approver
    User managerUser = TestUtil.getUserByFirstName('PAM_Global_Manager');
    System.assertEquals(
      managerUser.Id,
      pamRequest.Approver__c,
      'Failed to correctly populate PAM approver, when the global approver raises a request'
    );
  }

  /**
   * @description Test the scenario when PAM has already been processed
   */
  @isTest
  static void pamRequestAlreadyProcessed() {
    // GIVEN
    // a particular PAM request has already been processed
    Access_Request__c pamRequest = getAccessRequest(
      Lib_FakeIdGenerator.getMockId(User.getSObjectType())
    );
    pamRequest.Status__c = 'Approved';
    pamRequest.Approver__c = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );

    // WHEN
    // calculateApprover() method is called
    Test.startTest();

    AccessRequestCommonActions.calculateApprover(
      new List<Access_Request__c>{ pamRequest }
    );

    Test.stopTest();

    // THEN
    // the PAM approver should should not be re-calculated
    User approverUser = TestUtil.getUserByFirstName('PAM_Global_Approver');
    System.assertNotEquals(
      approverUser.Id,
      pamRequest.Approver__c,
      'Approver calculation logic should not be triggered for already processed PAM requests'
    );
  }

  /**
   * @description Test the scenario when there was an issue while trying to get global approver info
   */
  @isTest
  static void errorGetApproverUserInfo() {
    // GIVEN
    // global PAM approvers were not defined in custom settings
    List<PAM_Global_Approver__c> csList = [
      SELECT id
      FROM PAM_Global_Approver__c
    ];
    delete csList;

    // and no access request currently exists
    List<Access_Request__c> accRequests = [SELECT Id FROM Access_Request__c];
    delete accRequests;

    // WHEN
    // a user tries to raise a PAM request
    Test.startTest();

    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Access_Request__c pamRequest = getAccessRequest(engineerUser.Id);

    AccessRequestCommonActions.calculateApprover(
      new List<Access_Request__c>{ pamRequest }
    );

    Test.stopTest();

    // THEN
    // the PAM request should not be saved/updated
    System.assert(
      [SELECT COUNT() FROM Access_Request__c] == 0,
      'Access Request should fail to save/update if global Approvers were not defined.'
    );
  }

  /**
   * @description Test the happy path of Privileged Access Request getting created against an approved Access Requests
   */
  @isTest
  static void successPAReqCreation() {
    // GIVEN
    // an Acess Request has been raised
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Access_Request__c pamRequest = getAccessRequest(engineerUser.Id);
    insert pamRequest;

    // WHEN
    // the Access Request gets Approved
    Test.startTest();
    pamRequest.Status__c = 'Approved';
    update pamRequest;
    Test.stopTest();

    // THEN
    // [1] a Privileged Access Request record should get created with neccessary information
    List<Privileged_Access_Request__c> paReqests = [
      SELECT Id, Previous_Profile_Id__c, Start_Date_Time__c, Revoke_Time__c
      FROM Privileged_Access_Request__c
      WHERE Access_Request__c = :pamRequest.Id
    ];
    System.assert(
      !paReqests.isEmpty(),
      'Failed to create Privileged Access Request record upon Access Request approval'
    );

    // [2] start date/time incase of 'future' should be the same as given Expected Start on Access Request
    System.assertEquals(
      paReqests[0].Start_Date_Time__c,
      pamRequest.Expected_Start__c,
      'Failed to set Start date/time to be the same as given Expected Start on Access Request for "future" requests'
    );

    // [3] access revoke time should be calculated based on start date/time and duration
    System.assertEquals(
      paReqests[0].Revoke_Time__c,
      pamRequest.Expected_Start__c.addHours(
        Integer.valueOf(pamRequest.Duration_hrs__c)
      ),
      'Failed to calculate end date/time based on start date/time and duration'
    );

    // [4] requester's previous profile Id should be saved on PAR record
    System.assert(
      !String.isEmpty(paReqests[0].Previous_Profile_Id__c),
      'Failed to set profile Id of the requesting user on PAR record'
    );
  }

  /**
   * @description Test when Access Request is not Approved
   */
  @isTest
  static void accessRequestRejected() {
    // GIVEN
    // an Acess Request has been raised
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Access_Request__c newRecordInstance = getAccessRequest(engineerUser.Id);
    newRecordInstance.Id = Lib_FakeIdGenerator.getMockId(
      Access_Request__c.getSObjectType()
    );

    // creating a mock oldMap
    Access_Request__c oldRecordInstance = getAccessRequest(engineerUser.Id);
    oldRecordInstance.Id = newRecordInstance.Id;
    oldRecordInstance.Status__c = '';
    Map<Id, SObject> oldMap = new Map<Id, SObject>{
      oldRecordInstance.Id => oldRecordInstance
    };

    // and no privileged access request currently exists
    List<Privileged_Access_Request__c> privAccRequests = [
      SELECT Id
      FROM Privileged_Access_Request__c
    ];
    delete privAccRequests;

    // WHEN
    // the Access Request gets Rejected
    Test.startTest();

    newRecordInstance.Status__c = 'Rejected';
    List<Access_Request__c> newList = new List<Access_Request__c>();
    newList.add(newRecordInstance);
    AccessRequestCommonActions.createPARequestRecords(newList, oldMap);

    Test.stopTest();

    // THEN
    // a Privileged Access Request record should NOT be created
    System.assert(
      [SELECT COUNT() FROM Privileged_Access_Request__c] == 0,
      'PAR record was incorrectly created for Rejected access request'
    );
  }

  /**
   * @description Test start date/time calculation for 'immediate'
   */
  @isTest
  static void testImmediateStart() {
    // GIVEN
    // an a request has been raised requesting 'immediate' privileged access
    String immediateOrFuture = AccessRequestCommonActions.REQUEST_IMMEDIATE;

    // WHEN
    // the start date is calculated
    Test.startTest();

    Datetime calculatedStart = AccessRequestCommonActions.calculateStartTime(
      immediateOrFuture,
      null
    );

    Test.stopTest();

    // THEN
    // calculatedStart should be set to current datetime
    System.assert(
      datetime.now() >= calculatedStart,
      'Start date/time is not the same as datetime.now().'
    );
  }

  /**
   * @description Test when there is an exception
   */
  @isTest
  static void testExceptionBehaviour() {
    // GIVEN
    // there is a chance for an exception to happen
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Access_Request__c newRecordInstance = getAccessRequest(engineerUser.Id);
    newRecordInstance.Id = Lib_FakeIdGenerator.getMockId(
      Access_Request__c.getSObjectType()
    );
    // creating a blank oldMap (just to trigger an exception)
    Map<Id, SObject> oldMap = new Map<Id, SObject>();

    // and no privileged access request currently exists
    List<Privileged_Access_Request__c> privAccRequests = [
      SELECT Id
      FROM Privileged_Access_Request__c
    ];
    delete privAccRequests;

    // WHEN
    // the Access Request gets Approved
    Test.startTest();

    newRecordInstance.Status__c = 'Approved';
    List<Access_Request__c> newList = new List<Access_Request__c>();
    newList.add(newRecordInstance);
    AccessRequestCommonActions.createPARequestRecords(newList, oldMap);

    Test.stopTest();

    // THEN
    // [1] a Privileged Access Request record should NOT be created
    System.assert(
      [SELECT COUNT() FROM Privileged_Access_Request__c] == 0,
      'PAR record was incorrectly created regardless of an Exception scenario'
    );

    // [2] a System Log should be added related to the Exception
    Application_Log__c log = [
      SELECT Id, Function_Name__c
      FROM Application_Log__c
      LIMIT 1
    ];
    System.assertEquals(
      'createPARequestRecords',
      log.Function_Name__c,
      'Failed to create an Application Log for exception scenarios in PAM approval flow'
    );
  }

  @isTest
  private static void testSetAccessGrantedTimestamp() {
    // GIVEN
    // A Privileged Access Request has been process and requestor has been granted with System Admin access
    Privileged_Access_Request__c par = getPrivilegedAccessRequest();
    AccessRequestCommonActions.UpdateTimestampRequest req = new AccessRequestCommonActions.UpdateTimestampRequest();
    req.privilegedAccReqId = par.Id;
    req.processType = 'grant';
    List<AccessRequestCommonActions.UpdateTimestampRequest> requests = new List<AccessRequestCommonActions.UpdateTimestampRequest>();
    requests.add(req);

    // WHEN
    // setTimestamp() is invoked
    Test.startTest();
    AccessRequestCommonActions.setTimestamp(requests);
    Test.stopTest();

    // THEN
    // Actual_Access_Granted_Time__c should be populated
    Privileged_Access_Request__c parResult = getPrivilegedAccessRequest();
    System.assertNotEquals(
      null,
      parResult.Actual_Access_Granted_Time__c,
      'Actual Access Granted Time is null'
    );
  }

  @isTest
  private static void testSetAccessRevokedTimestamp() {
    // GIVEN
    // A Privileged Access Request has been process and System Admin access has been revoked
    Privileged_Access_Request__c par = getPrivilegedAccessRequest();
    AccessRequestCommonActions.UpdateTimestampRequest req = new AccessRequestCommonActions.UpdateTimestampRequest();
    req.privilegedAccReqId = par.Id;
    req.processType = 'revoke';
    List<AccessRequestCommonActions.UpdateTimestampRequest> requests = new List<AccessRequestCommonActions.UpdateTimestampRequest>();
    requests.add(req);

    // WHEN
    // setTimestamp() is invoked
    Test.startTest();
    AccessRequestCommonActions.setTimestamp(requests);
    Test.stopTest();

    // THEN
    // Actual_Access_Revoked_Time__c should be populated
    Privileged_Access_Request__c parResult = getPrivilegedAccessRequest();
    System.assertNotEquals(
      null,
      parResult.Actual_Access_Revoked_Time__c,
      'Actual Access Granted Time is null'
    );
  }

  private static Privileged_Access_Request__c getPrivilegedAccessRequest() {
    return [
      SELECT Id, Actual_Access_Granted_Time__c, Actual_Access_Revoked_Time__c
      FROM Privileged_Access_Request__c
      LIMIT 1
    ];
  }
}
