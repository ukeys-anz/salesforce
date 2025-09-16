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
    Opportunity oppRecord = getOpportunityRecord();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account accRecord = new Account(
      Id = accountId,
      RecordTypeId = RTAccount.personAccount
    );
    oppRecord.AccountId = accountId;
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    commercialOppActionRepoMock.mock(
      'getAccountAccountRelationsForCLG',
      new List<FinServ__AccountAccountRelation__c>{
        new FinServ__AccountAccountRelation__c(
          FinServ__Account__c = accountId,
          FinServ__RelatedAccount__c = clgAccountId
        )
      }
    );

    Test.startTest();
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(
      clgAccountId,
      oppRecords[0].CLG__c,
      'Clg Accounts id should populated on CLG__c field'
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
