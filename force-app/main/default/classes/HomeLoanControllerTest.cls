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

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = homeLoanCustomer.Name;
    finAccount.RecordTypeId = homeLoanRTId;
    finAccount.FinServ__Balance__c = faker.randomDecimal(6, 2);
    finAccount.FinServ__CurrentPostedBalance__c = faker.randomDecimal(4, 2);
    finAccount.FinServ__Status__c = 'Active';
    finAccount.FinServ__PrimaryOwner__c = homeLoanCustomer.Id;
    finAccount.Account_Key__c = faker.randomString(10);

    insert finAccount;
    Test.startTest();
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Id finAccountId = HomeLoanController.getHomeLoanFinancialAccountId(
        homeLoanCustomer.Id
      );
      System.assertNotEquals(
        null,
        finAccountId,
        'expect to return a financial account id '
      );
    }
    Test.stopTest();
  }
}
