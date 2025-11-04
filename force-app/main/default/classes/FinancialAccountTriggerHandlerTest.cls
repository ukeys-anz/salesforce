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
    finAccount.RecordTypeId = GetHelpConstants.CHECKING_ACCOUNT_RT_ID;
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = faker.randomString(9);
    finAccount.FinServ__FinancialAccountNumber__c = '123';
    finAccount.Number_Of_Signatures__c = '1';
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

  @isTest
  public static void testpopulateProductOnFinancialAccount() {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);
    accnt.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Product2 product = new Product2(
      Id = productId,
      Name = 'Test Product',
      ANZ_Product_Code__c = '198'
    );

    // adding mock product to selector
    QueryProducts.productsByProductCode = new Map<String, Product2>{
      product.ANZ_Product_Code__c => product
    };

    FinServ__FinancialAccount__c finAccount = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
      accnt.Id,
      false
    );
    FinServ__FinancialAccount__c newFinAccount = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
      accnt.Id,
      false
    );
    newFinAccount.Marketing_Code__c = '198';
    newFinAccount.Id = finAccount.Id;
    Test.startTest();
    Map<Id, FinServ__FinancialAccount__c> oldMap = new Map<Id, FinServ__FinancialAccount__c>{
      finAccount.Id => finAccount
    };
    List<FinServ__FinancialAccount__c> records = new List<FinServ__FinancialAccount__c>{
      newFinAccount
    };
    FinancialAccountActions.populateProductOnFinancialAccount(records, oldMap);
    Test.stopTest();

    Assert.areEqual(
      records[0].FinServ__ProductName__c,
      product.Id,
      'Product linked successfully'
    );
  }
}
