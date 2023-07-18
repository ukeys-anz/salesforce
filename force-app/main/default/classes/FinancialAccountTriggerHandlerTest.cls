/**
 *
 * @author Jasmine Nguyen
 * @since 03/2021
 * @description Test class for @link FinancialAccountTriggerHandler
 */

@isTest
public with sharing class FinancialAccountTriggerHandlerTest {
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
    accnt.External_Id__c = faker.randomString(10);

    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 400;
    finAccount.FinServ__CurrentPostedBalance__c = 400;
    finAccount.FinServ__Status__c = 'Active';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = faker.randomString(9);
    finAccount.FinServ__FinancialAccountNumber__c = '123';

    insert finAccount;
  }

  @isTest
  private static void testPopulateSourceStatus() {
    // GIVEN a financial account record
    FinServ__FinancialAccount__c finAccount = [
      SELECT Id, FinServ__PrimaryOwner__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];

    Test.startTest();
    // WHEN the record is updated with source system status
    finAccount.Source_System_Status__c = 'CAPCISOP';
    update finAccount;
    Test.stopTest();

    // THEN the source system status display is updated from status picklist label
    FinServ__FinancialAccount__c updatedFinAccount = [
      SELECT Id, Source_System_Status__c, Source_System_Status_Display__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];
    System.assertEquals(
      CommonUtil.getSinglePicklistLabel(
          FinServ__FinancialAccount__c.Source_System_Status__c,
          updatedFinAccount.Source_System_Status__c
        )
        .remove('CAPCIS'),
      updatedFinAccount.Source_System_Status_Display__c,
      'Source System Status does not match with the picklist label.'
    );
  }
}
