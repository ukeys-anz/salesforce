/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Test class for {@link FinancialAccountRoleTriggerHandler}
 */
@isTest
public with sharing class FinancialAccountRoleTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    CCRMTestDataFactory.createSystemCustomer();
  }

  @isTest
  static void testTriggers() {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();

    try {
      FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c();
      insert fa;

      FinServ__FinancialAccountRole__c far = new FinServ__FinancialAccountRole__c(
        FinServ__RelatedAccount__c = faSettings.System_Customer_Id__c,
        FinServ__FinancialAccount__c = fa.Id,
        FinServ__Role__c = 'Administrator'
      );
      insert far;
    } catch (Exception e) {
      Assert.fail(
        'Triggers should be executed without error: ' + e.getMessage()
      );
    }
  }
}
