/**
 * @author Greg Shaw
 * @since 09-2023
 * @description Test class for IDRQualityAssessmentTaskActions
 */

@IsTest
private class IDRQualityAssessmentTaskActionsTest {
  public static final String REFERENCE_VALUE = 'TestRef';

  /**
   * @description Tests IDRQualityAssessmentTaskActions.checkOnReversionToPending
   */
  @IsTest
  static void checkOnReversionToPending() {
    User oQAUser = createComplianceTasksImpl();

    System.runAs(oQAUser) {
      List<Quality_Assessment__c> lstAssessments = [
        SELECT Id, Status__c
        FROM Quality_Assessment__c
        WHERE Status__c = :QualityAssessmentActions.STATUS_COMPLETE
      ];
      Set<Id> stAssessmentIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        oAssessment.Status__c = IDRQualityAssessmentTaskActions.STATUS_PENDING;
        stAssessmentIds.add(oAssessment.Id);
      }

      update lstAssessments;

      List<Task> lstTasks = [
        SELECT Id, Status, WhatId, RecordType.DeveloperName
        FROM Task
        WHERE
          WhatId IN :stAssessmentIds
          AND Status = :IDRConstants.TASK_STATUS_EXPIRED
          AND RecordTypeId = :GetHelpConstants.TASK_COMPLIANCE_RT_ID
      ];

      System.assertEquals(lstAssessments.size(), lstTasks.size(), 'Count');
    }
  }

  /**
   * @description Tests IDRQualityAssessmentTaskActions.createComplianceTasks
   */
  @IsTest
  static void createComplianceTasks() {
    createComplianceTasksImpl();
  }

  static User createComplianceTasksImpl() {
    Profile stdXUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZ Standard User');
    UserRole cqRole = CommonUtil.getUserRoleByDevName(
      'Capability_Quality_C_Q_Team'
    );
    UserRole crplRole = CommonUtil.getUserRoleByDevName(
      'Customer_Resolution_Leadership'
    );

    User oQAUser;
    User oIDRUser;
    List<User> lstUsers = new List<User>{
      // Create QA user
      oQAUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'QA_User',
          'ProfileId' => stdXUserProfile.Id,
          'UserRoleId' => cqRole.Id
        }
      ),
      // Create IDR user
      oIDRUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'IDR_User',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => crplRole.Id
        }
      )
    };
    insert lstUsers;

    // Add IDR User permissions on test users
    PermissionSet ps = CommonUtil.getPermissionSetByName('IDR_User');
    List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>{
      TestUtil.createPSAssignment(oQAUser.Id, ps.Id)
    };

    List<PermissionSetGroup> lstPSG = [
      SELECT Id, DeveloperName
      FROM PermissionSetGroup
      WHERE DeveloperName IN ('CMOS_Quality_Assessor', 'IDR_Level_1')
    ];
    List<Id> lstPSGIds = new List<Id>();
    for (PermissionSetGroup psg : lstPSG) {
      System.debug('psg: ' + psg);
      lstPSGIds.add(psg.Id);
      lstPSA.add(
        new PermissionSetAssignment(
          AssigneeId = oQAUser.Id,
          PermissionSetGroupId = psg.Id
        )
      );
    }

    System.debug('PSA: ' + lstPSA);
    insert lstPSA;

    Test.calculatePermissionSetGroup(lstPSGIds);

    Test.startTest();

    Case[] newCases = new List<Case>();
    System.runAs(oQAUser) {
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        newCases.add(
          new Case(
            RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
            IDR_Customer_Number__c = '1234567890',
            Status = 'Closed'
          )
        );
      }
      insert newCases;

      Quality_Assessment__c[] lstAssessments = new List<Quality_Assessment__c>();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        lstAssessments.add(
          new Quality_Assessment__c(
            Status__c = 'In Progress',
            Related_Case__c = newCases[i].Id,
            Case_Manager__c = oQAUser.Id,
            TeamManager__c = oIDRUser.Id,
            RecordTypeId = IDRConstants.idrtCQQualityAssessment
          )
        );
      }
      insert lstAssessments;

      Set<Id> stAssessmentIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        oAssessment.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
        oAssessment.Context_and_General_Comments__c = REFERENCE_VALUE;
        stAssessmentIds.add(oAssessment.Id);
      }

      update lstAssessments;

      Test.stopTest();

      List<Task> lstTasks = [
        SELECT Id, Status, WhatId, RecordType.DeveloperName
        FROM Task
        WHERE
          WhatId IN :stAssessmentIds
          AND Status = 'Open'
          AND RecordTypeId = :GetHelpConstants.TASK_COMPLIANCE_RT_ID
      ];

      System.debug('Tasks: ' + lstTasks);
      System.assertEquals(lstAssessments.size(), lstTasks.size(), 'Count');
    }
    return oQAUser;
  }
}
