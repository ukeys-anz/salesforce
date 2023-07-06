/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Test class for {@link CCRMFinancialAccountActions}
 */
@IsTest
private class CCRMFinancialAccountActionsTest {
  @TestSetup
  static void makeData() {
    CCRMTestDataFactory.createBusinessAccount();
    CCRMTestDataFactory.createSystemCustomer();
  }

  @IsTest
  static void testSetPrimaryOwner() {
    Account normalFaOwner = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];

    FinServ__FinancialAccount__c faWithOwnerId = new FinServ__FinancialAccount__c(
      FinServ__PrimaryOwner__c = normalFaOwner.Id
    );
    FinServ__FinancialAccount__c faWithoutOwnerId = new FinServ__FinancialAccount__c();

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      CCRMFinancialAccountActions.setPrimaryOwner(
        new List<FinServ__FinancialAccount__c>{
          faWithOwnerId,
          faWithoutOwnerId
        }
      );
    }
    Test.stopTest();

    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    Assert.areNotEqual(
      faSettings.System_Customer_Id__c,
      faWithOwnerId.FinServ__PrimaryOwner__c,
      'Primary Owner should be set to System Customer if it is blank'
    );
    Assert.areEqual(
      faSettings.System_Customer_Id__c,
      faWithoutOwnerId.FinServ__PrimaryOwner__c,
      'Primary Owner should not be set to System Customer if it already has a value'
    );
  }

  @IsTest
  static void testPopulateName() {
    FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(
      FinServ__FinancialAccountType__c = 'CAP-CIS:DDA',
      FinServ__FinancialAccountNumber__c = '001'
    );

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      CCRMFinancialAccountActions.populateName(
        new List<FinServ__FinancialAccount__c>{ fa }
      );
    }
    Test.stopTest();

    Assert.areEqual(
      'DDA-001',
      fa.Name,
      'Name should be a concated string of Account Type and Account Number'
    );
  }
}
