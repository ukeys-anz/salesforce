/**
 * @author       : Mildeep Singh
 * @since        : Sept 2025
 * @description  : Test class for CommercialNeedsAnalysisActions
 **/
@isTest
public class CommercialNeedsAnalysisActionsTest {
  static Lib_MockProvider needsAnalysisRepoMock;

  static void registerMocks() {
    needsAnalysisRepoMock = Lib_MockProvider.forType(
      CommercialNeedsAnalysisRepository.class
    );
  }

  @isTest
  static void populateCustomerFromOpportunityTest() {
    registerMocks();

    // GIVEN Needs Analysis Record
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

    // WHEN Calling method
    CommercialNeedsAnalysisActions.populateCustomerFromOpportunity(naRecords);

    // THEN
    Assert.areEqual(
      naRecords[0].Customer__c,
      accRecordId,
      'Customer field should be populated with opportunity account Id'
    );
  }

  @isTest
  static void setCustomerIdToNeedsAnalysisTest() {
    registerMocks();

    // GIVEN records, oppToCustomer
    Id accRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Needs_Analysis__c> records = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(
        Id = Lib_FakeIdGenerator.getMockId(Needs_Analysis__c.SObjectType),
        RecordTypeId = RTNeedsAnalysis.transactionalBankingNeedsAnalysis,
        Opportunity__c = oppId
      )
    };

    Map<Id, Opportunity> oppToCustomer = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = accRecordId)
    };

    // WHEN Calling method
    CommercialNeedsAnalysisActions.setCustomerIdToNeedsAnalysis(
      records,
      oppToCustomer
    );

    // THEN it should assert properly
    Assert.areEqual(
      records[0].Customer__c,
      accRecordId,
      'Customer field on Need Analysis should be populated with account Id from Opportunity'
    );
  }

  @isTest
  static void populateCustomerFromOpportunityNullTest() {
    registerMocks();

    // GIVEN records, oppToCustomer
    Id accRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Needs_Analysis__c> records = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(
        Id = Lib_FakeIdGenerator.getMockId(Needs_Analysis__c.SObjectType),
        RecordTypeId = RTNeedsAnalysis.transactionalBankingNeedsAnalysis
      )
    };

    // WHEN Calling method
    CommercialNeedsAnalysisActions.populateCustomerFromOpportunity(records);

    // THEN it should assert properly
    Assert.isNull(
      records[0].Customer__c,
      'Customer field on Need Analysis should be null'
    );
  }

  @isTest
  static void restrictImagesInRichTextFieldsTest() {
    //GIVEN records, oldMap
    Id crId = Lib_FakeIdGenerator.getMockId(Needs_Analysis__c.SObjectType);
    List<Needs_Analysis__c> records = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(Id = crId, Overview__c = '<img>Google.com</img>')
    };

    Map<Id, Needs_Analysis__c> oldMap = new Map<Id, Needs_Analysis__c>{
      crId => new Needs_Analysis__c(
        Id = crId,
        Overview__c = '<img>Google.com</img>'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialNeedsAnalysisActions.restrictImagesInRichTextFields(
      records,
      oldMap
    );
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      records[0].hasErrors(),
      'No error while inserting Needs Analysis record with Image.'
    );
  }
}
