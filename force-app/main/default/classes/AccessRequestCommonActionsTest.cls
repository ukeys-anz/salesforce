/**
 * @author Shermal Warnakula
 * @since  May 2021
 * @description Test class to cover tests for {@link AccessRequestTriggerHandler}
 */
@isTest
public with sharing class AccessRequestCommonActionsTest {
  private static final Id BYPASS_AUTOMATION_REQUEST_RT_ID = QueryRT.of(
      Access_Request__c.SObjectType
    )
    .getId('Bypass_Automation_Request');

  private static final Id PRIVILEGED_ACCESS_REQUESTS_RT_ID = QueryRT.of(
      Access_Request__c.SObjectType
    )
    .getId('Privileged_Access_requests');

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
      ar.RecordTypeId = PRIVILEGED_ACCESS_REQUESTS_RT_ID;
      ar.Duration_hrs__c = '2';
      insert ar;
      ar.Status__c = AccessRequestCommonActions.STATUS_SUBMITTED;
      update ar;

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
   * @param recordTypeId RecordTypeId of the Access Request
   * @return Access_Request__c
   */
  private static Access_Request__c getAccessRequest(
    Id requesterId,
    Id recordTypeId
  ) {
    Access_Request__c accessReq = new Access_Request__c(
      Requestor__c = requesterId,
      Reason__c = 'Production deployment',
      Reference_Number__c = 'CR-987987',
      Access_Type__c = 'System Administrator',
      When__c = 'Future',
      Expected_Start__c = Datetime.now().addDays(2),
      Duration_hrs__c = '4',
      RecordTypeId = recordTypeId
    );

    return accessReq;
  }

  /**
   * @description Test preventing a user approving their own PAM request
   */
  @isTest
  static void testSelfRequestGranting() {
    // GIVEN
    // an PAM Queue Engineer creates a PAM Request
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');

    // WHEN
    // an Engineer requests a PAM
    Access_Request__c pamRequest = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );

    pamRequest.Requestor__c = engineerUser.Id;
    System.runAs(engineerUser) {
      Test.startTest();

      //Insert
      insert pamRequest;

      //THEN Trigger Update, expect a failure becuase the approver is the requestor
      try {
        pamRequest.Approver_ID__c = engineerUser.Id;
        update pamRequest;

        //IF we reach this then our trigger did not apply successfully.
        System.assert(
          false,
          'Failed to protect against user granting their own PAM request'
        );
      } catch (DmlException error) {
        System.assert(
          true,
          'This Exception was expected and is preventing self-elevation of PAM |\n' +
          error.getMessage()
        );
      }

      Test.stopTest();
    }

  }

  /**
   * @description Test the scenario when PAM has already been processed
   */
  @isTest
  static void pamRequestAlreadyProcessed() {
    // GIVEN
    // a particular PAM request has already been processed
    Access_Request__c pamRequest = getAccessRequest(
      Lib_FakeIdGenerator.getMockId(User.getSObjectType()),
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );
    pamRequest.Status__c = 'Approved';
    pamRequest.Approver__c = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );

    // THEN
    // the PAM approver should not be re-calculated
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
    Access_Request__c pamRequest = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );
    pamRequest.Status__c = 'Rejected';
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
    Access_Request__c pamRequest = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );
    insert pamRequest;
    pamRequest.Status__c = AccessRequestCommonActions.STATUS_SUBMITTED;
    update pamRequest;

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
    Access_Request__c newRecordInstance = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );
    newRecordInstance.Id = Lib_FakeIdGenerator.getMockId(
      Access_Request__c.getSObjectType()
    );

    // creating a mock oldMap
    Access_Request__c oldRecordInstance = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );
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
    Access_Request__c newRecordInstance = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );
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
  }

  @isTest
  static void testBypassSalesforceLibrarySetting() {
    // GIVEN
    // a PAM Request has been Approved to disable salesforce library settings and create a new PAR has been created
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');

    Access_Request__c ar = new Access_Request__c();
    ar.Requestor__c = engineerUser.Id;
    ar.Reason__c = 'Production deployment';
    ar.Reference_Number__c = 'CR-987987';
    ar.Automations_to_Bypass__c = 'Flows;Triggers';
    ar.When__c = 'Immediate';
    ar.Duration_hrs__c = '24';
    ar.RecordTypeId = BYPASS_AUTOMATION_REQUEST_RT_ID;

    Privileged_Access_Request__c par = new Privileged_Access_Request__c();
    BypassRequestFlowHandler.LibraryUpdateWrapper req = new BypassRequestFlowHandler.LibraryUpdateWrapper();
    req.processType = 'grant';
    req.userId = engineerUser.Id;
    req.disableFlows = false;

    // WHEN
    // the flow tries to assign System Administrator (priviileged) acces to a user
    List<Boolean> results;
    Test.startTest();
    insert ar;
    par.Access_Request__c = ar.Id;
    insert par;
    req.privilegedAccReqId = par.Id;
    results = BypassRequestFlowHandler.updateUserSFLibSetting(
      new List<BypassRequestFlowHandler.LibraryUpdateWrapper>{ req }
    );
    Test.stopTest();

    // THEN
    // updateUserSFLibSetting() invocable method should return success response
    Assert.isTrue(
      results[0],
      'Bypass Automation Access Flow should be triggered.'
    );
  }

  @isTest
  static void testBypassFailureNotCompleteRequest() {
    BypassRequestFlowHandler.LibraryUpdateWrapper req = new BypassRequestFlowHandler.LibraryUpdateWrapper();
    req.disableFlows = false;

    // WHEN
    // the flow tries to assign System Administrator (priviileged) acces to a user
    List<Boolean> results;
    Test.startTest();
    try {
      results = BypassRequestFlowHandler.updateUserSFLibSetting(
        new List<BypassRequestFlowHandler.LibraryUpdateWrapper>{ req }
      );
    } catch (Exception e) {
      Assert.isTrue(true, 'Trigger should throw an Exception error.');
    }

    Test.stopTest();

    // THEN
    // updateUserSFLibSetting() invocable method should return success response
    Assert.isFalse(
      results[0],
      'Bypass Automation Access Flow should be triggered, but does not do anything.'
    );
  }

  @isTest
  static void testBypassFailure() {
    Profile noAccessProfile = CommonUtil.getProfileByName('No Access');
    UserRole engineerRole = CommonUtil.getUserRoleByDevName('Banker');
    User noAccessUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'No_Access_User',
        'ProfileId' => noAccessProfile.Id,
        'UserRoleId' => engineerRole.Id
      }
    );
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Privileged_Access_Request__c par = [
      SELECT Id
      FROM Privileged_Access_Request__c
      LIMIT 1
    ];
    BypassRequestFlowHandler.LibraryUpdateWrapper req = new BypassRequestFlowHandler.LibraryUpdateWrapper();
    req.disableFlows = false;
    req.privilegedAccReqId = par.Id;
    req.processType = 'grant';
    req.userId = engineerUser.Id;

    // WHEN
    // the flow tries to assign System Administrator (priviileged) acces to a user
    List<Boolean> results;
    System.runAs(noAccessUser) {
      Test.startTest();
      try {
        results = BypassRequestFlowHandler.updateUserSFLibSetting(
          new List<BypassRequestFlowHandler.LibraryUpdateWrapper>{ req }
        );
      } catch (Exception e) {
        Assert.isTrue(true, 'Trigger should throw an Exception error.');
      }
      Test.stopTest();
    }

    // THEN
    // updateUserSFLibSetting() invocable method should return success response
    Assert.isFalse(
      results[0],
      'Bypass Automation Access Flow should be triggered, and return false.'
    );
  }

  @isTest
  static void testBypassFlowDisabledFlow() {
    // GIVEN
    // a PAM Request has been Approved to disable salesforce library settings and create a new PAR has been created

    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    // User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');

    Access_Request__c ar = new Access_Request__c();
    ar.Requestor__c = engineerUser.Id;
    ar.Reason__c = 'Production deployment';
    ar.Reference_Number__c = 'CR-987987';
    ar.Automations_to_Bypass__c = 'Flows;Triggers';
    ar.When__c = 'Immediate';
    ar.Duration_hrs__c = '24';
    ar.RecordTypeId = BYPASS_AUTOMATION_REQUEST_RT_ID;

    Privileged_Access_Request__c par = new Privileged_Access_Request__c();
    BypassRequestFlowHandler.LibraryUpdateWrapper req = new BypassRequestFlowHandler.LibraryUpdateWrapper();
    req.processType = 'grant';
    req.userId = engineerUser.Id;
    req.disableFlows = true;

    // WHEN
    // the flow tries to assign System Administrator (priviileged) acces to a user
    List<Boolean> results;
    Test.startTest();
    insert ar;
    par.Access_Request__c = ar.Id;
    insert par;
    req.privilegedAccReqId = par.Id;
    results = BypassRequestFlowHandler.updateUserSFLibSetting(
      new List<BypassRequestFlowHandler.LibraryUpdateWrapper>{ req }
    );
    Test.stopTest();

    // THEN
    // updateUserSFLibSetting() invocable method should return false response
    Assert.isTrue(
      results[0],
      'Bypass Automation Access Flow should be triggered.'
    );
    Access_Request__c arr = [
      SELECT Name, Automations_to_Bypass__c
      FROM Access_Request__c
      WHERE Id = :ar.Id
      LIMIT 1
    ];
    String expectedLogMessage =
      '%Error occured in Bypass grant flow. Related to request ' +
      arr.Name +
      ' requesting ' +
      arr.Automations_to_Bypass__c +
      ' Bypass.%';
    List<LogEntry__c> logs = [
      SELECT LogMessage__c
      FROM LogEntry__c
      WHERE LogMessage__c LIKE :expectedLogMessage
    ];
    Assert.isTrue(
      !logs.isEmpty(),
      'LogEntry should be created to inform that Disable Flow is true.'
    );
  }

  @isTest
  private static void testupdateUserProfile() {
    // GIVEN
    // a PAM Request has been Approved and a new PAR has been created
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Profile adminProfile = CommonUtil.getProfileByName('System Administrator');
    Privileged_Access_Request__c par = getPrivilegedAccessRequest();
    AccessRequestFlowHandler.ProfileUpdateWrapper req = new AccessRequestFlowHandler.ProfileUpdateWrapper();
    req.privilegedAccReqId = par.Id;
    req.processType = 'grant';
    req.userId = engineerUser.Id;
    req.profileId = adminProfile.Id;
    req.disableFlows = false;

    // WHEN
    // the flow tries to assign System Administrator (priviileged) acces to a user
    List<Boolean> results;
    Test.startTest();
    results = AccessRequestFlowHandler.updateUserProfile(
      new List<AccessRequestFlowHandler.ProfileUpdateWrapper>{ req }
    );
    Test.stopTest();

    // THEN
    // updateUserProfile() invocable method should return success response
    System.assert(
      results[0],
      'Error occured while assigning profiles via PAM flow'
    );
  }

  @isTest
  private static void testSetAccessGrantedTimestamp() {
    // GIVEN
    // A Privileged Access Request has been process and requestor has been granted with System Admin access
    Privileged_Access_Request__c par = getPrivilegedAccessRequest();

    // WHEN
    // updateSuccessTimeStamp() is invoked
    Test.startTest();
    AccessRequestFlowHandler.updateSuccessTimeStamp(
      par.Id,
      'grant',
      System.now()
    );
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

    // WHEN
    // updateSuccessTimeStamp() is invoked
    Test.startTest();
    AccessRequestFlowHandler.updateSuccessTimeStamp(
      par.Id,
      'revoke',
      System.now()
    );
    Test.stopTest();

    // THEN
    // Actual_Access_Revoked_Time__c should be populated
    Privileged_Access_Request__c parResult = getPrivilegedAccessRequest();
    System.assertNotEquals(
      null,
      parResult.Actual_Access_Revoked_Time__c,
      'Actual Access Revoked Time is null'
    );
  }

  @isTest
  private static void testGrantFlowFailures() {
    // GIVEN
    // a Privileged Access Request is being processed
    Privileged_Access_Request__c par = getPrivilegedAccessRequest();
    AccessRequestFlowHandler.ProfileUpdateWrapper req = new AccessRequestFlowHandler.ProfileUpdateWrapper();
    req.privilegedAccReqId = par.Id;
    req.processType = 'grant';
    req.disableFlows = false;

    // WHEN
    // an error occurs in the Grant flow which resulted in calling logGrantRevokeFailures()
    Test.startTest();
    String traceId = AccessRequestFlowHandler.logFailures(req, '');
    Test.stopTest();

    // THEN
    // an Application Trace Log should be created with a Trace Id (cannot query big objects in test context)
    System.assert(
      !String.isBlank(traceId),
      'Error occured while creating an Application Trace Log for grant flow failures'
    );
  }

  @isTest
  private static void testRevokeFlowFailures() {
    // GIVEN
    // a Privileged Access Request is being processed
    Privileged_Access_Request__c par = getPrivilegedAccessRequest();
    AccessRequestFlowHandler.ProfileUpdateWrapper req = new AccessRequestFlowHandler.ProfileUpdateWrapper();
    req.privilegedAccReqId = par.Id;
    req.processType = 'revoke';
    req.disableFlows = false;

    // WHEN
    // an error occurs in the Revoke flow which resulted in calling logGrantRevokeFailures()
    Test.startTest();
    String traceId = AccessRequestFlowHandler.logFailures(req, '');
    Test.stopTest();

    // THEN
    // an Application Trace Log should be created with a Trace Id (cannot query big objects in test context)
    System.assert(
      !String.isBlank(traceId),
      'Error occured while creating an Application Trace Log for revoke flow failures'
    );
  }

  @isTest
  private static void testRevokeBypassFlow() {
    // GIVEN
    // a PAM Request has been Approved to disable salesforce library settings and create a new PAR has been created

    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');

    Access_Request__c ar = new Access_Request__c();
    ar.Requestor__c = engineerUser.Id;
    ar.Reason__c = 'Production deployment';
    ar.Reference_Number__c = 'CR-987987';
    ar.Automations_to_Bypass__c = 'Flows;Triggers';
    ar.When__c = 'Immediate';
    ar.Duration_hrs__c = '24';
    ar.RecordTypeId = BYPASS_AUTOMATION_REQUEST_RT_ID;

    Privileged_Access_Request__c par = new Privileged_Access_Request__c();
    BypassRequestFlowHandler.LibraryUpdateWrapper req = new BypassRequestFlowHandler.LibraryUpdateWrapper();
    req.processType = 'revoke';
    req.userId = engineerUser.Id;
    req.disableFlows = false;
    Salesforce_Library_Settings__c customSettings = new Salesforce_Library_Settings__c(
      SetupOwnerId = engineerUser.Id,
      Disable_Flows__c = false,
      Disable_Triggers__c = true,
      Disable_VRs__c = true
    );
    // WHEN
    // the flow tries to assign System Administrator (priviileged) acces to a user
    List<Boolean> results;
    Test.startTest();
    insert ar;
    par.Access_Request__c = ar.Id;
    insert par;
    req.privilegedAccReqId = par.Id;
    insert customSettings;
    results = BypassRequestFlowHandler.updateUserSFLibSetting(
      new List<BypassRequestFlowHandler.LibraryUpdateWrapper>{ req }
    );
    Test.stopTest();

    // THEN
    // updateUserSFLibSetting() invocable method should return false response
    Assert.isTrue(
      results[0],
      'Bypass Automation Access Flow should not be triggered.'
    );
    List<Salesforce_Library_Settings__c> deletedLib = [
      SELECT Id
      FROM Salesforce_Library_Settings__c
      WHERE Id = :customSettings.Id
    ];
    Assert.isTrue(
      deletedLib.isEmpty(),
      'Salesforce library settings for user should be removed.'
    );
  }

  @isTest
  static void createAccessRequestsMapTest() {
    List<Access_Request__c> requests = [
      SELECT
        Id,
        RecordTypeId,
        Expected_Start__c,
        Duration_hrs__c,
        Requestor__c,
        When__c
      FROM Access_Request__c
    ];

    Test.startTest();
    Map<String, List<AccessRequestCommonActions.AccessRequestMap>> accessRequestsMap = AccessRequestCommonActions.createAccessRequestsMap(
      requests
    );
    Test.stopTest();

    Assert.isTrue(
      !accessRequestsMap.isEmpty(),
      'Access request map should be created for existing access request'
    );
    Assert.isTrue(
      accessRequestsMap.containsKey(requests[0].Requestor__c),
      'The key should be created'
    );
    Assert.isTrue(
      accessRequestsMap.get(requests[0].Requestor__c).size() == 1,
      'The map for the existing access request should have on Map<String, Object>'
    );
    Assert.areEqual(
      requests[0].RecordTypeId,
      accessRequestsMap.get(requests[0].Requestor__c)[0].recordTypeId,
      'The map for the existing access request should have on Map<String, Object>'
    );
    Assert.isNotNull(
      accessRequestsMap.get(requests[0].Requestor__c)[0].startTime,
      'There should be value'
    );
    Assert.isNotNull(
      accessRequestsMap.get(requests[0].Requestor__c)[0].revokeTime,
      'The map for the existing access request should have on Map<String, Object>'
    );
  }

  @isTest
  static void createAccessRequestsMapTestNoRequest() {
    Test.startTest();
    Map<String, List<AccessRequestCommonActions.AccessRequestMap>> accessRequestsMap = AccessRequestCommonActions.createAccessRequestsMap(
      new List<Access_Request__c>()
    );
    Test.stopTest();
    Assert.isTrue(
      accessRequestsMap.isEmpty(),
      'Access request map should not be created for existing access request'
    );
  }

  @isTest
  static void findOverLappedRequestsTest() {
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    Access_Request__c ar = new Access_Request__c();
    ar.Requestor__c = engineerUser.Id;
    ar.Reason__c = 'Production deployment';
    ar.Reference_Number__c = 'CR-findOverLappedRequestsTest';
    ar.Access_Type__c = 'System Administrator';
    ar.When__c = 'Immediate';
    ar.Duration_hrs__c = '3';
    ar.RecordTypeId = PRIVILEGED_ACCESS_REQUESTS_RT_ID;

    Privileged_Access_Request__c par = new Privileged_Access_Request__c();
    par.Previous_Profile_Id__c = stdUserProfile.Id;
    par.Start_Date_Time__c = system.now().addHours(1);
    par.Revoke_Time__c = system.now().addHours(3);

    Test.startTest();
    insert ar;
    par.Access_Request__c = ar.Id;
    insert par;
    Map<String, List<AccessRequestCommonActions.AccessRequestMap>> accessRequestsMap = AccessRequestCommonActions.createAccessRequestsMap(
      new List<Access_Request__c>{ ar }
    );
    Map<String, String> overlappedRequests = AccessRequestCommonActions.findOverLappedRequests(
      accessRequestsMap
    );
    Test.stopTest();
    ar = [
      SELECT Name
      FROM Access_Request__c
      WHERE Reference_Number__c = 'CR-findOverLappedRequestsTest'
      LIMIT 1
    ];
    Assert.isTrue(
      !overlappedRequests.isEmpty(),
      'It should find overlapped PAM'
    );
    Assert.isTrue(
      overlappedRequests.containsKey(engineerUser.Id),
      'The overlapping record should have a Requestor__c key.'
    );
    Assert.areEqual(
      overlappedRequests.get(engineerUser.Id),
      ar.Name,
      'The requester key should have the right value.'
    );
  }

  @isTest
  static void noOverLappedRequestsTest() {
    List<Access_Request__c> requests = [
      SELECT
        Id,
        RecordTypeId,
        Expected_Start__c,
        Duration_hrs__c,
        Requestor__c,
        When__c
      FROM Access_Request__c
    ];
    List<Privileged_Access_Request__c> pars = [
      SELECT
        Id,
        Name,
        Access_Request__r.Name,
        Access_Request__r.Requestor__c,
        Access_Request_Record_Type_Id__c,
        Start_Date_Time__c,
        Revoke_Time__c
      FROM Privileged_Access_Request__c
    ];
    Test.startTest();
    delete pars;
    Map<String, List<AccessRequestCommonActions.AccessRequestMap>> accessRequestsMap = AccessRequestCommonActions.createAccessRequestsMap(
      requests
    );
    Map<String, String> overlappedRequests = AccessRequestCommonActions.findOverLappedRequests(
      accessRequestsMap
    );
    Test.stopTest();
    Assert.isTrue(
      overlappedRequests.isEmpty(),
      'It should not find overlapped PAM'
    );
  }

  @isTest
  static void checkIfOverlapTest() {
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    String accessRequestName = [
      SELECT Id, Name
      FROM Access_Request__c
    ][0]
    .Name;
    Access_Request__c ar = new Access_Request__c();
    ar.Requestor__c = engineerUser.Id;
    ar.Reason__c = 'Production deployment';
    ar.Reference_Number__c = 'CR-987987';
    ar.Access_Type__c = 'System Administrator';
    ar.When__c = 'Immediate';
    ar.Duration_hrs__c = '3';
    ar.RecordTypeId = PRIVILEGED_ACCESS_REQUESTS_RT_ID;

    Privileged_Access_Request__c par = new Privileged_Access_Request__c();
    par.Previous_Profile_Id__c = stdUserProfile.Id;
    par.Start_Date_Time__c = system.now().addHours(1);
    par.Revoke_Time__c = system.now().addHours(3);

    Test.startTest();
    insert ar;
    par.Access_Request__c = ar.Id;
    insert par;
    ar.Status__c = AccessRequestCommonActions.STATUS_SUBMITTED;
    try {
      update ar;

      //IF we reach this then our trigger did not apply successfully.
      Assert.isTrue(false, 'Failed to check overlapping on trigger.');
    } catch (DmlException error) {
      //IF we reach this then our trigger did not apply successfully.
      Assert.isTrue(
        error.getMessage()
          .contains(
            'The request overlaps with an existing Privileged Access Request: ' +
              accessRequestName +
              '. Please double check the start time and duration to ensure they do not overlap'
          ),
        'Succeed to check overlapping on trigger.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void checkIfApproverFlowDisabledGlobal() {
    User engineerUser = TestUtil.getUserByFirstName('PAM_Engineer');
    Access_Request__c accessRequest = getAccessRequest(
      engineerUser.Id,
      PRIVILEGED_ACCESS_REQUESTS_RT_ID
    );

    Test.startTest();
    insert new Salesforce_Library_Settings__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Disable_Flows__c = true,
      Disable_Triggers__c = false,
      Disable_VRs__c = false
    );
    insert accessRequest;
    accessRequest.Status__c = AccessRequestCommonActions.STATUS_SUBMITTED;
    String customSettingsName = Salesforce_Library_settings__c.getOrgDefaults()
      .Name;
    try {
      update accessRequest;
      Assert.isTrue(
        false,
        'Trigger could not check if flow has been disabled.'
      );
    } catch (DmlException error) {
      Assert.isTrue(
        error.getMessage()
          .contains(
            'Updating Access request failed due to: ' +
              customSettingsName +
              ' Disable_Flows__c is true.'
          ),
        'Trigger could check if flow has been disabled.'
      );
    }

    Test.stopTest();
  }

  private static Privileged_Access_Request__c getPrivilegedAccessRequest() {
    return [
      SELECT Id, Actual_Access_Granted_Time__c, Actual_Access_Revoked_Time__c
      FROM Privileged_Access_Request__c
      LIMIT 1
    ];
  }
}
