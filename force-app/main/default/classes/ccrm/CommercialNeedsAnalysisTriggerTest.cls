/**
 * @author       : Mildeep Singh
 * @since        : Sept 2025
 * @description  : This is the handler class for CommercialNeedsAnalysisTrigger
 **/
@isTest
public with sharing class CommercialNeedsAnalysisTriggerTest {
  @isTest
  static void beforeInsertTest() {
    //GIVEN records
    Account accRecord = new Account(
      Name = 'Sample Account',
      OCV_ID__c = 'OCV7861',
      FinServ__KYCStatus__c = 'Completed - Valid',
      FinServ__Status__c = 'Active',
      RecordTypeId = RTAccount.businessAccount,
      Source_System_Name__c = System.Label.CCRM_Source_System_Name
    );
    insert accRecord;

    Opportunity oppRecord = new Opportunity(
      Name = 'Test Opp ',
      Accountid = accRecord.id,
      StageName = 'New',
      CloseDate = DateTimeUtils.getNextWeekdayDate(3),
      Description = '987654321',
      RecordTypeId = RTOpportunity.commercialOpportunity
    );
    insert oppRecord;

    List<Needs_Analysis__c> naRecords = new List<Needs_Analysis__c>{
      new Needs_Analysis__c(
        RecordTypeId = RTNeedsAnalysis.transactionalBankingNeedsAnalysis,
        Opportunity__c = oppRecord.Id
      )
    };

    //WHEN calling a method
    Test.startTest();
    insert naRecords;
    Test.stopTest();

    //Assert is should not throw an error
    Assert.areEqual(
      1,
      naRecords.size(),
      'Record should be inserted successfully'
    );
  }
}
