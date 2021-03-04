/**
 *
 * @author Peter Charalambous
 * @since 2021
 * @description UpdateFinancialAccountsTest is the test class to cover tests for {@link UpdateFinancialAccounts}
 */
@isTest
public with sharing class UpdateFinancialAccountsTest {
  /**
   * @description setup is to setup test data
   */
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);

    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 400;
    finAccount.FinServ__CurrentPostedBalance__c = 400;
    finAccount.FinServ__Status__c = 'Open';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = faker.randomString(9);
    finAccount.FinServ__FinancialAccountNumber__c = '123';
    finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');

    insert finAccount;
  }

  /**
   * @description testFinancialAccountUpdate tests that the financial account is updated correctly
   */
  @isTest
  public static void testFinancialAccountUpdate() {
    Account accnt = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    String[] accountNumbers = new List<String>();
    accountNumbers.add('123');

    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__FinancialAccountNumber__c = '123';

    financialAccounts.add(finAccount);

    Test.startTest();
    UpdateFinancialAccounts.updateAccounts(
      accnt.Id,
      accountNumbers,
      financialAccounts
    );

    FinServ__FinancialAccount__c financialAccount = [
      SELECT
        Id,
        FinServ__Balance__c,
        FinServ__CurrentPostedBalance__c,
        LastModifiedDate
      FROM FinServ__FinancialAccount__c
      WHERE Id = :finAccount.Id
    ];

    System.assertEquals(200, financialAccount.FinServ__Balance__c);

    Test.stopTest();
  }
}
