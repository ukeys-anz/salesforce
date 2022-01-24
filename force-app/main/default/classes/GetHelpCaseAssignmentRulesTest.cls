/**
 * @author Lance Shi
 * @date December 2021
 * @description Test class for {@link GetHelpCaseAssignmentRules} assignment rule test
 * @group ANZx
 */
@isTest
private with sharing class GetHelpCaseAssignmentRulesTest {
  /**
   * @description : This is to test for ATM/Card/NPP dispute types, when in unauthorised transaction situation
   * case is assigned correctly
   */
  @isTest
  static void testInsertUnauthorisedCases() {
    List<Id> disputeCaseTypes = new List<Id>{
      GetHelpConstants.ATM_DISPUTE_RT_ID,
      GetHelpConstants.CARD_DISPUTE_RT_ID,
      GetHelpConstants.NPP_DISPUTE_RT_ID
    };
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Submitted',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = 'test1234',
          Card_In_Possession_During_Transaction__c = 'No',
          Has_The_Card_Been_Stopped__c = 'No',
          Submitted__c = true,
          IDR_Escalation_Reason__c = '8',
          Origin = 'Phone',
          Priority = 'Standard',
          Description = 'Test',
          Type = '13',
          IDR_Subsequent_Issue__c = '9'
        )
      );
    }
    cases[1]
      .Dispute_Reason__c = GetHelpCaseAssignmentRules.DID_NOT_AUTHORISE_TRANSACTION;

    Test.startTest();
    insert cases;
    Test.stopTest();

    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :GetHelpConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.DIGITAL_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[2].Id).OwnerId).developerName
    );
  }

  /**
   * @description : This is to test for ATM/Card/NPP dispute types, when update in unauthorised transaction situation
   * case is assigned correctly
   */
  @isTest
  static void testUpdateUnauthorisedCases() {
    List<Id> disputeCaseTypes = new List<Id>{
      GetHelpConstants.ATM_DISPUTE_RT_ID,
      GetHelpConstants.CARD_DISPUTE_RT_ID,
      GetHelpConstants.NPP_DISPUTE_RT_ID
    };
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Open',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = 'test1234',
          Card_In_Possession_During_Transaction__c = 'No',
          Has_The_Card_Been_Stopped__c = 'No',
          IDR_Escalation_Reason__c = '8',
          Origin = 'Phone',
          Priority = 'Standard',
          Description = 'Test',
          Type = '13',
          IDR_Subsequent_Issue__c = '9'
        )
      );
    }
    cases[1]
      .Dispute_Reason__c = GetHelpCaseAssignmentRules.DID_NOT_AUTHORISE_TRANSACTION;

    Test.startTest();
    insert cases;

    for (Case c : cases) {
      c.Status = 'Submitted';
      c.Submitted__c = true;
    }
    update cases;
    Test.stopTest();

    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :GetHelpConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.DIGITAL_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[2].Id).OwnerId).developerName
    );
  }

  /**
   * @description : This is to test for ATM/Card/NPP dispute types, reassignment works when dispute reasons change
   * case is assigned correctly
   */
  @isTest
  static void testCasesReassignment() {
    List<Id> disputeCaseTypes = new List<Id>{
      GetHelpConstants.ATM_DISPUTE_RT_ID,
      GetHelpConstants.CARD_DISPUTE_RT_ID,
      GetHelpConstants.NPP_DISPUTE_RT_ID
    };
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Submitted',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = 'test1234',
          Card_In_Possession_During_Transaction__c = 'No',
          Has_The_Card_Been_Stopped__c = 'No',
          Submitted__c = true,
          IDR_Escalation_Reason__c = '8',
          Origin = 'Phone',
          Priority = 'Standard',
          Description = 'Test',
          Type = '13',
          IDR_Subsequent_Issue__c = '9',
          Received_Amount__c = 100,
          Amount_Of_Credit_Due__c = 20
        )
      );
    }
    cases[1]
      .Dispute_Reason__c = GetHelpCaseAssignmentRules.DID_NOT_AUTHORISE_TRANSACTION;

    Test.startTest();
    insert cases;
    cases[0].Dispute_Reason__c = 'Cash Dispensing Error';
    cases[1].Dispute_Reason__c = 'Charged Incorrect Amount';
    cases[2].Dispute_Reason__c = 'Incorrect Account Details';
    update cases;
    Test.stopTest();

    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :GetHelpConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_GENERAL_QUEUE,
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_GENERAL_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[2].Id).OwnerId).developerName
    );
  }

  /**
   * @description : This is to test for DD/DE dispute types
   * case is assigned correctly
   */
  @isTest
  static void testDirectDebitEntryCases() {
    List<Id> disputeCaseTypes = new List<Id>{
      GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID,
      GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID
    };
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Submitted',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = 'test1234',
          Card_In_Possession_During_Transaction__c = 'No',
          Has_The_Card_Been_Stopped__c = 'No',
          Submitted__c = true,
          IDR_Escalation_Reason__c = '8',
          Is_this_a_Business_Customer__c = 'No',
          Amount_Of_Authorised_Transaction__c = 20,
          Origin = 'Phone',
          Priority = 'Standard',
          Description = 'Test',
          Type = '13',
          IDR_Subsequent_Issue__c = '9'
        )
      );
    }
    cases[1].Dispute_Reason__c = 'Incorrect Amount';

    Test.startTest();
    insert cases;
    Test.stopTest();

    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :GetHelpConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName
    );
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName
    );
  }
}
