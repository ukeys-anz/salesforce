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
    finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');

    insert finAccount;
  }

  @isTest
  private static void changingPrimaryOwnerWithoutStartDate() {
    FinServ__FinancialAccount__c finAccount = [
      SELECT Id, FinServ__PrimaryOwner__c, Primary_Owner_Start_Date__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];

    Faker faker = new Faker('AU');
    Account accnt2 = new Account();
    accnt2.Name = 'TestAccount2';
    accnt2.Display_Name__c = 'TestAccount2';
    accnt2.OCV_ID__c = faker.randomString(10);
    accnt2.ANZx_Customer__c = true;
    accnt2.External_Id__c = faker.randomString(10);
    insert accnt2;

    Test.startTest();
    try {
      finAccount.Primary_Owner_Start_Date__c = null;
      finAccount.FinServ__PrimaryOwner__c = accnt2.Id;
      update finAccount;
      System.assert(
        false,
        'Expected an exception when setting the Primary Owner Start Date to NULL'
      );
    } catch (Exception e) {
      System.assertNotEquals(
        'Primary owner start date cannot be empty. Financial Account Id: ' +
        finAccount.Id,
        e.getMessage(),
        'Error message does not match.'
      );
    }
    Test.stopTest();
  }

  /*@isTest
  private static void changingStartDatesWithoutUpdatingPrimaryOwner() {
    FinServ__FinancialAccount__c finAccount = [
      SELECT Id, FinServ__PrimaryOwner__c, Primary_Owner_Start_Date__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];
    Test.startTest();

    try {
      finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-03-04'); // some random date
      update finAccount;

      System.assert(
        false,
        'Should have thrown an exception when attempting to updating the start dates without a primary owner update'
      );
    } catch (Exception e) {
      System.assertNotEquals(
        'Primary Owner and Primary Owner Start Date values should be updated simultaneously. Financial Account Id: ' +
        finAccount.Id,
        e.getMessage(),
        'Error message does not match.'
      );
    }

    Test.stopTest();
  }*/

  @isTest
  private static void changingPrimaryOwnerSuccessfully() {
    FinServ__FinancialAccount__c finAccount = [
      SELECT Id, FinServ__PrimaryOwner__c, Primary_Owner_Start_Date__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];

    Faker faker = new Faker('AU');
    Account accnt2 = new Account();
    accnt2.Name = 'TestAccount2';
    accnt2.Display_Name__c = 'TestAccount2';
    accnt2.OCV_ID__c = faker.randomString(10);
    accnt2.ANZx_Customer__c = true;
    accnt2.External_Id__c = faker.randomString(10);
    insert accnt2;

    Test.startTest();
    try {
      finAccount.FinServ__PrimaryOwner__c = accnt2.Id;
      finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-03-04');
      update finAccount;
    } catch (Exception e) {
      System.assertEquals(null, e, 'Exception occurs');
    }
    Test.stopTest();

    FinServ__FinancialAccount__c updatedFinAccount = [
      SELECT Id, FinServ__PrimaryOwner__c, Primary_Owner_Start_Date__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];
    System.assertEquals(
      accnt2.Id,
      updatedFinAccount.FinServ__PrimaryOwner__c,
      'Primary Owner does not match.'
    );
    System.assertEquals(
      Date.valueOf('2021-03-04'),
      updatedFinAccount.Primary_Owner_Start_Date__c,
      'Primary Owner Start Date does not match.'
    );
  }
}
