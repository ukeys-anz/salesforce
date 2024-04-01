/**
 * @author Ayushi Gupta
 * @since 02/2024
 * @description Test class for CCRMOpportunityActionsSkipStageHelper
 */
@isTest
private class CCRMOpportunitySkipStageHelperTest {
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
  static void validateOppOnInsertTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'Stage can only be set to Opportunity Identified.';
    System.runAs(ccrmBaseUser) {
      List<Database.Error> errors;
      Database.Error error;

      Test.startTest();
      Opportunity opp = CCRMTestDataFactory.createStaticOpportunityData(
        null,
        'Test Opp',
        CCRMConstants.CCRM_OPP_RT_ID,
        'Needs Analysis'
      );
      CCRMOpportunityActionsSkipStageHelper.validateCCRMOpportunity(
        new List<Opportunity>{ opp },
        new Map<Id, Opportunity>(),
        true
      );
      errors = opp.getErrors();
      error = errors.get(0);
      Test.stopTest();

      System.assertEquals(1, errors.size());
      System.assertEquals(
        expMsg,
        error.getMessage(),
        'Opp updated successfully'
      );
    }
  }

  @isTest
  static void validateCCRMOpportunitiesTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsgForLeadSource = 'Other Source Detail is mandatory if Lead Source is Other.';
    String expMsgForLostOpp =
      'Please provide valid Lost Reason/Lost Reason Detail.\n' +
      'Won From/Lost To is mandatory to Proceed to Opportunity Won/Lost.';
    String expMsgForWonOpp = 'Won From/Lost To is mandatory to Proceed to Opportunity Won/Lost.';

    System.runAs(ccrmBaseUser) {
      Opportunity leadSourceOpp;
      Opportunity closedLostOpp;
      Opportunity closedWonOpp;
      List<Database.Error> leadSourceOppErrors;
      List<Database.Error> wonOppErrors;
      List<Database.Error> lostOppErrors;
      Database.Error leadSourceError;
      Database.Error wonOppError;
      Database.Error lostOppError;

      Test.startTest();
      leadSourceOpp = CCRMTestDataFactory.createStaticOpportunityData(
        null,
        'Test Opp 1',
        CCRMConstants.CCRM_OPP_RT_ID,
        'Needs Analysis'
      );
      leadSourceOpp.LeadSource = 'Other';
      closedLostOpp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h000004rqUQAAY',
        'Test Opp 2',
        CCRMConstants.CCRM_OPP_RT_ID,
        CCRMConstants.OPP_LOST
      );
      closedWonOpp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h00000ATaQYAA1',
        'Test Opp 3',
        CCRMConstants.CCRM_OPP_RT_ID,
        CCRMConstants.OPP_WON
      );

      CCRMOpportunityActionsSkipStageHelper.validateCCRMOpportunity(
        new List<Opportunity>{ leadSourceOpp, closedLostOpp, closedWonOpp },
        new Map<Id, Opportunity>{
          '0069h000004rqUQAAY' => closedLostOpp,
          '0069h00000ATaQYAA1' => closedWonOpp
        },
        false
      );

      leadSourceOppErrors = leadSourceOpp.getErrors();
      leadSourceError = leadSourceOppErrors.get(0);

      lostOppErrors = closedLostOpp.getErrors();
      lostOppError = lostOppErrors.get(0);

      wonOppErrors = closedWonOpp.getErrors();
      wonOppError = wonOppErrors.get(0);

      Test.stopTest();

      System.assertEquals(1, leadSourceOppErrors.size());
      System.assertEquals(1, lostOppErrors.size());
      System.assertEquals(1, wonOppErrors.size());
      System.assertEquals(
        expMsgForLeadSource,
        leadSourceError.getMessage(),
        'Opp updated successfully'
      );
      System.assertEquals(
        expMsgForLostOpp,
        lostOppError.getMessage(),
        'Opp updated successfully'
      );
      System.assertEquals(
        expMsgForWonOpp,
        wonOppError.getMessage(),
        'Opp updated successfully'
      );
    }
  }

  @isTest
  static void validateSkipStageTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'Unfortunately, you are not allowed to skip stages or re-open a closed Opportunity.';
    System.runAs(ccrmBaseUser) {
      Opportunity opp;
      Opportunity oldOpp;
      Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping;
      Map<Id, String> oppsStageSegmentMap;
      List<Database.Error> errors;
      Database.Error error;

      Test.startTest();
      opp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h000004rqUQAAY',
        'Test Opp 1',
        CCRMConstants.CCRM_OPP_RT_ID,
        CCRMConstants.CUST_ACCEPT
      );

      oldOpp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h000004rqUQAAY',
        'Test Opp 2',
        CCRMConstants.CCRM_OPP_RT_ID,
        CCRMConstants.NEED_ANALYSIS
      );

      stageActionPlanMapping = new Map<String, CCRM_Commercial_Stage_Action_Plan__mdt>{
        'Needs Analysis-BB' => new CCRM_Commercial_Stage_Action_Plan__mdt(
          Current_Stage__c = 'Needs Analysis',
          Previous_Stage__c = 'Opportunity Identified',
          Template_Name__c = CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP,
          Next_Stage__c = 'Solution Development'
        )
      };
      oppsStageSegmentMap = new Map<Id, String>{
        '0069h000004rqUQAAY' => 'Needs Analysis-BB'
      };

      CCRMOpportunityActionsSkipStageHelper.addErrorForSkippedStage(
        new List<Opportunity>{ opp },
        new Map<Id, Opportunity>{ '0069h000004rqUQAAY' => oldOpp },
        stageActionPlanMapping,
        oppsStageSegmentMap
      );

      errors = opp.getErrors();
      error = errors.get(0);

      Test.stopTest();
      System.assertEquals(1, errors.size());
      System.assertEquals(
        expMsg,
        error.getMessage(),
        'Opp updated successfully'
      );
    }
  }

  @isTest
  static void checkOpenTaskForClosedOpportunitiesTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      List<Database.Error> errors;
      Opportunity closedLostOpp;

      Test.startTest();
      closedLostOpp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h000004rqUQAAY',
        'Test Opp 2',
        CCRMConstants.CCRM_OPP_RT_ID,
        CCRMConstants.OPP_LOST
      );
      CCRMOpportunityActionsSkipStageHelper.checkOpenTaskForClosedOpportunities(
        new Map<Id, Opportunity>{ '0069h000004rqUQAAY' => closedLostOpp }
      );
      errors = closedLostOpp.getErrors();
      Test.stopTest();
      System.assertEquals(0, errors.size());
    }
  }

  @isTest
  static void displayErrorForMandatoryTaskTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Opportunity opp;
      List<Database.Error> errors;
      Map<Id, String> oppIdToTemplateMap;

      Test.startTest();
      opp = CCRMTestDataFactory.createStaticOpportunityData(
        '0069h000004rqUQAAY',
        'Test Opp',
        CCRMConstants.CCRM_OPP_RT_ID,
        CCRMConstants.NEED_ANALYSIS
      );
      CCRMOpportunityActionsSkipStageHelper.displayErrorForMandatoryTask(
        new Map<Id, String>{
          '0069h000004rqUQAAY' => CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
        },
        new Map<Id, Opportunity>()
      );
      errors = opp.getErrors();
      Test.stopTest();
      System.assertEquals(0, errors.size());
    }
  }
}
