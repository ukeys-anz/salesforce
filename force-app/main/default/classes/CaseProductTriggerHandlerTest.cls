@isTest
public with sharing class CaseProductTriggerHandlerTest {
  @isTest
  static void testCreateUpdateCaseProducts() {
    //GIVEN Case and Product records
    Case[] cases = new List<Case>();
    Product2[] products = new List<Product2>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      cases.add(new Case(RecordTypeId = IDRConstants.SI_RT_ID));
      products.add(
        new Product2(
          Name = 'Test Product ' + i,
          RecordTypeId = IDRConstants.ANZ_PRODUCT_RT_ID,
          isActive = true
        )
      );
    }
    insert cases;
    insert products;

    //WHEN I relate them
    Case_Product__c[] cps = new List<Case_Product__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      cps.add(
        new Case_Product__c(Case__c = cases[i].Id, Product__c = products[i].Id)
      );
    }
    insert cps;

    //THEN it works
    Integer insertions = [SELECT COUNT() FROM Case_Product__c];
    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      insertions,
      'All record should have been inserted.'
    );

    //WHEN I update one
    Case_Product__c cp = [
      SELECT Case__c, Product__c
      FROM Case_Product__c
      WHERE Id = :cps[0].Id
      WITH SECURITY_ENFORCED
    ];
    cp.Product__c = products[1].Id;

    //THEN it worked
    Boolean exceptionThrown = false;
    String errorMessage = '';
    try {
      update cp;
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
      System.assert(false, 'Failed to update the record');
    }
    System.assertEquals(
      false,
      exceptionThrown,
      'An exception should not have been thrown on updating the record.|\n' +
      errorMessage
    );
  }
  @isTest
  static void testErrorIfAlreadyExists() {
    //GIVEN a case and a product, related to each other
    Case c = new Case(RecordTypeId = IDRConstants.SI_RT_ID);
    insert c;
    Product2 p = new Product2(
      Name = 'Test Product',
      RecordTypeId = IDRConstants.ANZ_PRODUCT_RT_ID,
      isActive = true
    );
    insert p;
    Case_Product__c cp = new Case_Product__c(Case__c = c.Id, Product__c = p.Id);
    insert cp;

    //WHEN I try to relate them again
    Case_Product__c[] cps = new List<Case_Product__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      cps.add(new Case_Product__c(Case__c = c.Id, Product__c = p.Id));
    }

    //THEN I get a duplicate error
    Boolean exceptionThrown = false;
    try {
      insert cps;
      System.assert(
        false,
        'Failed to prevent duplicating product relation to case'
      );
    } catch (Exception e) {
      exceptionThrown = true;
      Boolean expectedExceptionThrown = (e.getMessage()
          .contains('Product has already been related to case.'))
        ? true
        : false;
      System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
    }
    System.assertEquals(
      true,
      exceptionThrown,
      'An exception should have been thrown on inserting duplicate records'
    );
  }

  @isTest
  static void testErrorIfDuplicateInBulk() {
    //GIVEN a case and a product, NOT related
    Case c = new Case(RecordTypeId = IDRConstants.SI_RT_ID);
    insert c;
    Product2 p = new Product2(
      Name = 'Test Product',
      RecordTypeId = IDRConstants.ANZ_PRODUCT_RT_ID,
      isActive = true
    );
    insert p;

    //WHEN I try to relate them more than once
    Case_Product__c[] cps = new List<Case_Product__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      cps.add(new Case_Product__c(Case__c = c.Id, Product__c = p.Id));
    }

    //THEN I get a duplicate error
    Boolean exceptionThrown = false;
    try {
      insert cps;
      System.assert(
        false,
        'Failed to prevent duplicating product relation to the same case'
      );
    } catch (Exception e) {
      exceptionThrown = true;
      Boolean expectedExceptionThrown = (e.getMessage()
          .contains(
            'Trying to relate the same product to the same case more than once.'
          ))
        ? true
        : false;
      System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
    }
    System.assertEquals(
      true,
      exceptionThrown,
      'An exception should have been thrown on inserting duplicate records'
    );
  }

  @isTest
  static void testInsufficientPermission() {
    //GIVEN a case, a product, and a current user who doesn't have enough CRUD access
    Case c = new Case(RecordTypeId = IDRConstants.SI_RT_ID);
    insert c;
    Product2 p = new Product2(
      Name = 'Test Product',
      RecordTypeId = IDRConstants.ANZ_PRODUCT_RT_ID,
      isActive = true
    );
    insert p;
    Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    User u = new User(
      Alias = 'stduser',
      Email = 'standard.user@anz.com',
      LastName = 'Testing',
      ProfileId = prof.Id,
      UserName = 'standard.user@anztest.com',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8'
    );
    insert u;

    //WHEN he or she tries to relate them
    Test.startTest();
    Boolean exceptionThrown = false;
    System.runAs(u) {
      Case_Product__c[] cps = new List<Case_Product__c>();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        cps.add(new Case_Product__c(Case__c = c.Id, Product__c = p.Id));
      }
      try {
        insert cps;
        System.assert(
          false,
          'Failed to prevent creation of new case product when user has insufficient permissions'
        );
      } catch (Exception e) {
        //THEN he or she will get an insufficient permission error
        exceptionThrown = true;
        Boolean expectedExceptionThrown = (e.getMessage()
            .contains('Insufficient permissions'))
          ? true
          : false;
        System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
      }
      System.assertEquals(
        true,
        exceptionThrown,
        'An exception should have been thrown because current user has insufficient permissions'
      );
    }
    Test.stopTest();
  }
}
