/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Opportunity Action Test is the test class for CCRM Opportunity Actions Class.
 */
@isTest
private class CCRMOpportunityActionsTest {
  @isTest
  static void testCreateOpportunity() {
    //Given when banker creates a new Opportunity
    //When Account Name is valid and Amount is valid
    //Then Opportunity Name is Account_Name_Amount
    Account accnt = CCRMTestDataFactory.createPersonAccount();

    Opportunity opp = new Opportunity();
    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get('Commercial_Opportunity')
      .getRecordTypeId();
    opp.Name = 'sample';
    opp.AccountId = accnt.id;
    opp.StageName = 'Opportunity Identified';
    opp.Amount = 2000;
    opp.CloseDate = System.today() + 10;
    insert opp;
    opp = [SELECT Id, Name, Amount FROM Opportunity WHERE id = :opp.id];
    System.assertEquals(
      opp.Name,
      'sample',
      'Opportunity Name is the same for Manual Opportunity.'
    );
  }
}
