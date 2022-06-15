/**
 * @author Boobalakrishnan Duraisamy
 * @date Oct 2021
 * @description Test class for {@link IDRCollectionActions}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCollectionActionsTest {
  @TestSetup
  static void setup() {
    //create a product
    Product2 p = new Product2(
      Name = 'Home Loan Protection Insurance',
      IsActive = true,
      ANZ_Product_Code__c = '241',
      IDR_Product_or_Service_Category__c = '8',
      IDR_Product_or_Service_Line__c = '3',
      IDR_Product_or_Service_Type__c = '35'
    );
    insert p;
  }
  @isTest
  static void testStopCollectionOnInsert() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333;444444444;555555555;666666666;777777777;888888888;999999999;1234567890',
          Type = '4',
          IDR_Subsequent_Issue__c = '96',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '2134565778;283273273;4393483833;823748237;8423742374;672354763;273647234;678263478;463724622;234324324',
          IDR_Issue_Type_2__c = '17',
          IDR_Subsequent_Issue_2__c = '97',
          IDR_Product_2__c = p.Id,
          IDR_Third_Issue__c = true,
          IDR_Account_Card_Policy_Number_3__c = '132342343;534764565;645656456;678765665;3422323423;645676556;896875567;432241244;565423545;432431211',
          IDR_Issue_Type_3__c = '17',
          IDR_Subsequent_Issue_3__c = '98',
          IDR_Product_3__c = p.Id
        )
      );
    }

    Test.startTest();
    // WHEN they are inserted
    insert collectionCases;
    Test.stopTest();

    // THEN STOP collection tasks must be created for each account number
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE WhatId = :collectionCases[0].id AND Subject LIKE 'STOP Collection%'
    ];
    System.assertEquals(
      30,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @isTest
  static void testStopCollectionOnUpdate() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '444444444;5555555555;6666666666',
          IDR_Issue_Type_2__c = '4',
          IDR_Subsequent_Issue_2__c = '21',
          IDR_Product_2__c = p.Id
        )
      );
    }
    insert collectionCases;

    Test.startTest();
    // WHEN the case is updated to add third issue with collection issue type
    collectionCases[0].IDR_Third_Issue__c = true;
    collectionCases[0]
      .IDR_Account_Card_Policy_Number_3__c = '7777777777;8888888888;9999999999';
    collectionCases[0].IDR_Issue_Type_3__c = '4';
    collectionCases[0].IDR_Subsequent_Issue_3__c = '23';
    collectionCases[0].IDR_Product_3__c = p.Id;
    update collectionCases[0];

    Test.stopTest();

    // THEN STOP collection tasks must be created for each account number added during update
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE WhatId = :collectionCases[0].id AND Subject LIKE 'STOP Collection%'
    ];
    System.assertEquals(
      9,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @isTest
  static void testStartCollectionScenarioOne() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '444444444;5555555555;6666666666',
          IDR_Issue_Type_2__c = '4',
          IDR_Subsequent_Issue_2__c = '21',
          IDR_Product_2__c = p.Id
        )
      );
    }
    insert collectionCases;

    Test.startTest();
    // WHEN one case is closed and another one is open with same account numbers
    collectionCases[0].Status = 'Withdrawn';
    update collectionCases[0];

    Test.stopTest();

    // THEN START collection tasks must not be created as there is an open complaint present for these account numbers
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE WhatId = :collectionCases[0].id AND Subject LIKE 'START Collection%'
    ];
    System.assertEquals(
      0,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @isTest
  static void testStartCollectionScenarioTwo() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '444444444;5555555555;6666666666',
          IDR_Issue_Type_2__c = '4',
          IDR_Subsequent_Issue_2__c = '21',
          IDR_Product_2__c = p.Id
        )
      );
    }
    insert collectionCases;

    Test.startTest();
    // WHEN they are closed
    collectionCases[0].Status = 'Withdrawn';
    update collectionCases[0];
    collectionCases[1].Status = 'Withdrawn';
    update collectionCases[1];

    Test.stopTest();

    // THEN START collection tasks must be created if there is no open complaint present for these account numbers
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE Subject LIKE 'START Collection%'
    ];
    System.assertEquals(
      6,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @isTest
  static void testClosedOnCreate() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers closed on create
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Withdrawn',
          Product__c = p.Id
        )
      );
    }

    Test.startTest();
    // WHEN they are inserted
    insert collectionCases;
    Test.stopTest();

    // THEN STOP AND START collection tasks must created
    List<Task> collectionTasks = [
      SELECT Id, Type
      FROM Task
      WHERE Subject LIKE '%Collection%'
    ];
    // THEN Add AND Remove Complaints tasks must created
    List<Task> complaintTasks = [
      SELECT Id, Type
      FROM Task
      WHERE Subject LIKE '%Complaint%'
    ];
    System.assertEquals(
      6,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
    System.assertEquals(
      4,
      complaintTasks.size(),
      'Complaint tasks size should be as expected.'
    );
    System.assertEquals(
      IDRConstants.TASK_TYPE_COLLECTION,
      collectionTasks[0].Type,
      'Collection task type should be as expected.'
    );
    System.assertEquals(
      IDRConstants.TASK_TYPE_COMPLIANTS_FLAG,
      complaintTasks[0].Type,
      'Complaint task type should be as expected.'
    );
  }

  @isTest
  static void testAccountNumberNA() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and account number selected as N/A
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = 'N/A',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Withdrawn',
          Product__c = p.Id
        )
      );
    }

    Test.startTest();
    // WHEN they are inserted
    insert collectionCases;
    Test.stopTest();

    // THEN STOP AND START collection tasks will not get created
    List<Task> collectionTasks = [
      SELECT Id, Type
      FROM Task
      WHERE Subject LIKE '%Collection%'
    ];
    System.assertEquals(
      0,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }
}
