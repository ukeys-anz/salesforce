@isTest
public with sharing class FinancialAccountControllerTest {
  @testSetup
  static void setup() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = '1';
    accnt.ANZx_Customer__c = true;
    insert accnt;

    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();

    for (Integer i = 0; i < 3; i++) {
      FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
      finAccount.Name = 'Everyday Account' + i;
      finAccount.FinServ__Balance__c = 200;
      finAccount.FinServ__CurrentPostedBalance__c = 200;
      finAccount.FinServ__Status__c = 'Open';
      finAccount.FinServ__FinancialAccountType__c = 'Checking';
      finAccount.FinServ__PrimaryOwner__c = accnt.Id;

      financialAccounts.add(finAccount);
    }

    insert financialAccounts;
  }

  @isTest
  public static void testFinAccountRetrieval() {
    Account accnt = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    Test.startTest();

    List<FinServ__FinancialAccount__c> finAccountList = FinancialAccountController.getFinancialAccounts(
      accnt.Id,
      3,
      'Checking'
    );

    System.assertEquals(3, finAccountList.size());

    Test.stopTest();
  }
}
