/**
 * @author Lance Shi
 * @date December 2021
 * @description Test class for {@link GetHelpCaseAssignmentRules} assignment rule test
 * @group ANZx
 */
@isTest
public with sharing class GetHelpCaseAssignmentRulesTest {
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
    Faker faker = new Faker('AU');
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Submitted',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = faker.randomString(8),
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
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.DIGITAL_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[2].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
  }

  @isTest
  static void testAssignAEMToBOHQueueCases() {
    Faker faker = new Faker('AU');
    Case testCase = new Case(
      RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID,
      Status = GetHelpConstants.OPEN_STATUS,
      Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN,
      Priority = 'Standard',
      Description = 'Test',
      Type = '11',
      IDR_Product_Category__c = 'Home loans',
      ANZx_Customer__c = true
    );

    Test.startTest();
    insert testCase;
    Case c = [SELECT Id, OwnerId, Queue__c FROM Case WHERE Id = :testCase.Id];
    Test.stopTest();

    Group bohCoachQueue = CommonUtil.getQueueByName('BOH_Coach_Queue');
    System.assertEquals(
      c.OwnerId,
      bohCoachQueue.Id,
      'Should return the Id of expected queue.'
    );
    System.assertEquals(
      c.Queue__c,
      bohCoachQueue.Name,
      'Should return the Name of expected queue.'
    );
  }

  @isTest
  static void testAssignAEMToCoachQueueCases() {
    Faker faker = new Faker('AU');
    Case testCase = new Case(
      RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID,
      Status = GetHelpConstants.OPEN_STATUS,
      Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN,
      Priority = 'Standard',
      Description = 'Test',
      Type = '11',
      IDR_Product_Category__c = 'Not product related',
      ANZx_Customer__c = true
    );

    Test.startTest();
    insert testCase;
    Case c = [SELECT Id, OwnerId, Queue__c FROM Case WHERE Id = :testCase.Id];
    Test.stopTest();

    Group coachQueue = CommonUtil.getQueueByName('Coach_Queue');
    System.assertEquals(
      c.OwnerId,
      coachQueue.Id,
      'Should return the Id of expected queue.'
    );
    System.assertEquals(
      c.Queue__c,
      coachQueue.Name,
      'Should return the Name of expected queue.'
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
    Faker faker = new Faker('AU');
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Open',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = faker.randomString(8),
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
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.DIGITAL_FRAUD_QUEUE,
      queueNameById.get(caseMap.get(cases[2].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
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
      GetHelpConstants.NPP_DISPUTE_RT_ID,
      GetHelpConstants.ATM_DISPUTE_RT_ID,
      GetHelpConstants.ATM_DISPUTE_RT_ID
    };
    Faker faker = new Faker('AU');
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Submitted',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = faker.randomString(8),
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
    cases[3].Dispute_Reason__c = 'Cash Deposit Error';
    cases[4].Dispute_Reason__c = 'Cheque Deposit Error';
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
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.CARD_DISPUTE_GENERAL_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[2].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[3].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[4].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
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
    Faker faker = new Faker('AU');
    Case[] cases = new List<Case>();
    for (Id rtId : disputeCaseTypes) {
      cases.add(
        new Case(
          RecordTypeId = rtId,
          Status = 'Submitted',
          Dispute_Reason__c = GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION,
          External_System__c = 'Pega_Smarts',
          External_Case_ID__c = faker.randomString(8),
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
      queueNameById.get(caseMap.get(cases[0].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    System.assertEquals(
      GetHelpConstants.SUPPORT_COACH_QUEUE,
      queueNameById.get(caseMap.get(cases[1].Id).OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
  }

  /**
   * @description : This is to test for Card dispute type for pending queues
   * case is assigned correctly
   */
  @isTest
  static void testPendingCardCases() {
    Faker faker = new Faker('AU');
    Case c = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Dispute_Reason__c = GetHelpCaseAssignmentRules.DID_NOT_AUTHORISE_TRANSACTION,
      External_System__c = 'Pega_Smarts',
      External_Case_ID__c = faker.randomString(8),
      Card_In_Possession_During_Transaction__c = 'No',
      Has_The_Card_Been_Stopped__c = 'No',
      Date_Posted__c = date.newInstance(1970, 1, 1),
      IDR_Escalation_Reason__c = '8',
      Is_this_a_Business_Customer__c = 'No',
      Amount_Of_Authorised_Transaction__c = 20,
      Origin = 'App',
      Priority = 'Standard',
      Description = 'Test',
      Type = '13',
      IDR_Subsequent_Issue__c = '9'
    );

    Test.startTest();
    insert c;
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
    c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
    System.assertEquals(
      GetHelpConstants.PENDING_CARD_DISPUTE_FRAUD_QUEUE,
      queueNameById.get(c.OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
    c.Dispute_Reason__c = 'Charged Incorrect Amount';
    update c;
    c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
    System.assertEquals(
      GetHelpConstants.PENDING_CARD_DISPUTE_GENERAL_QUEUE,
      queueNameById.get(c.OwnerId).developerName,
      'Should return the developer name of expected queue.'
    );
  }

  /**
   * @description : This is to test validation rule is working when case is in pending status
   * case cannot be submitted
   */
  @isTest
  static void testSubmitPendingCaseValidation() {
    Faker faker = new Faker('AU');
    Case c = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Dispute_Reason__c = GetHelpCaseAssignmentRules.DID_NOT_AUTHORISE_TRANSACTION,
      External_System__c = 'Pega_Smarts',
      External_Case_ID__c = faker.randomString(8),
      Card_In_Possession_During_Transaction__c = 'No',
      Has_The_Card_Been_Stopped__c = 'No',
      Date_Posted__c = date.newInstance(1970, 1, 1),
      IDR_Escalation_Reason__c = '8',
      Is_this_a_Business_Customer__c = 'No',
      Amount_Of_Authorised_Transaction__c = 20,
      Origin = 'App',
      Priority = 'Standard',
      Description = 'Test',
      Type = '13',
      IDR_Subsequent_Issue__c = '9'
    );

    Test.startTest();
    insert c;
    Test.stopTest();

    c.Submitted__c = true;
    String expMsg = '';
    try {
      update c;
      System.assert(
        false,
        'Failed to prevent against user submitting dispute case when the transaction stauts is pending or Date posted is not valid'
      );
    } catch (Exception e) {
      expMsg = e.getMessage();
    }
    String validationMsg = 'Card dispute case cannot be submitted when the transaction status is pending or Date posted is not Valid';
    System.assert(
      expMsg.contains(validationMsg),
      'The message should be as expected.'
    );
  }
}
