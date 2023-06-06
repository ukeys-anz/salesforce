/**
 * @author Boobalakrishnan Duraisamy
 * @since 03/2023
 * @description To unit test temporary batch classes created for transform and update external Id.
 */
@isTest
public with sharing class CCRMExternalIdBatchTest {
  @isTest
  public static void testExternalIdUpdateOnAccount() {
    //GIVEN a account record
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1234567891';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '1234567891_CAP-CIS_9876543219';
    insert accnt;

    Test.startTest();
    //WHEN the external id update batch class is executed
    CCRMUpdateAccExternalIdBatch externalIdBatch = new CCRMUpdateAccExternalIdBatch();
    Database.executeBatch(externalIdBatch);

    Test.stopTest();

    Account acc = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM Account
      WHERE External_Id__c != NULL
      LIMIT 1
    ];
    //THEN the external id is copied to temporary field and updated to new transformed value
    System.assertEquals(
      acc.External_Id__c,
      acc.Temporary_External_Id__c.substringAfter('_'),
      'External ID update is not successful'
    );
  }

  @isTest
  public static void testExternalIdRevertOnAccount() {
    //GIVEN a account record
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1234567891';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = 'CAP-CIS_9876543219';
    accnt.Temporary_External_Id__c = '1234567891_CAP-CIS_9876543219';
    insert accnt;

    Test.startTest();
    //WHEN the external id revert batch class is executed
    CCRMRevertAccExternalIdBatch revertExternalIdBatch = new CCRMRevertAccExternalIdBatch();
    Database.executeBatch(revertExternalIdBatch);

    Test.stopTest();

    Account acc = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM Account
      WHERE External_Id__c != NULL
      LIMIT 1
    ];
    //THEN the external id value is reverted from temporary field
    System.assertEquals(
      acc.Temporary_External_Id__c,
      acc.External_Id__c,
      'External ID revert is not successful'
    );
  }

  @isTest
  public static void testExternalIdUpdateOnFAR() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1234567891';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '1234567891_CAP-CIS_9876543219';
    insert accnt;

    //GIVEN a financial account record
    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__Status__c = 'Active';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = '342490981';
    finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');

    insert finAccount;

    FinServ__FinancialAccountRole__c far = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM FinServ__FinancialAccountRole__c
      LIMIT 1
    ];

    far.External_Id__c = '1234567897_CAP-CIS_9876543219';
    update far;

    Test.startTest();
    //WHEN the external id update batch class is executed
    CCRMUpdateFARExternalIdBatch externalIdBatch = new CCRMUpdateFARExternalIdBatch();
    Database.executeBatch(externalIdBatch);

    Test.stopTest();

    FinServ__FinancialAccountRole__c financialAccountRole = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM FinServ__FinancialAccountRole__c
      WHERE External_Id__c != NULL
      LIMIT 1
    ];
    //THEN the external id is copied to temporary field and updated to new transformed value
    System.assertEquals(
      financialAccountRole.External_Id__c,
      financialAccountRole.Temporary_External_Id__c.substringAfter('_'),
      'External ID update is not successful'
    );
  }

  @isTest
  public static void testExternalIdRevertOnFAR() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1234567891';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '1234567891_CAP-CIS_9876543219';
    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 200;
    finAccount.FinServ__CurrentPostedBalance__c = 200;
    finAccount.FinServ__Status__c = 'Active';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = '342490981';
    finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');

    insert finAccount;

    FinServ__FinancialAccountRole__c far = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM FinServ__FinancialAccountRole__c
      LIMIT 1
    ];

    far.External_Id__c = '1234567896_CAP-CIS_9876543219';
    update far;

    //GIVEN a financial account record
    FinServ__FinancialAccountRole__c financialAccountRole = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM FinServ__FinancialAccountRole__c
      WHERE External_Id__c != NULL
      LIMIT 1
    ];
    financialAccountRole.Temporary_External_Id__c = financialAccountRole.External_Id__c;
    financialAccountRole.External_Id__c = financialAccountRole.External_Id__c.substringAfter(
      '_'
    );
    update financialAccountRole;

    Test.startTest();
    //WHEN the external id update batch class is executed
    CCRMRevertFARExternalIdBatch revertExternalIdBatch = new CCRMRevertFARExternalIdBatch();
    Database.executeBatch(revertExternalIdBatch);

    Test.stopTest();

    financialAccountRole = [
      SELECT Id, External_Id__c, Temporary_External_Id__c
      FROM FinServ__FinancialAccountRole__c
      WHERE External_Id__c != NULL
      LIMIT 1
    ];
    //THEN the external id is copied to temporary field and updated to new transformed value
    System.assertEquals(
      financialAccountRole.Temporary_External_Id__c,
      financialAccountRole.External_Id__c,
      'External ID revert is not successful'
    );
  }
}
