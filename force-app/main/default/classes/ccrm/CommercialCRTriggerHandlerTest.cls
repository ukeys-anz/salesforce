/**
 * @author       : Naman Garg
 * @since        : July 2025
 * @description  : This is test class for CommercialCRTriggerHandler
 **/
@isTest
public class CommercialCRTriggerHandlerTest {
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void beforeInsertTest() {
    //GIVEN records
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Notes__c = 'TAX Number 1234567890',
        Other_Account_Plan_Information__c = 'Credit Card Number 12345678901234',
        Additional_Details__c = 'FILE Number 987654321',
        Customer_Areas_of_Interest__c = 'TFN Number 0134024094209'
      )
    };
    CommercialCRTriggerHandler handler = new CommercialCRTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should throw an error
    Assert.areEqual(
      'TAX Number ******7890',
      records[0].Notes__c,
      'should redact Notes field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Other_Account_Plan_Information__c,
      'should redact Account Plan field on insertion'
    );
    Assert.areEqual(
      'FILE Number *****4321',
      records[0].Additional_Details__c,
      'should redact Customer Bio field on insertion'
    );
    Assert.areEqual(
      'TFN Number *********4209',
      records[0].Customer_Areas_of_Interest__c,
      'should redact Executive summary field on insertion'
    );
  }

  @isTest
  static void beforeInsertErrorTest() {
    //GIVEN records
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Other_Account_Plan_Information__c = '<img>Google.com</img>'
      )
    };
    CommercialCRTriggerHandler handler = new CommercialCRTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should throw an error
    Assert.isTrue(
      records[0].hasErrors(),
      'should throw error while inserting record with Image in Account Plan field'
    );
  }

  @isTest
  static void beforeUpdateTest() {
    Boolean exceptionThrow = false;
    Id crId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );
    //GIVEN records, oldMap
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = crId,
        Notes__c = 'TAX Number 1234567890',
        Other_Account_Plan_Information__c = 'Credit Card Number 12345678901234',
        Additional_Details__c = 'FILE Number 987654321',
        Customer_Areas_of_Interest__c = 'TFN Number 0134024094209'
      )
    };

    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      crId => new Customer_Relationship__c(
        Notes__c = 'Sample Notes',
        Other_Account_Plan_Information__c = 'Sample Account Plan',
        Additional_Details__c = 'Sample Customer Bio',
        Customer_Areas_of_Interest__c = 'Sample Executive Summary'
      )
    };
    CommercialCRTriggerHandler handler = new CommercialCRTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //Assert is should redact properly
    Assert.areEqual(
      'TAX Number ******7890',
      records[0].Notes__c,
      'should redact Notes field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Other_Account_Plan_Information__c,
      'should redact Account Plan field on insertion'
    );
    Assert.areEqual(
      'FILE Number *****4321',
      records[0].Additional_Details__c,
      'should redact Customer Bio field on insertion'
    );
    Assert.areEqual(
      'TFN Number *********4209',
      records[0].Customer_Areas_of_Interest__c,
      'should redact Executive summary field on insertion'
    );
  }

  @isTest
  static void beforeUpdateErrorTest() {
    Id crId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );
    //GIVEN records, oldMap
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = crId,
        Other_Account_Plan_Information__c = '<img>Google.com</img>'
      )
    };

    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      crId => new Customer_Relationship__c(
        Other_Account_Plan_Information__c = 'Sample Account Plan'
      )
    };

    CommercialCRTriggerHandler handler = new CommercialCRTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //Assert is should throw an error
    Assert.isTrue(
      records[0].hasErrors(),
      'should throw error while updating record with Image in Other Account Plan Information field'
    );
  }

  @isTest
  static void afterUpdateTest() {
    registerMocks();
    Boolean exceptionThrow = false;
    Id crId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );
    //GIVEN records, oldMap
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(Id = crId, Status__c = 'Inactive')
    };
    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      crId => new Customer_Relationship__c(Status__c = 'Active')
    };

    CommercialCRTriggerHandler handler = new CommercialCRTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onAfterUpdate(oldMap);
    Test.stopTest();

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );

    List<Interaction> insertedRecords = (List<Interaction>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    //THEN it should create interaction record
    Assert.isNotNull(insertedRecords[0], 'New interaction should be created');
  }
}
