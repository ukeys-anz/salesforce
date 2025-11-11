/**
 * @author       : Mildeep Singh
 * @since        : Sept 2025
 * @description  : This is the handler class for CommercialNeedsAnalysisTriggerHandler
 **/
@isTest
public with sharing class CommercialNeedsAnalysisTriggHandlerTest {
  static Lib_MockProvider needsAnalysisRepoMock;

  static void registerMocks() {
    needsAnalysisRepoMock = Lib_MockProvider.forType(
      CommercialNeedsAnalysisRepository.class
    );
  }

  @isTest
  static void isValidRecordTest() {
    // GIVEN Needs_Analysis__c Record
    Needs_Analysis__c record = new Needs_Analysis__c(
      Id = Lib_FakeIdGenerator.getMockId(Needs_Analysis__c.SObjectType),
      RecordTypeId = RTNeedsAnalysis.transactionalBankingNeedsAnalysis
    );
    CommercialNeedsAnalysisTriggerHandler handler = new CommercialNeedsAnalysisTriggerHandler();

    // WHEN calling isValidRecord
    Test.startTest();
    Boolean isNeedsAnalysisRecord = handler.isValidRecord(record);
    Test.stopTest();

    // THEN it should return true value
    Assert.isTrue(
      isNeedsAnalysisRecord,
      'Record is not a valid Needs Analysis Record'
    );
  }

  @isTest
  static void beforeInsertTest() {
    registerMocks();
    //GIVEN records
    Id accRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Opportunity> oppRecord = new List<Opportunity>{
      new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
        Name = 'Sample Opportunity',
        AccountId = accRecordId
      )
    };
    List<Needs_Analysis__c> naRecords = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(
        Id = Lib_FakeIdGenerator.getMockId(Needs_Analysis__c.SObjectType),
        RecordTypeId = RTNeedsAnalysis.transactionalBankingNeedsAnalysis,
        Opportunity__c = oppRecord[0].Id
      )
    };
    needsAnalysisRepoMock.mock('getCustomerRecordUsingOpportunity', oppRecord);

    CommercialNeedsAnalysisTriggerHandler handler = new CommercialNeedsAnalysisTriggerHandler();
    handler.records = naRecords;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should not throw an error
    Assert.isNotNull(
      naRecords[0].Customer__c,
      'Record should be inserted successfully'
    );
  }

  @isTest
  static void beforeInsertRedactionTest() {
    //GIVEN records
    List<Needs_Analysis__c> records = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(
        Money_Held__c = 'TAX Number 1234567890',
        Overview__c = 'Credit Card Number 12345678901234',
        Money_Out__c = 'FILE Number 987654321',
        Money_In__c = 'TFN Number 0134024094209',
        Payables__c = 'Credit Card Number 12345678901234',
        Receivables__c = 'Credit Card Number 12345678901234'
      )
    };
    CommercialNeedsAnalysisTriggerHandler handler = new CommercialNeedsAnalysisTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should throw an error
    Assert.areEqual(
      'TAX Number ******7890',
      records[0].Money_Held__c,
      'should redact Notes field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Overview__c,
      'should redact Account Plan field on insertion'
    );
    Assert.areEqual(
      'FILE Number *****4321',
      records[0].Money_Out__c,
      'should redact Customer Bio field on insertion'
    );
    Assert.areEqual(
      'TFN Number *********4209',
      records[0].Money_In__c,
      'should redact Executive summary field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Payables__c,
      'should redact Account Plan field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Receivables__c,
      'should redact Account Plan field on insertion'
    );
  }

  @isTest
  static void beforeUpdateRedactionTest() {
    Boolean exceptionThrow = false;
    Id crId = Lib_FakeIdGenerator.getMockId(Needs_Analysis__c.SObjectType);
    //GIVEN records, oldMap
    List<Needs_Analysis__c> records = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(
        Id = crId,
        Money_Held__c = 'TAX Number 1234567890',
        Overview__c = 'Credit Card Number 12345678901234',
        Money_Out__c = 'FILE Number 987654321',
        Money_In__c = 'TFN Number 0134024094209',
        Payables__c = 'Credit Card Number 12345678901234',
        Receivables__c = 'Credit Card Number 12345678901234'
      )
    };

    Map<Id, Needs_Analysis__c> oldMap = new Map<Id, Needs_Analysis__c>{
      crId => new Needs_Analysis__c(
        Money_Held__c = 'Sample Notes',
        Overview__c = 'Sample Account Plan',
        Money_Out__c = 'Sample Customer Bio',
        Money_In__c = 'Sample Executive Summary',
        Payables__c = 'Sample Executive Summary',
        Receivables__c = 'Sample Executive Summary'
      )
    };
    CommercialNeedsAnalysisTriggerHandler handler = new CommercialNeedsAnalysisTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //Assert is should redact properly
    Assert.areEqual(
      'TAX Number ******7890',
      records[0].Money_Held__c,
      'should redact Notes field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Overview__c,
      'should redact Account Plan field on insertion'
    );
    Assert.areEqual(
      'FILE Number *****4321',
      records[0].Money_Out__c,
      'should redact Customer Bio field on insertion'
    );
    Assert.areEqual(
      'TFN Number *********4209',
      records[0].Money_In__c,
      'should redact Executive summary field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Payables__c,
      'should redact Account Plan field on insertion'
    );
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].Receivables__c,
      'should redact Account Plan field on insertion'
    );
  }
}
