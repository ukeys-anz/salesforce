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
    checkingAccount.RecordTypeId = GetHelpConstants.CHECKING_ACCOUNT_RT_ID;
    checkingAccount.FinServ__PrimaryOwner__c = acc.Id;
    checkingAccount.Account_Key__c = faker.randomString(10);
    insert checkingAccount;

    FinServ__FinancialAccount__c savingsAccount = new FinServ__FinancialAccount__c();
    savingsAccount.Name = 'Savings Account';
    savingsAccount.FinServ__Balance__c = 400;
    savingsAccount.FinServ__CurrentPostedBalance__c = 400;
    savingsAccount.FinServ__Status__c = 'Active';
    savingsAccount.RecordTypeId = GetHelpConstants.SAVINGS_ACCOUNT_RT_ID;
    savingsAccount.FinServ__PrimaryOwner__c = acc.Id;
    savingsAccount.Account_Key__c = faker.randomString(10);
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
      Account_Type__c = 'Individual',
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
      System.assertEquals(
        200,
        response.status.code,
        'Status code of 200 was expected'
      );
      System.assertEquals(
        'Package closure successfully completed',
        response.status.description,
        'Package closure was not successful'
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
      Account_Type__c = 'Individual',
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
      Package_Id__c = faker.randomString(10)
    );
    insert newCase;
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      try {
        StravinskyController.getPackageClosureAura(newCase.Id);
        System.assert(false, 'Should have thrown an exception');
      } catch (AuraHandledException e) {
        System.assertEquals(
          'Failed to retrieve financial account data. Please refresh and try again. Raise a fault through TechAssist if the problem persists.',
          e.getMessage(),
          'Exception message was not as expected'
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

    Case newCase = new Case(
      AccountId = acc.Id,
      Account_Type__c = 'Individual',
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    );
    insert newCase;
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      try {
        StravinskyController.getPackageClosureAura(newCase.Id);
        System.assert(false, 'Should have thrown an exception');
      } catch (AuraHandledException e) {
        System.assertEquals(
          'No package id found. Please ensure a package id has been added to the case. Raise a fault through TechAssist if the problem persists.',
          e.getMessage(),
          'Exception message was not as expected'
        );
      }

      Test.stopTest();
    }
  }

  @isTest
  static void testPackageClosureJointAccount() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      //Joint Account
      Account jointCustomer = TestDataFactory.createPersonAccount(
        '10111111',
        true
      );
      List<FinServ__FinancialAccount__c> jointFinAccount = TestDataFactory.createFinancialAccount(
        1,
        true
      );
      FinServ__FinancialAccountRole__c financialAccountRoleRecord = new FinServ__FinancialAccountRole__c(
        FinServ__RelatedAccount__c = jointCustomer.Id,
        FinServ__FinancialAccount__c = jointFinAccount[0].Id,
        FinServ__Active__c = true,
        Finserv__Role__c = 'Additional Owner'
      );

      insert financialAccountRoleRecord;

      Faker faker = new Faker('AU');
      Case newCase = new Case(
        AccountId = jointCustomer.Id,
        Account_Type__c = 'Joint',
        RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
        Package_Id__c = faker.randomString(10)
      );
      insert newCase;

      PackageClosureModel response = StravinskyController.getPackageClosureAura(
        newCase.Id
      );

      Test.stopTest();
      System.assertEquals(
        200,
        response.status.code,
        'Status code of 200 was expected'
      );
      System.assertEquals(
        'Package closure successfully completed',
        response.status.description,
        'Package closure was not successful'
      );
    }
  }

  @isTest
  static void testPackageClosureJointAccountException() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      //Joint Account
      Account jointCustomer = TestDataFactory.createPersonAccount(
        '10111111',
        true
      );
      List<FinServ__FinancialAccount__c> jointFinAccount = TestDataFactory.createFinancialAccount(
        2,
        true
      );

      List<FinServ__FinancialAccountRole__c> financialAccountRoleRecordList = new List<FinServ__FinancialAccountRole__c>();
      FinServ__FinancialAccountRole__c financialAccountRoleRecord1 = new FinServ__FinancialAccountRole__c(
        FinServ__RelatedAccount__c = jointCustomer.Id,
        FinServ__FinancialAccount__c = jointFinAccount[0].Id,
        FinServ__Active__c = true,
        Finserv__Role__c = 'Additional Owner'
      );
      financialAccountRoleRecordList.add(financialAccountRoleRecord1);

      FinServ__FinancialAccountRole__c financialAccountRoleRecord2 = new FinServ__FinancialAccountRole__c(
        FinServ__RelatedAccount__c = jointCustomer.Id,
        FinServ__FinancialAccount__c = jointFinAccount[1].Id,
        FinServ__Active__c = true,
        Finserv__Role__c = 'Additional Owner'
      );
      financialAccountRoleRecordList.add(financialAccountRoleRecord2);
      insert financialAccountRoleRecordList;

      Faker faker = new Faker('AU');
      Case newCase = new Case(
        AccountId = jointCustomer.Id,
        Account_Type__c = 'Joint',
        RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
        Package_Id__c = faker.randomString(10)
      );
      insert newCase;

      try {
        StravinskyController.getPackageClosureAura(newCase.Id);
        System.assert(false, 'Should have thrown an exception');
      } catch (AuraHandledException e) {
        System.assertEquals(
          'Failed to perform account closure because there are more than one Joint Account associated with the customer',
          e.getMessage(),
          'Exception message was not as expected'
        );
        Test.stopTest();
      }
    }
  }
}
