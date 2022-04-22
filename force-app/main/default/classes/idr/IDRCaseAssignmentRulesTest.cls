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
    Schema.DescribeFieldResult productWorkbasketList = Product_Family__c.IDR_Workbasket__c.getDescribe();
    List<Schema.PicklistEntry> workbasketPicklistValues = productWorkbasketList.getPicklistValues();
    list<Product_Family__c> pfList = new List<Product_Family__c>();
    Integer productNumber = 1;
    for (Schema.PicklistEntry workbasket : workbasketPicklistValues) {
      pfList.add(
        new Product_Family__c(
          Name = 'Product Family' + productNumber,
          IDR_Workbasket__c = workbasket.getValue()
        )
      );
      productNumber++;
    }
    insert pfList;

    List<Product2> products = new List<Product2>();
    productNumber = 1;

    for (Product_Family__c pf : pfList) {
      products.add(
        new Product2(
          Name = 'Test Product ' + productNumber,
          RecordTypeId = IDRConstants.ANZ_PRODUCT_RT_ID,
          isActive = true,
          IDR_Product_Family__c = pf.Id
        )
      );
      productNumber++;
    }

    insert products;
  }

  /**
   * @description : This is to test if cases are being assigned to the Products queue defined on the product record
   */

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
          Status = 'Escalated',
          IDR_Escalation_Reason__c = '8',
          Origin = 'Phone',
          Priority = 'Standard',
          Type = '13',
          IDR_Subsequent_Issue__c = '9'
        )
      );
    }

    Test.startTest();
    insert cases;
    Test.stopTest();

    Map<ID, Group> queueNameById = new Map<ID, Group>(
      [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :IDRConstants.workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ]
    );
    cases = [
      SELECT
        Id,
        Product__r.IDR_Product_Family__c,
        IDR_Product_Family__c,
        IDR_Product_Family__r.IDR_Workbasket__c,
        Owner.Name
      FROM Case
    ];
    for (case c : cases) {
      System.assertEquals(
        c.Product__r.IDR_Product_Family__c,
        c.IDR_Product_Family__c,
        'Case Product Family Should align with selected product'
      );
      System.assertEquals(
        c.IDR_Product_Family__r.IDR_Workbasket__c,
        queueNameById.get(c.OwnerId).DeveloperName,
        'Case Should be assigned to the workbasket defined for the Product'
      );
    }
  }

  /**
   * @description : This is to test if cases are being assigned to the queues based on Priority, Subsequent Issue Type and Channel Recieved.
   */
  @isTest
  static void testNonProductAssignmentRulesOnUpdate() {
    //GIVEN open complaints
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
        Type = '19',
        Description = 'CCR_Complaints'
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
