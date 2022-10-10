/**
 * @author Paul Boyington
 * @since May 2022
 * @description Test class for StravinskyController
 */
@isTest
public with sharing class StravinskyControllerTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(10)
    );

    insert acc;

    //Test account with no financial accounts
    Account accNoFinAccount = new Account(
      Name = 'TestAccountNoFin',
      Display_Name__c = 'TestAccountNoFin',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(10)
    );

    insert accNoFinAccount;

    FinServ__FinancialAccount__c checkingAccount = new FinServ__FinancialAccount__c();
    checkingAccount.Name = 'Everyday Account';
    checkingAccount.FinServ__Balance__c = 400;
    checkingAccount.FinServ__CurrentPostedBalance__c = 400;
    checkingAccount.FinServ__Status__c = 'Active';
    checkingAccount.FinServ__FinancialAccountType__c = 'Checking';
    checkingAccount.FinServ__PrimaryOwner__c = acc.Id;
    checkingAccount.Account_Key__c = faker.randomString(10);
    checkingAccount.Primary_Owner_Start_Date__c = Date.valueOf('2022-08-03');
    insert checkingAccount;

    FinServ__FinancialAccount__c savingsAccount = new FinServ__FinancialAccount__c();
    savingsAccount.Name = 'Savings Account';
    savingsAccount.FinServ__Balance__c = 400;
    savingsAccount.FinServ__CurrentPostedBalance__c = 400;
    savingsAccount.FinServ__Status__c = 'Active';
    savingsAccount.FinServ__FinancialAccountType__c = 'Savings';
    savingsAccount.FinServ__PrimaryOwner__c = acc.Id;
    savingsAccount.Account_Key__c = faker.randomString(10);
    savingsAccount.Primary_Owner_Start_Date__c = Date.valueOf('2022-08-03');
    insert savingsAccount;
  }

  @isTest
  static void testPackageClosureAuraSuccess() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
      Package_Id__c = faker.randomString(10)
    );
    insert newCase;

    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      PackageClosureModel response = StravinskyController.getPackageClosureAura(
        newCase.Id
      );

      Test.stopTest();
      System.assertEquals(200, response.status.code);
      System.assertEquals(
        'Package closure successfully completed',
        response.status.description
      );
    }
  }

  @isTest
  static void testPackageClosureNoFinAccount() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccountNoFin'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
      Package_Id__c = faker.randomString(10)
    );
    insert newCase;
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      try {
        PackageClosureModel response = StravinskyController.getPackageClosureAura(
          newCase.Id
        );
        System.assert(false, 'Should have thrown an exception');
      } catch (AuraHandledException e) {
        System.assertEquals(
          'Failed to retrieve financial account data. Please refresh and try again. Raise a fault through TechAssist if the problem persists.',
          e.getMessage()
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testPackageClosureNoPackageId() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    );
    insert newCase;
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      try {
        PackageClosureModel response = StravinskyController.getPackageClosureAura(
          newCase.Id
        );
        System.assert(false, 'Should have thrown an exception');
      } catch (AuraHandledException e) {
        System.assertEquals(
          'No package id found. Please ensure a package id has been added to the case. Raise a fault through TechAssist if the problem persists.',
          e.getMessage()
        );
      }

      Test.stopTest();
    }
  }
}
