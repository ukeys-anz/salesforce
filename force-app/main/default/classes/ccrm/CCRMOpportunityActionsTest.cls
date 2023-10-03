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
    opp = [
      SELECT Id, Name, Opp_Id__c, Customer_Needs__c, Amount
      FROM Opportunity
      WHERE id = :opp.id
    ];
    System.assertEquals(
      opp.Opp_Id__c +
      ' ' +
      opp.Customer_Needs__c,
      opp.Name,
      'Opportunity Name is the same for Manual Opportunity.'
    );
  }

  @istest
  static void testOppStage() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'Stage can only be set to Opportunity Identified.';
    String actualMsg = '';
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      try {
        Account accnt = CCRMTestDataFactory.createPersonAccount();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID;
        opp.Name = 'Test Opportunity';
        opp.AccountId = accnt.id;
        opp.StageName = 'Customer Acceptance';
        opp.Amount = 200;
        opp.CloseDate = System.today() + 15;
        insert opp;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(expMsg, actualMsg, 'Opp updated successfully');
    }
  }

  @istest
  static void testSkipStageCheck() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'Unfortunately, you are not allowed to skip or re-open closed stages.';
    String actualMsg = '';
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      try {
        oppList[0].StageName = 'Customer Acceptance';
        update oppList[0];
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Opp Stage updated successfully to Customer Acceptance'
      );
    }
  }

  @istest
  static void testMandatoryFields() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'BBD Application Number & CLP Credit Case Number is mandatory to proceed to Approved and offered.';
    String actualMsg = '';
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      try {
        oppList[0].StageName = 'Needs Analysis';
        update oppList[0];
        oppList[0].StageName = 'Solution Development';
        update oppList[0];
        oppList[0].StageName = 'Approved & Offered';
        update oppList[0];
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Opp Stage updated successfully to Approved & offered'
      );
    }
  }

  @istest
  static void testLostReason() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'Please select a valid Lost Reason.';
    String actualMsg = '';
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      try {
        oppList[0].StageName = 'Needs Analysis';
        update oppList[0];
        oppList[0].StageName = 'Solution Development';
        oppList[0].BBD_Application_Number__c = '1234';
        oppList[0].CLP_Credit_Case_Number__c = '1234';
        update oppList[0];
        oppList[0].StageName = 'Approved & Offered';
        update oppList[0];
        oppList[0].StageName = 'Customer Acceptance';
        oppList[0].Won_from_Lost_to__c = 'AAMI';
        update oppList[0];
        oppList[0].StageName = 'Opportunity Lost';
        update oppList[0];
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Opp Stage updated successfully to Approved & offered'
      );
    }
  }

  @istest
  static void testWonLost() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    String expMsg = 'Won From/Lost To is mandatory to Proceed to Opportunity Won/Lost.';
    String actualMsg = '';
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      try {
        oppList[0].StageName = 'Needs Analysis';
        update oppList[0];
        oppList[0].StageName = 'Solution Development';
        oppList[0].BBD_Application_Number__c = '1234';
        oppList[0].CLP_Credit_Case_Number__c = '1234';
        update oppList[0];
        oppList[0].StageName = 'Approved & Offered';
        update oppList[0];
        oppList[0].StageName = 'Customer Acceptance';
        update oppList[0];
        oppList[0].StageName = 'Opportunity Won';
        update oppList[0];
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Opp Stage updated successfully to Opportunity Closed / Opportunity Won'
      );
    }
  }

  @istest
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
        opp.Opp_Id__c +
        ' ' +
        opp.Customer_Needs__c,
        opp.Name,
        'Opportunity Name not updated'
      );
    }
  }

  @istest
  static void testInsertActionPlan() {
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
    List<Task> taskList = new List<Task>();
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
}
