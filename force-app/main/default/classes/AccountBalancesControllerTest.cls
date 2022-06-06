@isTest
public with sharing class AccountBalancesControllerTest {
  @isTest
  public static void testBalanceRetrieval() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '82jfsa80534';
    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__Status__c = 'Active';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = '342490981';
    finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');

    insert finAccount;

    Test.startTest();

    List<FinServ__FinancialAccount__c> finAccountList = AccountBalancesController.getBalances(
      finAccount.Id
    );
    System.assertEquals(
      1,
      finAccountList.size(),
      'Financial Account List size should be 1.'
    );

    Test.stopTest();
  }
}
