/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Opportunity Action Test is the test class for CCRM Opportunity Actions Class.
 */
@isTest
private class CCRMOpportunityActionsTest {
  @testSetup
  static void makeData() {
    User ccrmBaseUser;
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
      TestUtil.assignPermissionSets(
        new List<String>{ 'CCRM_Opportunity_Access', 'ActionPlans' },
        new List<User>{ ccrmBaseUser }
      );
    }

    System.runAs(ccrmBaseUser) {
      CCRMTestDataFactory.createActionPlans();
    }
  }

  @isTest
  static void testCreateOpportunity() {
    //Given when banker creates a new Opportunity
    //When Account Name is valid and Amount is valid
    //Then Opportunity Name is Account_Name_Amount
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      Account accnt = CCRMTestDataFactory.createPersonAccount();

      Opportunity opp = new Opportunity();
      opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('Commercial_Opportunity')
        .getRecordTypeId();
      opp.Name = 'sample Opp';
      opp.AccountId = accnt.id;
      opp.StageName = 'Opportunity Identified';
      opp.Customer_Needs__c = 'Purchasing a new Business';
      opp.Amount = 2000;
      opp.CloseDate = System.today() + 10;
      insert opp;
      Test.stopTest();
      opp = [
        SELECT Id, Name, Opp_Id__c, Customer_Needs__c, Amount
        FROM Opportunity
        WHERE id = :opp.id
      ];
      System.assertEquals(
        opp.Opp_Id__c + ' ' + opp.Customer_Needs__c + ' sample Opp',
        opp.Name,
        'Opportunity Name is the same for Manual Opportunity.'
      );
    }
  }

  @isTest
  static void testOppName() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      Test.stopTest();
      Opportunity opp = [
        SELECT Id, Name, Opp_Id__c, Customer_Needs__c
        FROM Opportunity
        WHERE Id = :oppList[0].Id
      ];
      System.assertEquals(
        opp.Opp_Id__c + ' ' + opp.Customer_Needs__c + ' ' + 'Test Opp 1',
        opp.Name,
        'Opportunity Name not updated'
      );
    }
  }

  @istest
  static void testInsertionOfActionPlans() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      Test.startTest();
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      Test.stopTest();
      List<ActionPlan> apList = [
        SELECT Id, TargetId
        FROM ActionPlan
        WHERE TargetId = :oppList[0].Id
      ];
      System.assertEquals(1, apList.size(), 'Action Plan not created');
    }
  }

  @istest
  static void updateActionStatusCompleted() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    List<Task> taskList = new List<Task>();
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      Test.startTest();
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      for (ActionPlanItem iterator : [
        SELECT Id, ActionPlan.TargetId, ItemId
        FROM ActionPlanItem
        WHERE ActionPlan.TargetId = :oppList[0].Id
      ]) {
        taskList.add(
          new Task(
            Id = iterator.ItemId,
            Status = 'Completed',
            RecordTypeId = CCRMConstants.CCRM_TASK_RT_ID
          )
        );
      }
      update taskList;
      Test.stopTest();
      List<ActionPlan> apList = [
        SELECT Id, TargetId, ActionPlanState
        FROM ActionPlan
        WHERE TargetId = :oppList[0].Id AND ActionPlanState = 'Completed'
      ];
      System.assertEquals(1, apList.size(), 'Action Plan marked as completed');
    }
  }

  @isTest
  static void checkStageHasMandatoryTaskCompletedTest() {
    String expMsg = System.Label.CCRM_OpenTasksOnOpportunityError;
    String actualMsg = '';
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      Test.startTest();
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      try {
        oppList[0].StageName = CCRMConstants.SOL_DEV;
        update oppList;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Opp Stage updated successfully to Solution Development'
      );
    }
  }

  @isTest
  static void checkStageHasOpenTaskTest() {
    String expMsg = System.Label.CCRM_OpenTasksOnOpportunityCloseError;
    String actualMsg = '';
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList;
      ActionPlanItem item;
      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );

      Test.startTest();
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      item = [
        SELECT Id, Name, ItemState
        FROM ActionPlanItem
        WHERE Name = 'Search'
      ];
      item.ItemState = 'Completed';
      update item;
      oppList[0].StageName = CCRMConstants.SOL_DEV;
      update oppList;
      update item;
      oppList[0].StageName = CCRMConstants.APPROVED_OFFERED;
      update oppList;
      update item;
      oppList[0].StageName = CCRMConstants.CUST_ACCEPT;
      update oppList;
      try {
        oppList[0].StageName = CCRMConstants.OPP_WON;
        update oppList;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Opp Stage updated successfully to Closed Won'
      );
    }
  }

  @isTest
  static void existingActionPlansTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppList;
      ActionPlanItem item;
      List<ActionPlan> apList;

      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );

      Test.startTest();
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      item = [
        SELECT Id, Name, ItemState
        FROM ActionPlanItem
        WHERE Name = 'Search'
      ];
      item.ItemState = 'Completed';
      update item;
      oppList[0].StageName = CCRMConstants.SOL_DEV;
      update oppList;
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      oppList[0].StageName = CCRMConstants.OPP_IDENTIFIED;
      update oppList;
      oppList[0].StageName = CCRMConstants.NEED_ANALYSIS;
      update oppList;
      Test.stopTest();

      apList = [SELECT Id FROM ActionPlan WHERE TargetId = :oppList[0].Id];
      System.assertEquals(1, apList.size(), 'Action Plans are more than 1');
    }
  }

  @isTest
  static void testOpportunityOwnership() {
    User bbUser = new User();
    User sbbUser = new User();
    String errorMessage = '';
    //GIVEN a BB & a SBB User
    bbUser = CCRMTestDataFactory.createCCRMBaseUserWithCS('BB');
    sbbUser = CCRMTestDataFactory.createCCRMBaseUserWithCS('SBB');

    System.runAs(bbUser) {
      //GIVEN a Opportunity record
      Opportunity oppRec = CCRMTestDataFactory.createOpportunityRecords(
        1,
        bbUser,
        true
      )[0];

      Test.startTest();
      try {
        //WHEN update owner from BB to SBB
        oppRec.OwnerId = sbbUser.Id;
        update oppRec;
      } catch (Exception e) {
        errorMessage = e.getDmlMessage(0);
      }
      Test.stopTest();
      //THEN Error message as we can't transfer ownership outside the segment
      System.assertEquals(
        'Opportunity can only be transferred within your segment.',
        errorMessage,
        'User from different commercial segment able to update the Opportunity owner'
      );
    }
  }

  @isTest
  static void testUpdateBulkOppOwnership() {
    User bbUser = new User();
    User sbbUser = new User();
    //GIVEN a BB & a SBB User
    bbUser = CCRMTestDataFactory.createCCRMBaseUserWithCS('BB');
    sbbUser = CCRMTestDataFactory.createCCRMBaseUserWithCS('SBB');

    System.runAs(bbUser) {
      //GIVEN a Opportunity record
      Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{
        '0069h000004rqUQAAY' => (new Opportunity(
          Id = '0069h000004rqUQAAY',
          OwnerId = bbUser.Id,
          Opportunity_Owner__c = bbUser.Id,
          recordTypeId = CCRMConstants.CCRM_OPP_RT_ID
        ))
      };

      //WHEN update the Opportunity_Owner__c field on opportunity
      List<Opportunity> oppList = new List<Opportunity>{
        new Opportunity(
          Id = '0069h000004rqUQAAY',
          OwnerId = bbUser.Id,
          Opportunity_Owner__c = sbbUser.Id,
          recordTypeId = CCRMConstants.CCRM_OPP_RT_ID
        )
      };
      Test.startTest();
      CCRMOpportunityActions.updateBulkOppOwnership(oppList, oldOppMap);
      Test.stopTest();

      //THEN check if update the actual OwnerId field is updated
      System.assertEquals(
        oppList[0].OwnerId,
        oppList[0].Opportunity_Owner__c,
        'Owner not updated'
      );
    }
  }

  @isTest
  static void testOwnerCommercialSegment() {
    User bbUser = new User();
    User sbbUser = new User();
    //GIVEN a BB & a SBB User
    bbUser = CCRMTestDataFactory.createCCRMBaseUserWithCS('BB');
    sbbUser = CCRMTestDataFactory.createCCRMBaseUserWithCS('SBB');

    Map<Id, User> userMap = new Map<Id, User>();
    System.runAs(bbUser) {
      //GIVEN a Opportunity record
      Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{
        '0069h000004rqUQAAY' => (new Opportunity(
          Id = '0069h000004rqUQAAY',
          OwnerId = bbUser.Id,
          recordTypeId = CCRMConstants.CCRM_OPP_RT_ID
        ))
      };

      //WHEN update the OwnerId field on opportunity
      List<Opportunity> oppList = new List<Opportunity>{
        new Opportunity(
          Id = '0069h000004rqUQAAY',
          OwnerId = sbbUser.Id,
          recordTypeId = CCRMConstants.CCRM_OPP_RT_ID
        )
      };
      Test.startTest();
      userMap = CCRMOpportunityActions.getOwnerCommercialSegment(
        oppList,
        oldOppMap
      );
      Test.stopTest();

      //THEN check if update the actual OwnerId field is updated
      System.assertEquals(
        2,
        userMap.size(),
        'Not able to get the Commercial segment of user'
      );
    }
  }

  @isTest
  static void getFilteredCCRMOppsTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;

    System.runAs(ccrmBaseUser) {
      Map<Id, Opportunity> oldOppMap;
      List<Opportunity> oppList;
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;

      Test.startTest();

      oldOppMap = new Map<Id, Opportunity>{
        '0069h000004rqUQAAY' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          'Opportunity Identified'
        ),
        '0069h00000ATaQYAA1' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.CUST_ACCEPT
        )
      };

      oppList = new List<Opportunity>{
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        ),
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.OPP_WON
        )
      };

      oppWrapper = CCRMOpportunityActions.getFilteredCCRMOpps(
        oppList,
        oldOppMap,
        true
      );
      Test.stopTest();
      System.assertEquals(2, oppWrapper.filteredOpps.size(), 'Size is not 2');
    }
  }

  @isTest
  static void getStageSegmentOrTemplateMapTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    System.runAs(ccrmBaseUser) {
      Map<Id, Opportunity> oldOppMap;
      List<Opportunity> oppList;
      Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping;
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;

      Test.startTest();
      oldOppMap = new Map<Id, Opportunity>{
        '0069h000004rqUQAAY' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          'Opportunity Identified'
        ),
        '0069h00000ATaQYAA1' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        )
      };

      oppList = new List<Opportunity>{
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        ),
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.SOL_DEV
        )
      };
      stageActionPlanMapping = new Map<String, CCRM_Commercial_Stage_Action_Plan__mdt>{
        'Needs Analysis-BB' => new CCRM_Commercial_Stage_Action_Plan__mdt(
          Current_Stage__c = CCRMConstants.NEED_ANALYSIS,
          Previous_Stage__c = 'Opportunity Identified',
          Template_Name__c = CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP,
          Next_Stage__c = CCRMConstants.SOL_DEV
        )
      };

      oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();
      oppWrapper.stageUpdatedOpps = new Map<Id, Opportunity>(oppList);
      oppWrapper.oppOwnerIdToSegmentMap = new Map<Id, User>{
        '0059t000003l3OvAAI' => ccrmBaseUser
      };
      oppWrapper.oppIdToOwnerIdMap = new Map<Id, String>{
        '0069h000004rqUQAAY' => '0059t000003l3OvAAI',
        '0069h00000ATaQYAA1' => '0059t000003l3OvAAI'
      };

      CCRMOpportunityActions.getStageSegmentOrTemplateMap(
        oppWrapper,
        oldOppMap,
        stageActionPlanMapping
      );
      Test.stopTest();
      System.assertEquals(
        1,
        oppWrapper.oppIdToTemplateNameMap.keySet().size(),
        'Size is not 1'
      );
      System.assertEquals(
        1,
        oppWrapper.oppWithMandatoryTaskMap.keySet().size(),
        'Size is not 1'
      );
    }
  }

  @isTest
  static void getStageActionPlanMetadataTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> metadataRecord;

      Test.startTest();
      metadataRecord = CCRMOpportunityActions.getStageActionPlanMetadata(
        new List<Opportunity>{
          CCRMTestDataFactory.createStaticOpportunityData(
            '0069h000004rqUQAAY',
            'Test Opp',
            CCRMConstants.CCRM_OPP_RT_ID,
            CCRMConstants.NEED_ANALYSIS
          )
        }
      );
      Test.stopTest();
      System.assertEquals(21, metadataRecord.keySet().size(), 'Size is not 21');
    }
  }
}
