/**
 *
 * @author Jasmine Nguyen
 * @since 03/2021
 * @description Test class for FinancialAccountRoleTriggerHandler (@link FinancialAccountRoleTriggerHandler)
 */
@isTest
public with sharing class FinancialAccountRoleTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    Account customerAccount = new Account();
    customerAccount.FirstName = 'John';
    customerAccount.LastName = 'Doe';
    customerAccount.OCV_Id__c = '123456';
    customerAccount.External_Id__c = 'afs8032lfs0';
    insert customerAccount;
  }

  // Test setting financial role's external Id successfully with primary owner role
  @isTest
  static void testSetFinancialRoleExternalIdWithPrimaryOwner() {
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
    // Assertions
    List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
      SELECT Id, External_Id__c, FinServ__StartDate__c
      FROM FinServ__FinancialAccountRole__c
    ];
    System.assertEquals(
      1,
      financialAccountRoles.size(),
      'Incorrect amount of roles created.'
    );
    System.assertEquals(
      externalIdString,
      financialAccountRoles[0].External_Id__c,
      'Incorrect external Id'
    );
  }

  // Test setting financial role's external Id successfully with non primary owner role
  @isTest
  static void testSetFinancialRoleExternalIdWithNonPrimaryOwner() {
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
    insert financialAccount;

    Test.startTest();
    FinServ__FinancialAccountRole__c finAccRole = new FinServ__FinancialAccountRole__c();
    finAccRole.FinServ__RelatedAccount__c = customerAccount.Id;
    finAccRole.FinServ__FinancialAccount__c = financialAccount.Id;
    finAccRole.FinServ__Role__c = 'Authorized Individual';
    finAccRole.FinServ__StartDate__c = Date.valueOf('2021-03-15');
    insert finAccRole;
    Test.stopTest();
    String externalIdString =
      String.valueOf(customerAccount.External_Id__c) +
      '_' +
      String.valueOf(financialAccount.Account_Key__c) +
      '_' +
      'AuthorizedIndividual' +
      '_' +
      '15032021';
    // Assertions
    List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
      SELECT Id, External_Id__c, FinServ__StartDate__c
      FROM FinServ__FinancialAccountRole__c
    ];
    System.assertEquals(
      2,
      financialAccountRoles.size(),
      'Incorrect amount of roles created.'
    );
    FinServ__FinancialAccountRole__c testFinRole = [
      SELECT External_ID__c
      FROM FinServ__FinancialAccountRole__c
      WHERE FinServ__Role__c = 'Authorized Individual'
      LIMIT 1
    ];
    System.assertEquals(
      externalIdString,
      testFinRole.External_Id__c,
      'Incorrect external Id'
    );
  }

  // Test setting financial role's external Id without primary owner start date
  @isTest
  static void testSetFinancialRoleExternalIdMissingPOStartDate() {
    Account customerAccount = [SELECT Id FROM Account LIMIT 1][0];
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Name = 'Savings Account';
    financialAccount.Account_Key__c = '999000111';
    financialAccount.FinServ__PrimaryOwner__c = customerAccount.Id;
    Test.startTest();
    try {
      insert financialAccount;
      System.assert(
        false,
        'Failed to prevent against user creating financial account'
      );
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'Failed to set external Id for Financial Account Role due to missing value in the following field(s): Primary Owner Start Date/Start Date.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // Test setting financial role's external Id without start date
  @isTest
  static void testSetFinancialRoleExternalIdMissingStartDate() {
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
    insert financialAccount;

    Test.startTest();
    FinServ__FinancialAccountRole__c finAccRole = new FinServ__FinancialAccountRole__c();
    finAccRole.FinServ__RelatedAccount__c = customerAccount.Id;
    finAccRole.FinServ__FinancialAccount__c = financialAccount.Id;
    finAccRole.FinServ__Role__c = 'Authorized Individual';
    finAccRole.FinServ__StartDate__c = null;
    try {
      insert finAccRole;
      System.assert(
        false,
        'Failed to prevent against user creating financial account role'
      );
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'Failed to set external Id for Financial Account Role due to missing value in the following field(s): Primary Owner Start Date/Start Date.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // Test setting financial role's external Id without account key
  @isTest
  static void testSetFinancialRoleExternalIdMissingAccountKey() {
    Account customerAccount = [SELECT Id FROM Account LIMIT 1][0];
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Name = 'Savings Account';
    financialAccount.FinServ__PrimaryOwner__c = customerAccount.Id;
    financialAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-10');
    Test.startTest();
    try {
      insert financialAccount;
      System.assert(
        false,
        'Failed to prevent against user creating financial account'
      );
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'Failed to set external Id for Financial Account Role due to missing value in the following field(s): Account Key.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // Test setting financial role's external Id without external id
  @isTest
  static void testSetFinancialRoleExternalIdMissingExternalId() {
    Account customerAccount = [SELECT Id FROM Account LIMIT 1][0];
    // Remove the account's external id
    customerAccount.External_Id__c = '';
    update customerAccount;

    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Name = 'Savings Account';
    financialAccount.FinServ__PrimaryOwner__c = customerAccount.Id;
    financialAccount.Account_Key__c = '999000111';
    financialAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-10');
    Test.startTest();
    try {
      insert financialAccount;
      System.assert(
        false,
        'Failed to prevent against user creating financial account'
      );
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'Failed to set external Id for Financial Account Role due to missing value in the following field(s): External Id.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }
}
