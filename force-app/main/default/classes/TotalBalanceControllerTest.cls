/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceControllerTest is the test class to cover tests for {@link TotalBalanceController}
 */
@isTest
public with sharing class TotalBalanceControllerTest {
  private static User thisUser = [
    SELECT Id
    FROM User
    WHERE Id = :UserInfo.getUserId()
  ];

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
    accnt.FinServ__TotalFinAcctsPrimaryOwner__c = 200;
    accnt.External_Id__c = faker.randomString(10);
    //Rollup summary hardcoded to 200, as it doesn't work in test scenarios and is not the focus of these test cases
    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__Status__c = 'Active';
    finAccount.RecordTypeId = GetHelpConstants.CHECKING_ACCOUNT_RT_ID;
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = faker.randomString(9);

    insert finAccount;

    FinServ__FinancialAccount__c[] savingAccounts = new List<FinServ__FinancialAccount__c>();
    for (Integer i = 0; i < 2; i++) {
      savingAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Savings Account',
          FinServ__Balance__c = 200,
          FinServ__CurrentPostedBalance__c = 200,
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = faker.randomString(9)
        )
      );
    }

    insert savingAccounts;

    // Inserting as current user, to get around MIXED_DML_OPERATION error
    System.runAs(thisUser) {
      TestUtil.addAccountsGoalsPs();
    }
  }

  /**
   * @description testBalanceRetrieval is to test total balance is retrieved successfully
   */
  @isTest
  public static void testBalanceRetrieval() {
    System.runAs(thisUser) {
      Account accnt = [
        SELECT Id
        FROM Account
        WHERE Display_Name__c = 'TestAccount'
        LIMIT 1
      ];

      Test.startTest();

      AggregateResult result = TotalBalanceController.getTotalBalance(accnt.Id);

      System.assertEquals(
        600,
        result.get('totalBalance'),
        'Total balance should be as expected.'
      );

      Test.stopTest();
    }
  }

  /**
   * @description testBalanceRetrieval is to test total balance is retrieved successfully
   */
  @isTest
  public static void testTotalSavedRetrieval() {
    Account accnt = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];
    AggregateResult result;
    Test.startTest();
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      result = TotalBalanceController.getTotalSaved(accnt.Id);
    }

    Test.stopTest();

    System.assertEquals(
      400,
      result.get('totalSaved'),
      'Total saved should be as expected.'
    );
  }
}
