/**
 *
 * @author Vidhya Raghavan
 * @since January 2023
 * @description Test class for {@link HomeLoanController)
 */

@isTest
public inherited sharing class HomeLoanControllerTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    Set<String> permissionSetAssigned = TestUtil.getUserPermissionSets(
      UserInfo.getUserId()
    );
    if (!permissionSetAssigned.contains('BoH_Read_Only')) {
      TestUtil.addPermissionSets(new List<String>{ 'BoH_Read_Only' });
    }
  }
  @isTest
  static void homeLoanAccountRetrieve() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      HomeLoanModel response = HomeLoanController.getHomeLoanAccount('2222');

      Test.stopTest();
      System.assertEquals(
        1,
        response.accounts.size(),
        'Home loan found with ocvId and corresponding home loan marketing code'
      );
      System.assertEquals(
        '390899946',
        response.accounts[0].account_number,
        'Account number is corresponding to OCVId'
      );
    }
  }

  @IsTest
  static void getHomeLoanFinancialAccountIdTest() {
    Faker faker = new Faker('AU');
    Id homeLoanRTId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
      .get('BankingAccount')
      .getRecordTypeId();
    Account homeLoanCustomer = new Account();
    homeLoanCustomer.Name =
      faker.person.firstName() +
      ' ' +
      faker.person.lastName();
    homeLoanCustomer.OCV_ID__c = faker.randomString(5);
    homeLoanCustomer.ANZx_Customer__c = true;
    homeLoanCustomer.External_Id__c = faker.randomString(6);
    insert homeLoanCustomer;

    List<FinServ__FinancialAccount__c> finAccounts = TestDataFactory.createFinancialAccount(
      2,
      false
    );
    for (FinServ__FinancialAccount__c finAccount : finAccounts) {
      finAccount.Name = homeLoanCustomer.Name;
      finAccount.RecordTypeId = homeLoanRTId;
      finAccount.FinServ__PrimaryOwner__c = homeLoanCustomer.Id;
    }

    finAccounts[0]
      .Marketing_Code__c = GetHelpConstants.HOME_LOAN_MARKETING_CODES[0];
    finAccounts[0].FinServ__FinancialAccountNumber__c = '111111111';

    insert finAccounts;

    Test.startTest();
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Id finAccountId = HomeLoanController.getHomeLoanFinancialAccountId(
        homeLoanCustomer.Id
      );
      FinServ__FinancialAccount__c result = [
        SELECT FinServ__FinancialAccountNumber__c
        FROM FinServ__FinancialAccount__c
        WHERE Id = :finAccountId
        LIMIT 1
      ];
      Assert.areEqual(
        '111111111',
        result.FinServ__FinancialAccountNumber__c,
        'One home loan marketing code fin account should be returned'
      );
    }
    Test.stopTest();
  }
}
