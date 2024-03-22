/**
 * @author Anuja Vats
 * @since 03-2024
 * @description Test class for IDRQualityAssessmentDisputeTaskActions
 */

@IsTest
public class IDRQualityAssessmentDisputeTaskTest {
  static String qaRecordId = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.SObjectType
  );
  static String qaRecordId1 = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.SObjectType
  );
  static String qaRecordId2 = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.SObjectType
  );
  static String qaRecordId3 = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.SObjectType
  );
  static String qaRecordId4 = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.SObjectType
  );

  /**
   * @description Method to set up users for Quality Assessment record
   */
  @TestSetup
  static void makeData() {
    Profile stdXUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZ Standard User');
    UserRole cqRole = CommonUtil.getUserRoleByDevName(
      'Capability_Quality_C_Q_Team'
    );
    UserRole crplRole = CommonUtil.getUserRoleByDevName(
      'Customer_Resolution_Leadership'
    );
    User oQAUser;
    User oCQManager;
    List<User> lstUsers = new List<User>{
      // Create QA user
      oQAUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'DummyCQSpecialist',
          'ProfileId' => stdXUserProfile.Id,
          'UserRoleId' => cqRole.Id
        }
      ),
      // Create QAManager user
      oCQManager = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'DummyCQManager',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => cqRole.Id
        }
      )
    };
    insert lstUsers;
    oQAUser.ManagerId = oCQManager.ID;
    update oQAUser;
  }
  /**
   * @description Method get List of Quality Assessment record
   * @return List of Quality Assessment
   */
  static List<Quality_Assessment__c> getQAData() {
    List<Quality_Assessment__c> cQAssessments = new List<Quality_Assessment__c>();
    User oQAUser = [
      SELECT Id, Name
      FROM User
      WHERE FirstName = 'DummyCQSpecialist'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    Quality_Assessment__c qARecord = IDRTestDataFactory.createQARecord(
      qaRecordId,
      oQAUser
    );
    qARecord.Team_Manager_Response__c = IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE;

    Quality_Assessment__c qARecord1 = IDRTestDataFactory.createQARecord(
      qaRecordId1,
      oQAUser
    );
    qARecord1.C_Q_Manager_Response__c = 'Test Manager Response';

    Quality_Assessment__c qARecord2 = IDRTestDataFactory.createQARecord(
      qaRecordId2,
      oQAUser
    );
    qARecord2.TM_Response_to_C_Q_Manager_Review__c = IDRConstants.TM_REJECTS_CQ_MANAGER_RESPONSE;

    Quality_Assessment__c qARecord3 = IDRTestDataFactory.createQARecord(
      qaRecordId3,
      oQAUser
    );
    qARecord3.C_Q_Lead_Response__c = 'Test CQ Lead Response';

    Quality_Assessment__c qARecord4 = IDRTestDataFactory.createQARecord(
      qaRecordId4,
      oQAUser
    );
    qARecord4.Status__c = 'Pending';

    cQAssessments.add(qARecord);
    cQAssessments.add(qARecord1);
    cQAssessments.add(qARecord2);
    cQAssessments.add(qARecord3);
    cQAssessments.add(qARecord4);
    return cQAssessments;
  }
  /**
   * @description Method get Map of Id Quality Assessment record
   * @return Map of ID and Quality Assessment
   */
  static Map<Id, Quality_Assessment__c> getQAOldRecordData() {
    Map<Id, Quality_Assessment__c> mpOldQARecords = new Map<Id, Quality_Assessment__c>();
    User oQAUser = [
      SELECT Id, Name
      FROM User
      WHERE FirstName = 'DummyCQSpecialist'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    Quality_Assessment__c qAOldRecord = IDRTestDataFactory.createQARecord(
      qaRecordId,
      oQAUser
    );
    Quality_Assessment__c qAOldRecord1 = IDRTestDataFactory.createQARecord(
      qaRecordId1,
      oQAUser
    );
    Quality_Assessment__c qAOldRecord2 = IDRTestDataFactory.createQARecord(
      qaRecordId2,
      oQAUser
    );
    Quality_Assessment__c qAOldRecord3 = IDRTestDataFactory.createQARecord(
      qaRecordId3,
      oQAUser
    );
    mpOldQARecords.put(qAOldRecord.Id, qAOldRecord);
    mpOldQARecords.put(qAOldRecord1.Id, qAOldRecord1);
    mpOldQARecords.put(qAOldRecord2.Id, qAOldRecord2);
    mpOldQARecords.put(qAOldRecord3.Id, qAOldRecord3);
    return mpOldQARecords;
  }
  /**
   * @description test generateChangeFieldOnRecordMap()
   */
  @isTest
  static void testGenerateChangeFieldOnRecordMap() {
    Test.startTest();
    Map<Id, String> rcdMap = IDRQualityAssessmentsDisputeTaskActions.generateChangeFieldOnRecordMap(
      getQAData(),
      getQAOldRecordData()
    );
    Test.stopTest();
    System.assertEquals(1, rcdMap.size(), 'One Field Changed in the Record');
  }
  /**
   * @description test generateDisputeTask()
   */
  @isTest
  static void testGenerateDisputeTask() {
    List<Quality_Assessment__c> qaList = getQAData();
    qaList[0]
      .Team_Manager_Response__c = IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE;
    qaList[1].C_Q_Manager_Response__c = 'Test Manager Response';
    qaList[2]
      .TM_Response_to_C_Q_Manager_Review__c = IDRConstants.TM_REJECTS_CQ_MANAGER_RESPONSE;
    qaList[3].C_Q_Lead_Response__c = 'Test CQ Lead Response';

    List<Task> disputeTasks = IDRQualityAssessmentsDisputeTaskActions.generateDisputeTask(
      new Map<Id, String>{
        qaList[0].Id => 'Team_Manager_Response__c',
        qaList[1].Id => 'C_Q_Manager_Response__c',
        qaList[2].Id => 'TM_Response_to_C_Q_Manager_Review__c',
        qaList[3].Id => 'C_Q_Lead_Response__c'
      },
      qaList
    );
    System.assertEquals(
      4,
      disputeTasks.size(),
      'Tasks Created for All Qa Records'
    );
  }
  /**
   * @description test createDisputeTasks()
   */
  @isTest
  static void testCreateDisputeTasks() {
    List<Quality_Assessment__c> qaList = getQAData();
    List<Quality_Assessment__c> qaListOld = getQAData();
    qaList[0]
      .TM_Response_to_C_Q_Manager_Review__c = IDRConstants.TM_REJECTS_CQ_MANAGER_RESPONSE;
    IDRQualityAssessmentsDisputeTaskActions.createDisputeTasks(
      new List<Quality_Assessment__c>{ qaList[0] },
      new Map<Id, Quality_Assessment__c>{ qaListOld[0].Id => qaListOld[0] }
    );
    List<Task> disputeTasks = [
      SELECT Id, Status, WhatId, RecordType.DeveloperName
      FROM Task
      WHERE
        WhatId = :qaList[0].Id
        AND RecordTypeId = :IDRConstants.TASK_COMPLIANCE_RT_ID
    ];
    System.assertNotEquals(
      1,
      disputeTasks.size(),
      'Dispute Tasks Actually not inserted in DB'
    );
  }
}
