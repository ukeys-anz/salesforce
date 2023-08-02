@isTest
public with sharing class FinancialAccountControllerTest {
  private static User thisUser = [
    SELECT Id
    FROM User
    WHERE Id = :UserInfo.getUserId()
  ];

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

    // skip 111111111 because it is in the fabric mock response, and we need to test the partial update
    List<String> testFinAccNumbers = new List<String>{
      '000000000',
      '222222222',
      '333333333'
    };

    for (Integer i = 0; i < 3; i++) {
      FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
      finAccount.Name = 'Everyday Account' + i;
      finAccount.FinServ__Balance__c = 200;
      finAccount.FinServ__CurrentPostedBalance__c = 200;
      finAccount.FinServ__Status__c = 'Active';
      finAccount.RecordTypeId = GetHelpConstants.CHECKING_ACCOUNT_RT_ID;
      finAccount.FinServ__PrimaryOwner__c = accnt.Id;
      finAccount.Account_Key__c = '342490981' + i;
      finAccount.FinServ__FinancialAccountNumber__c = testFinAccNumbers[i];

      financialAccounts.add(finAccount);
    }

    insert financialAccounts;

    // Inserting as current user, to get around MIXED_DML_OPERATION error
    System.runAs(thisUser) {
      TestUtil.addAccountsGoalsPs();
    }
  }

  /**
   * @description Test retrieval of financial accounts
   */
  @isTest
  public static void testFinAccountDBRetrieval() {
    System.runAs(thisUser) {
      Account accnt = [
        SELECT Id
        FROM Account
        WHERE Display_Name__c = 'TestAccount'
        LIMIT 1
      ];

      List<String> accountTypes = new List<String>{
        GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME,
        GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME
      };
      Test.startTest();

      List<FinServ__FinancialAccount__c> finAccountList = FinancialAccountController.getFinancialAccountDB(
        accnt.Id,
        accountTypes
      );

      Test.stopTest();

      Assert.areEqual(
        3,
        finAccountList.size(),
        'Incorrect number of financial accounts returned'
      );
    }
  }

  /**
   * @description Test retrieval of financial accounts, with 3 accounts in the response and only 2 in the database
   */
  @isTest
  public static void testFinAccountFabricRetrieval() {
    System.runAs(thisUser) {
      Account accnt = [
        SELECT Id
        FROM Account
        WHERE Display_Name__c = 'TestAccount'
        LIMIT 1
      ];

      List<String> accountTypes = new List<String>{
        GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME,
        GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME
      };
      Test.startTest();

      List<FinServ__FinancialAccount__c> finAccountList = FinancialAccountController.getFinancialAccountFabric(
        accnt.Id,
        accountTypes
      );

      Test.stopTest();

      Assert.areEqual(
        2,
        finAccountList.size(),
        'Two accounts in the mock response should be returned'
      );

      for (FinServ__FinancialAccount__c fa : finAccountList) {
        Assert.isNotNull(
          fa.RecordType?.DeveloperName,
          'DeveloperName must be available'
        );
      }

      FinServ__FinancialAccount__c databaseFinancialAccount = (FinServ__FinancialAccount__c) [
        SELECT FinServ__Balance__c
        FROM FinServ__FinancialAccount__c
        WHERE FinServ__FinancialAccountNumber__c = '000000000'
      ];
      Assert.areEqual(
        18.0012,
        databaseFinancialAccount.FinServ__Balance__c,
        'Financial account balance should be updated'
      );
    }
  }
}
