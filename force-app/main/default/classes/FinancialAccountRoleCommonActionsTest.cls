@isTest
public without sharing class FinancialAccountRoleCommonActionsTest {
  @isTest
  public static void testPopulateDataSuccessfully() {
    System.runAs(TestDataFactory.thisUser) {
      //GIVEN
      List<FinServ__FinancialAccount__c> financialAccounts = TestDataFactory.createFinancialAccount(
        1,
        false
      );

      //WHEN
      insert financialAccounts;

      //THEN
      Test.startTest();
      FinServ__FinancialAccountRole__c financialAccountRole = [
        SELECT Role_Type__c, External_Id__c
        FROM FinServ__FinancialAccountRole__c
      ];
      Test.stopTest();

      System.assertEquals(
        financialAccounts[0].Role_Type__c,
        financialAccountRole.Role_Type__c,
        'Financial Account Role - Role Type should be populated.'
      );

      System.assertEquals(
        string.isEmpty(financialAccountRole.External_Id__c),
        false,
        'Financial Account Role - External Id Type should be populated.'
      );
    }
  }

  @isTest
  public static void testUpdateFinancialAccoutWithIsPrimaryOwnerAsFalse() {
    System.runAs(TestDataFactory.thisUser) {
      //GIVEN
      List<FinServ__FinancialAccount__c> financialAccounts = TestDataFactory.createFinancialAccount(
        1,
        true
      );
      string primaryAccount = financialAccounts[0].FinServ__PrimaryOwner__c;
      Account secondaryAccount = TestDataFactory.createAccount(
        'NonPrimaryAccount',
        true
      );

      //WHEN
      financialAccounts[0].IsPrimaryOwner__c = false;
      financialAccounts[0].FinServ__PrimaryOwner__c = secondaryAccount.Id;
      update financialAccounts;

      //THEN
      Test.startTest();
      FinServ__FinancialAccount__c updateFinancialAccount = [
        SELECT FinServ__PrimaryOwner__c
        FROM FinServ__FinancialAccount__c
      ];

      FinServ__FinancialAccountRole__c financialAccountRole = [
        SELECT Role_Type__c, External_Id__c
        FROM FinServ__FinancialAccountRole__c
      ];
      Test.stopTest();

      System.assertEquals(
        updateFinancialAccount.FinServ__PrimaryOwner__c,
        primaryAccount,
        'Financial Account not update when Is Primary flag is false'
      );

      System.assertNotEquals(
        secondaryAccount.Id,
        updateFinancialAccount.FinServ__PrimaryOwner__c,
        'Financial Account not update when Is Primary flag is false'
      );
    }
  }
}
