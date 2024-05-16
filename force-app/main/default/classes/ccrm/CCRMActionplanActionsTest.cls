/**
 * @author Ayushi Gupta
 * @since 03/2024
 * @description Test class for CCRMActionPlanActions
 */
@isTest
private class CCRMActionplanActionsTest {
  @testSetup
  static void makeData() {
    User ccrmBaseUser;
    ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
    TestUtil.assignPermissionSets(
      new List<String>{ 'CCRM_Opportunity_Access', 'ActionPlans' },
      new List<User>{ ccrmBaseUser }
    );
  }
  @isTest
  static void testCreateActionPlan() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      ActionPlan plan;

      Test.startTest();
      plan = CCRMActionPlanActions.createActionPlan(
        '0069h000004rqUQAAY',
        'Needs Analysis BB Action Plan Template',
        '0PT9h0000001uwDGAQ',
        ccrmBaseUser.Id
      );
      Test.stopTest();

      System.assertEquals(
        'Needs Analysis BB Action Plan Template',
        plan.Name,
        'Plan name does not match'
      );
    }
  }

  @isTest
  static void insertActionPlansTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList;
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;
      CCRMActionPlanActions.CCRMActionPlanWrapper planWrapper;
      List<ActionPlan> actionPlan;

      Test.startTest();
      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      CCRMTestDataFactory.createActionPlans();

      oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();
      oppWrapper.oppIdToOwnerIdMap = new Map<Id, String>{
        oppList[0].Id => ccrmBaseUser.Id
      };

      planWrapper = new CCRMActionPlanActions.CCRMActionPlanWrapper();
      planWrapper.templates.add(CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP);

      planWrapper.oppsWithNoActionPlansToTemplateNameMap = new Map<Id, List<String>>{
        oppList[0].Id => new List<String>{
          CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
        }
      };
      CCRMActionPlanActions.mockResults = [
        SELECT Id, Name, Status, ActionPlanTemplate.Name
        FROM ActionPlanTemplateVersion
        WHERE Name = :CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
      ];
      actionPlan = CCRMActionPlanActions.insertActionPlans(
        planWrapper,
        oppWrapper
      );
      Test.stopTest();

      System.assertEquals(1, actionPlan.size(), 'No action plans exist');
    }
  }

  @isTest
  static void insertActionPlansWithNoOppTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList;
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;
      CCRMActionPlanActions.CCRMActionPlanWrapper planWrapper;
      List<ActionPlan> actionPlan = new List<ActionPlan>();

      Test.startTest();
      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      CCRMTestDataFactory.createActionPlans();

      oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();

      planWrapper = new CCRMActionPlanActions.CCRMActionPlanWrapper();

      planWrapper.oppsWithNoActionPlansToTemplateNameMap = new Map<Id, List<String>>();

      actionPlan = CCRMActionPlanActions.insertActionPlans(
        planWrapper,
        oppWrapper
      );
      Test.stopTest();

      System.assertEquals(0, actionPlan.size(), 'Action plans exist');
    }
  }

  @isTest
  static void getOppsWithNoActionPlansTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;
      CCRMActionplanActions.CCRMActionPlanWrapper planWrapper;

      Test.startTest();
      oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();
      oppWrapper.oppIdToTemplateNameMap = new Map<Id, String>{
        '0069h000004rqUQAAY' => CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
      };
      planWrapper = CCRMActionPlanActions.getOppsWithNoActionPlans(
        new Map<Id, List<String>>(),
        oppWrapper
      );
      Test.stopTest();

      System.assertEquals(1, planWrapper.templates.size(), 'No template exist');
    }
  }

  @isTest
  static void checkForExistingActionPlansTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Opportunity opp;
      ActionPlan plan;
      Map<Id, List<String>> oppsWithActionPlans;

      Test.startTest();
      opp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h000004rqUQAAY',
        'Test Opp',
        CCRMConstants.CCRM_OPP_RT_ID,
        'Opportunity Identified'
      );
      plan = new ActionPlan();
      plan.TargetId = '0069h000004rqUQAAY';
      plan.Name = CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP;
      CCRMActionPlanActions.mockResults = new List<ActionPlan>{ plan };
      oppsWithActionPlans = CCRMActionPlanActions.checkForExistingActionPlans(
        new Map<Id, String>{
          '0069h000004rqUQAAY' => CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
        }
      );
      Test.stopTest();

      System.assertEquals(
        0,
        oppsWithActionPlans.keySet().size(),
        'Opp with action plans exist'
      );
    }
  }

  @isTest
  static void userwithNoAccessTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    Map<Id, PermissionSet> ps = new Map<Id, PermissionSet>(
      [
        SELECT Id, Name
        FROM PermissionSet
        WHERE
          Name IN :new List<String>{ 'CCRM_Opportunity_Access', 'ActionPlans' }
      ]
    );
    List<PermissionSetAssignment> psAssignment = [
      SELECT Id, AssigneeId, PermissionSetId
      FROM PermissionSetAssignment
      WHERE AssigneeId = :ccrmBaseUser.Id AND PermissionSetId IN :ps.keySet()
    ];
    if (psAssignment != null && psAssignment.size() > 0) {
      delete psAssignment;
    }

    System.runAs(ccrmBaseUser) {
      Map<Id, List<String>> oppsWithActionPlans;
      String exMsg;

      Test.startTest();
      try {
        oppsWithActionPlans = CCRMActionPlanActions.checkForExistingActionPlans(
          new Map<Id, String>{
            '0069h000004rqUQAAY' => CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
          }
        );
      } catch (Exception e) {
        exMsg = e.getMessage();
      }
      Test.stopTest();

      System.assertEquals(
        exMsg,
        'Insufficient permissions: secure query included inaccessible field',
        'You can access fields'
      );
    }
  }
}
