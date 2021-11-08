/**
 * @author Olivier Saier
 * @date May 2021
 * @description Test class for {@link IDRCaseAssignmentRules} assignment rule test
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCaseAssignmentRulesTest {
  @TestSetup
  static void makeData() {
    Case[] cases = new List<Case>();
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Priority = 'Customer in Collections',
        Description = 'IDR_Hardship'
      )
    ); 
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Priority = 'Financial Hardship',
        Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
        Description = 'Specialised_Early_Resolution_Hardship'
      )
    );
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Type = '5',
        IDR_Subsequent_Issue__c = '38',
        Description = 'IDR_Responsible_Lending'
      )
    );
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Type = '5',
        IDR_Subsequent_Issue__c = '38',
        Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
        Description = 'Specialised_EarlyRes_Responsible_Lending'
      )
    );
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Origin = '9',
        Description = 'IDR_CEO'
      )
    );
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Origin = '10',
        Description = 'IDR_CEO'
      )
    );
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Origin = 'Phone',
        Priority = 'Standard',
        Type = '1',
        IDR_Subsequent_Issue__c = '52',
        Description = 'IDR_Early_Resolution' //default workbasket
      )
    );
    insert cases;
  }

  @isTest
  static void testProductAssignmentRulesOnInsert() {
    //WHEN complaints are created as escalated
    Case[] cases = new List<Case>();
    Product2[] products = [SELECT Id FROM Product2];
    for (Product2 p : products) {
      cases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Product__c = p.Id,
          IsEscalated = true
        )
      );
    }
    insert cases;

    //THEN they're auto-assigned to workbaskets
    Case[] assignedCases = [
      SELECT Id
      FROM Case
      WHERE Owner.Type = :IDRCaseActions.QUEUE_TYPE
    ];
    System.assertEquals(
      cases.size(),
      assignedCases.size(),
      'All cases should have been assigned to a queue'
    );

    //assert one product per workbasket
    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :IDRConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    cases = [SELECT Id, Product__r.Name FROM Case];
    for (case c : cases) {
      if (c.Product__r.Name == 'ANZ Business Black Credit Card') {
        System.assertEquals(
          'IDR_Business_Owners',
          queueNameById.get(c.OwnerId).DeveloperName,
          'Case should be reassigned as per product-dependent assignment rules'
        );
      } else if (c.Product__r.Name == 'ANZ First Credit Card') {
        System.assertEquals(
          'IDR_Everyday_Banking',
          queueNameById.get(c.OwnerId).DeveloperName,
          'Case should be reassigned as per product-dependent assignment rules'
        );
      } else if (c.Product__r.Name == 'ANZ Breakfree Package') {
        System.assertEquals(
          'IDR_Home_Owners',
          queueNameById.get(c.OwnerId).DeveloperName,
          'Case should be reassigned as per product-dependent assignment rules'
        );
      } else if (c.Product__r.Name == 'Margin Lending') {
        System.assertEquals(
          'IDR_Wealth',
          queueNameById.get(c.OwnerId).DeveloperName,
          'Case should be reassigned as per product-dependent assignment rules'
        );
      }
    }
  }

  @isTest
  static void testNonProductAssignmentRulesOnUpdate() {
    //GIVEN open complaints
    Case[] cases = [
      SELECT Id, Status, IDR_Escalated_to__c, IDR_Escalation_Reason__c
      FROM Case
    ];

    Test.startTest();
    //WHEN escalated
    for (Case c : cases) {
      c.Status = 'Escalated';
      c.IDR_Escalated_to__c = '1';
      c.IDR_Escalation_Reason__c = '1';
    }
    update cases;
    Test.stopTest();
    //THEN they're auto-assigned to workbaskets
    cases = [SELECT OwnerId, Description FROM Case];
    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :IDRConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    for (Case c : cases) {
      System.assertEquals(
        c.Description,
        queueNameById.get(c.OwnerId).DeveloperName,
        'Case should have been reassigned to the appropriate queue'
      );
    }
  }
}
