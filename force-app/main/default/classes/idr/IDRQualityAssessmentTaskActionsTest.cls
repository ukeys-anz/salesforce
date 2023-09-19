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
      List<Quality_Assessment__c> lstAssessments = [SELECT Id, Status__c
                                                    FROM Quality_Assessment__c
                                                        WHERE Status__c = :QualityAssessmentActions.STATUS_COMPLETE
        ];
      Set<Id> stAssessmentIds = new Set<Id>();
      for ( Quality_Assessment__c oAssessment : lstAssessments) {
        oAssessment.Status__c = IDRQualityAssessmentTaskActions.STATUS_PENDING;
        stAssessmentIds.add(oAssessment.Id);
      }

      update lstAssessments;
      System.debug('Assessments: ' + lstAssessments);

      List<Task> lstTasks = [SELECT Id, Status, WhatId, RecordType.DeveloperName
                              FROM Task
                              WHERE WhatId IN :stAssessmentIds
                              AND Status = 'Expired'
                                AND RecordTypeId = :GetHelpConstants.TASK_COMPLIANCE_RT_ID
        ];

      System.debug('Tasks: ' + lstTasks);
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

    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole cqRole = CommonUtil.getUserRoleByDevName('Capability_Quality_C_Q_Team');

    // Create QA user
    User oQAUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'QA_User',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => cqRole.Id
      }
    );
    insert oQAUser;

    // Add IDR User permissions on test users
    PermissionSet ps = CommonUtil.getPermissionSetByName('IDR_User');
    insert TestUtil.createPSAssignment(oQAUser.Id, ps.Id);

    Test.startTest();

    System.runAs(oQAUser) {
    Case[] newCases = new List<Case>();
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
            TeamManager__c = oQAUser.Id,
          RecordTypeId = (Math.mod(i, 2) == 0) ? IDRConstants.idrtCQQualityAssessment : IDRConstants.idrtCallLetterReviewQualityAssessment
        )
      );
    }
    insert lstAssessments;

    Set<Id> stAssessmentIds = new Set<Id>();
    for ( Quality_Assessment__c oAssessment : lstAssessments) {
      oAssessment.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
      oAssessment.Context_and_General_Comments__c = REFERENCE_VALUE;
      stAssessmentIds.add(oAssessment.Id);
    }

    update lstAssessments;

    Test.stopTest();
    System.debug('Assessments: ' + lstAssessments);

    List<Task> lstTasks = [SELECT Id, Status, WhatId, RecordType.DeveloperName
                            FROM Task
                            WHERE WhatId IN :stAssessmentIds
                            AND Status = 'Open'
                              AND RecordTypeId = :GetHelpConstants.TASK_COMPLIANCE_RT_ID
      ];

    System.debug('Tasks: ' + lstTasks);
    System.assertEquals(lstAssessments.size(), lstTasks.size(), 'Count');
  }
    return oQAUser;
  }
}