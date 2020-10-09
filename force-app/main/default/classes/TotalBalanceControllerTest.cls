/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceControllerTest is the test class to cover tests for {@link TotalBalanceController}
 */
@isTest
public with sharing class TotalBalanceControllerTest {
  /**
   * @description setup is to setup test data
   */
  @testSetup
  static void setup() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1';
    accnt.FinServ__TotalFinAcctsPrimaryOwner__c = 200;
    //Rollup summary hardcoded to 200, as it doesn't work in test scenarios and is not the focus of these test cases
    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__Status__c = 'Open';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;

    insert finAccount;
  }

  /**
   * @description testBalanceRetrieval is to test total balance is retrieved successfully
   */
  @isTest
  public static void testBalanceRetrieval() {
    Account accnt = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

    Test.startTest();

    AggregateResult result = TotalBalanceController.getTotalBalance(accnt.Id);

    System.assertEquals(200, result.get('totalBalance'));

    Test.stopTest();
  }
}
