/**
 * @author Emmanuel Yap
 * @since 01/2022
 * @description OpportunityTriggerHandlerTest is the test class for Opportunity Trigger and Opportunity Trigger Handler Class.
 */
@isTest
private class OpportunityTriggerHandlerTest {
  static Lib_MockProvider commercialOppActionRepoMock;
  static void registerMocks() {
    commercialOppActionRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
  }

  @istest
  static void testBeforeInsert() {
    registerMocks();
    Opportunity oppRecord = new Opportunity(
      Name = 'Test Opp ',
      StageName = 'Need Analysis',
      RecordType = new RecordType(DeveloperName = 'Commercial_Opportunity'),
      RecordTypeId = RTOpportunity.commercialOpportunity
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    oppRecord.AccountId = accountId;
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    commercialOppActionRepoMock.mock('getUsers', new List<User>());

    Test.startTest();
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(
      'Stage can only be set to New.',
      oppRecords[0].getErrors()[0].getMessage(),
      'Opportunity stage can only be set new on insertion'
    );
  }

  static Opportunity getOpportunityRecord() {
    return new Opportunity(
      Name = 'Test Opp ',
      StageName = 'Need Analysis',
      Customer_Needs__c = 'Asset Finance',
      Amount = 200,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      CloseDate = system.Today() + 10,
      Description = 'Test Opportunity TAX Number 1234567890 Credit Card Number 12345678901234 TFN Number 0134024094209',
      RecordTypeId = RTOpportunity.mlOpportunity,
      RecordType = new RecordType(DeveloperName = 'MLCRM_Opportunity'),
      Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
      Lead_Converted__c = false
    );
  }
}
