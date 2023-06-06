/**
 * @author Olivier Saier
 * @date May 2021
 * @description Test class for {@link IDRCaseAssignmentRules} assignment rule test
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
private with sharing class IDRCaseAssignmentRulesTest {
  @TestSetup
  static void makeData() {
    Schema.DescribeFieldResult productWorkbasketList = Product_Family__c.IDR_Workbasket__c.getDescribe();
    List<Schema.PicklistEntry> workbasketPicklistValues = productWorkbasketList.getPicklistValues();
    List<Product_Family__c> pfList = new List<Product_Family__c>();
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
          IsActive = true,
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

  @IsTest
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
          Type = '15',
          IDR_Subsequent_Issue__c = '9'
        )
      );
    }

    Test.startTest();
    insert cases;
    Test.stopTest();

    Map<Id, Group> queueNameById = new Map<Id, Group>(
      [
        SELECT Id, DeveloperName
        FROM Group
        WHERE
          DeveloperName IN :IDRConstants.workBasketNames
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
    for (Case c : cases) {
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
  @IsTest
  static void testNonProductAssignmentRulesOnUpdate() {
    //GIVEN open complaints
    Case[] cases = new List<Case>();
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Priority = 'Customer in Collections',
        Type = '4',
        Description = 'IDR_Hardship'
      )
    );
    cases.add(
      new Case(
        RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
        Priority = 'Financial Hardship',
        Type = '17',
        Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
        Description = 'EDR_Hardship'
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
    Map<Id, Group> queueNameById = new Map<Id, Group>(
      [
        SELECT Id, DeveloperName
        FROM Group
        WHERE
          DeveloperName IN :IDRConstants.workBasketNames
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

  /**
   * @description : This is to test if Product Family is assigned to escalated ANZ Plus Complaint to Customer Complaint.
   */
  @IsTest
  private static void anzPlusComplaintProductAssignment() {
    // GIVEN
    // ANZ Plus Complaint Case with a product (that has a product family) assigned.
    Product_Family__c testProductFamily = new Product_Family__c(
      IDR_ANZ_com_Product_Category__c = 'Home loans',
      IDR_Workbasket__c = 'IDR_Home_Owners'
    );
    insert testProductFamily;

    Product2 testProduct = new Product2(
      Name = 'ANZ Plus - Fixed Home Loan',
      IDR_Product_Family__c = testProductFamily.Id
    );
    insert testProduct;

    Id mockId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()); //Prep Id for assignProductFamily' parameters
    Case oldCase = new Case(
      Id = mockId,
      RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID,
      Product__c = testProduct.Id
    );
    Map<Id, Case> oldMap = new Map<Id, Case>{ oldCase.Id => oldCase };

    List<Case> newCases = new List<Case>();
    newCases.add(
      new Case(
        Id = mockId,
        RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
        Product__c = testProduct.Id,
        Status = 'Escalated',
        IDR_Escalated_to__c = '1',
        IDR_Escalation_Reason__c = 'MANUAL_ESCALATION_REASON'
      )
    );

    // WHEN
    // assignProductFamily is invoked for a case that was escalated from ANZ Plus Complaint to Customer Complaint
    Test.startTest();
    IDRCaseAssignmentRules.assignProductFamily(newCases, oldMap);
    Test.stopTest();

    //THEN
    //Check if newCase (ANZ Plus Complaint Case) has product family and product category assigned
    System.assertEquals(
      testProductFamily.Id,
      newCases[0].IDR_Product_Family__c,
      'Product Families should match'
    );
    System.assertEquals(
      'Home loans',
      newCases[0].IDR_Product_Category__c,
      'Product Category should be Home loans'
    );
  }
}
