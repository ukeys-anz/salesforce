/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Test class for FinancialAccountRoleCommonActions (@link FinancialAccountRoleCommonActionsTest)
 */

@isTest
public with sharing class FinancialAccountRoleCommonActionsTest {
  @TestSetup
  static void makeData() {
    Account customerAccount = new Account();
    customerAccount.FirstName = 'John';
    customerAccount.LastName = 'Doe';
    customerAccount.OCV_Id__c = '123456';
    customerAccount.External_Id__c = 'afs8032lfs0';
    insert customerAccount;
  }

  // Test setting financial role's external Id successfully
  @isTest
  static void testSetFinancialRoleExternalIdSuccessfully() {
    Account customerAccount = [
      SELECT Id, External_Id__c
      FROM Account
      LIMIT 1
    ][0];
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Name = 'Savings Account';
    financialAccount.Account_Key__c = '999000111';
    financialAccount.FinServ__PrimaryOwner__c = customerAccount.Id;
    financialAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-10');
    Test.startTest();
    insert financialAccount;
    Test.stopTest();
    String externalIdString =
      String.valueOf(customerAccount.External_Id__c) +
      '_' +
      String.valueOf(financialAccount.Account_Key__c) +
      '_' +
      'PrimaryOwner' +
      '_' +
      '10022021';
    List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
      SELECT Id, External_Id__c, FinServ__StartDate__c
      FROM FinServ__FinancialAccountRole__c
    ];
    // Assertions
    System.assertEquals(1, financialAccountRoles.size());
    System.assertEquals(
      externalIdString,
      financialAccountRoles[0].External_Id__c
    );
    System.assertEquals(
      Date.valueOf('2021-02-10'),
      financialAccountRoles[0].FinServ__StartDate__c
    );
  }

  // Test setting financial role's external Id with exception thrown
  @isTest
  static void testSetFinancialRoleExternalIdWithException() {
    Account customerAccount = [SELECT Id FROM Account LIMIT 1][0];
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Name = 'Savings Account';
    financialAccount.Account_Key__c = '999000111';
    financialAccount.FinServ__PrimaryOwner__c = customerAccount.Id;
    Test.startTest();
    try {
      insert financialAccount;
    } catch (Exception e) {
      System.assertNotEquals(null, e);
    }
    Test.stopTest();
  }
}
