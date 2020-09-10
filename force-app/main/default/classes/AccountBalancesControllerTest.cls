@isTest
public with sharing class AccountBalancesControllerTest {
  @isTest
  public static void testBalanceRetrieval() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1';
    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__Status__c = 'Open';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;

    insert finAccount;

    Test.startTest();

    List<FinServ__FinancialAccount__c> finAccountList = AccountBalancesController.getBalances(
      finAccount.Id
    );
    System.assertEquals(1, finAccountList.size());

    Test.stopTest();
  }
}
