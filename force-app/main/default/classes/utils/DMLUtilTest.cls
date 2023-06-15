/**
 * @description       : Test class for DMLUtil class
 * @author            : Prakash B
 * @last modified on  : 19-04-2023
 **/
@isTest
public with sharing class DMLUtilTest {
  public static final Id GET_HELP_RECORDTYPEID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('Get_Help')
    .getRecordTypeId();

  public static final String REFERENCE_VALUE = 'TestRef';

  @isTest
  static void testSuccessfulRecordCreation() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a Coach User with 'Coach Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
      UserRole qaRole = CommonUtil.getUserRoleByDevName('Quality Analyst');
      User qa = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'QATestUser',
          'ProfileId' => profile.Id,
          'UserRoleId' => qaRole.Id,
          'Username' => 'This.Is.A@Test.User'
        }
      );
      insert qa;
    }

    User qaUser = [SELECT ID FROM User WHERE FirstName = 'QATestUser' LIMIT 1];

    // Assign related PSs
    List<String> qaPs = new List<String>{ 'Quality_Assessment_Read_Write' };
    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :qaPs
    ];

    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      psaList.add(TestUtil.createPSAssignment(qaUser.id, ps.Id));
    }
    insert psaList;

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qa.Reference__c = REFERENCE_VALUE;
      qaList.add(qa);
    }

    Test.startTest();
    System.runAs(qaUser) {
      DMLUtil.insertRecords(
        qaList,
        DMLUtil.ALLOW_PARTIAL_UPDATE,
        DMLUtil.USER_MODE
      );
    }
    Test.stopTest();

    qaList = [SELECT ID FROM Quality_Assessment__c];

    System.assertEquals(10, qaList.size(), '10 QA records should be created');
  }

  @isTest
  static void testRecordCreationFailure() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qaList.add(qa);
    }

    Test.startTest();
    DMLUtil.insertRecords(
      qaList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
    Test.stopTest();

    List<LogEntry__c> logEntryList = new List<LogEntry__c>(
      [SELECT ID FROM LogEntry__c]
    );

    System.assertEquals(
      1,
      logEntryList.size(),
      'Log Entry records should be created due to record creation failure'
    );
  }

  @isTest
  static void testRecordUpsertFailure() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qaList.add(qa);
    }

    Test.startTest();
    DMLUtil.upsertRecords(
      qaList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
    Test.stopTest();

    List<LogEntry__c> logEntryList = new List<LogEntry__c>(
      [SELECT ID FROM LogEntry__c]
    );

    System.assertEquals(
      1,
      logEntryList.size(),
      'Log Entry records should be created due to record creation failure'
    );
  }

  @isTest
  static void testRecordCreationPermissionFailure() {
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a Coach User with 'Coach Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
      UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
      User coach = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'CoachTest',
          'ProfileId' => profile.Id,
          'UserRoleId' => coachRole.Id,
          'Username' => 'This.Is.A@Test.User'
        }
      );
      insert coach;
    }

    User coachUser = [
      SELECT ID
      FROM User
      WHERE FirstName = 'CoachTest'
      LIMIT 1
    ];

    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qaList.add(qa);
    }

    Test.startTest();
    System.runAs(coachUser) {
      DMLUtil.insertRecords(
        qaList,
        DMLUtil.ALLOW_PARTIAL_UPDATE,
        DMLUtil.USER_MODE
      );
    }
    Test.stopTest();

    List<LogEntry__c> logEntryList = new List<LogEntry__c>(
      [SELECT ID, LogMessage__c FROM LogEntry__c]
    );

    System.assertEquals(
      1,
      logEntryList.size(),
      'Log Entry records should be created due to record creation failure'
    );
  }

  @isTest
  static void testRecordUpdationFailure() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qa.Reference__c = REFERENCE_VALUE;
      qaList.add(qa);
    }

    insert qaList;

    qaList = [SELECT Id, Reference__c FROM Quality_Assessment__c];

    for (Quality_Assessment__c qa : qalist) {
      qa.Reference__c = '';
    }

    Test.startTest();
    DMLUtil.updateRecords(
      qaList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
    Test.stopTest();

    List<LogEntry__c> logEntryList = new List<LogEntry__c>(
      [SELECT ID FROM LogEntry__c]
    );

    System.assertEquals(
      1,
      logEntryList.size(),
      'Log Entry records should be created due to record creation failure'
    );
  }

  @isTest
  static void testSuccessfulRecordDeletion() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qa.Reference__c = REFERENCE_VALUE;
      qaList.add(qa);
    }

    insert qaList;

    qaList = [SELECT ID FROM Quality_Assessment__c];

    System.assertEquals(10, qaList.size(), '10 QA records should be created');

    Test.startTest();
    DMLUtil.deleteRecords(
      qaList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
    Test.stopTest();

    qaList = [SELECT ID FROM Quality_Assessment__c];

    System.assertEquals(0, qaList.size(), 'All QA records should be deleted');
  }

  @isTest
  static void testSuccessfulRecordUndeletion() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < 10; i++) {
      Quality_Assessment__c qa = new Quality_Assessment__c();
      qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
      qa.RecordTypeId = GET_HELP_RECORDTYPEID;
      qa.Reference__c = REFERENCE_VALUE;
      qaList.add(qa);
    }

    insert qaList;

    qaList = [SELECT ID FROM Quality_Assessment__c];

    System.assertEquals(10, qaList.size(), '10 QA records should be created');

    delete qaList;

    List<Quality_Assessment__c> qaListDeleted = [
      SELECT ID
      FROM Quality_Assessment__c
    ];

    System.assertEquals(
      0,
      qaListDeleted.size(),
      'All QA records should be deleted'
    );

    Test.startTest();
    DMLUtil.undeleteRecords(
      qaList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
    Test.stopTest();

    qaList = [SELECT ID FROM Quality_Assessment__c];

    System.assertEquals(10, qaList.size(), 'All QA records should be restored');
  }
}
