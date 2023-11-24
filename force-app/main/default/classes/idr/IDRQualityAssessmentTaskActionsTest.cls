/**
 * @author Greg Shaw
 * @since 09-2023
 * @description Test class for IDRQualityAssessmentTaskActions
 */

@IsTest
public class IDRQualityAssessmentTaskActionsTest {
  @IsTest
  static void checkMandatoryFields() {
    Boolean fExceptionThrown = false;
    try {
      createComplianceTasksImpl(false);
    } catch (DmlException ex) {
      fExceptionThrown = true;
    }
    System.assert(
      fExceptionThrown,
      'Mandatory fields didn\'t trigger exception'
    );
  }
  /**
   * @description Tests IDRQualityAssessmentTaskActions.checkOnReversionToPending
   */
  @IsTest
  static void checkOnReversionFromComplete() {
    User oQAUser = createComplianceTasksImpl(true);

    System.runAs(oQAUser) {
      List<Quality_Assessment__c> lstAssessments = [
        SELECT Id, Status__c
        FROM Quality_Assessment__c
        WHERE Status__c = :QualityAssessmentActions.STATUS_COMPLETE
      ];
      Set<Id> stAssessmentIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        oAssessment.Status__c = QualityAssessmentActions.STATUS_PENDING;
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
    createComplianceTasksImpl(true);
  }

  static User createComplianceTasksImpl(Boolean fFillMandatoryFields) {
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
      lstPSGIds.add(psg.Id);
      lstPSA.add(
        new PermissionSetAssignment(
          AssigneeId = oQAUser.Id,
          PermissionSetGroupId = psg.Id
        )
      );
    }

    Test.calculatePermissionSetGroup(lstPSGIds);

    insert lstPSA;

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
      Quality_Assessment__c oNewAssessment;
      Map<String, FieldSet> mpAssessmentFieldSets = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        lstAssessments.add(
          oNewAssessment = new Quality_Assessment__c(
            Status__c = QualityAssessmentActions.STATUS_PENDING,
            Related_Case__c = newCases[i].Id,
            Case_Manager__c = oQAUser.Id,
            TeamManager__c = oIDRUser.Id,
            RecordTypeId = IDRConstants.idrtCQQualityAssessment
          )
        );
        if (fFillMandatoryFields) {
          fillMandatoryFields(oNewAssessment, mpAssessmentFieldSets);
        }
      }
      insert lstAssessments;

      Set<Id> stAssessmentIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        oAssessment.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
        oAssessment.Team_Manager_Response__c = '';

        stAssessmentIds.add(oAssessment.Id);
      }

      Boolean fExceptionThrown = false;
      try {
        update lstAssessments;
      } catch (DmlException ex) {
        fExceptionThrown = true;
      }
      System.assert(
        fExceptionThrown,
        'Update should\'ve failed for missing Team_Manager_Response__c.'
      );

      for (Quality_Assessment__c oAssessment : lstAssessments) {
        oAssessment.Team_Manager_Response__c = 'Accepted by TM';
        oAssessment.Team_Manager_Comments__c = 'LGTM';
      }
      // try again
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

  /**
   * @description fill Quality_Assessment__c record with mandatory fields noted in fieldset
   * @param oAssessment  record to apply mandatory values to
   * @param mpAssessmentFieldSets map of fieldsets
   */
  public static void fillMandatoryFields(
    Quality_Assessment__c oAssessment,
    Map<String, FieldSet> mpAssessmentFieldSets
  ) {
    String strFieldsetId = IDRQualityAssessmentActions.getFieldsetId(
      oAssessment
    );
    Schema.FieldSet oFieldSet;
    if (
      strFieldsetId != '' &&
      (oFieldSet = mpAssessmentFieldSets.get(strFieldsetId + '_mandatory')) !=
      null
    ) {
      for (Schema.FieldSetMember field : oFieldSet.getFields()) {
        if (oAssessment.get(field.SObjectField) == null) {
          if (field.getType() == DisplayType.REFERENCE) {
            switch on field.fieldPath {
              when 'C_Q_Specialist__c' {
                oAssessment.put(field.SObjectField, UserInfo.getUserId());
              }
              when 'Case_Manager__c' {
                oAssessment.put(field.SObjectField, UserInfo.getUserId());
              }
              when 'TeamManager__c' {
                oAssessment.put(field.SObjectField, UserInfo.getUserId());
              }
            }
          } else if (field.getType() == DisplayType.PICKLIST) {
            for (
              PicklistEntry peEntry : field.getSObjectField()
                .getDescribe()
                .getPicklistValues()
            ) {
              // just use first one.
              oAssessment.put(field.SObjectField, peEntry.value);
              break;
            }
          } else {
            oAssessment.put(field.SObjectField, 'Met');
          }
        }
      }
    }
  }
}
