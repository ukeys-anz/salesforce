/**
 * @description OpportunityLineItemTriggerTest is the test class for Opportunity Line Item Trigger.
 * @author Naman Garg
 * @since Jun 2025
 */
@isTest
public with sharing class OpportunityLineItemTriggerTest {
  @isTest
  static void insertOLITest() {
    //This is used to cover the trigger test coverage
    insert new Opportunity(
      Name = 'Sample Opp',
      StageName = 'New',
      CloseDate = System.Today() + 1,
      RecordTypeId = RTOpportunity.commercialOpportunity
    );
    OpportunityLineItem oliRecord = CCRMTestDataFactory.createOpportunityLineItem();
    insert oliRecord;

    //THEN it should successfully insert oli record
    Assert.isNotNull(oliRecord.Id, 'should successfully insert oli record');
  }
}
