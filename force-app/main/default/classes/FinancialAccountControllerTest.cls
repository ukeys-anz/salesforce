@isTest
public with sharing class FinancialAccountControllerTest {
  @testSetup
  static void setup() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = '1';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '82jfsa80534';
    insert accnt;

    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();

    for (Integer i = 0; i < 3; i++) {
      FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
      finAccount.Name = 'Everyday Account' + i;
      finAccount.FinServ__Balance__c = 200;
      finAccount.FinServ__CurrentPostedBalance__c = 200;
      finAccount.FinServ__Status__c = 'Active';
      finAccount.FinServ__FinancialAccountType__c = 'Checking';
      finAccount.FinServ__PrimaryOwner__c = accnt.Id;
      finAccount.Account_Key__c = '342490981' + i;
      finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');

      financialAccounts.add(finAccount);
    }

    insert financialAccounts;

    TestUtil.addAccountsGoalsPs();
  }

  @isTest
  public static void testFinAccountRetrieval() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
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
}
