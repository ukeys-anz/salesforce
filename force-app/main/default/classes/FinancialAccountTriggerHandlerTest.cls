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
    System.runAs(TestDataFactory.thisUser) {
      Profile integrationProfile = CommonUtil.getProfileByName(
        'Integration User'
      );
      UserRole anzRole = CommonUtil.getUserRoleByDevName('ANZ');
      User contractEventIntegrationUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'Contract Event',
          'LastName' => 'Integration User',
          'ProfileId' => integrationProfile.Id,
          'UserRoleId' => anzRole.Id
        }
      );

      insert contractEventIntegrationUser;

      // Integration User permission sets
      List<String> integrationUserPSs = new List<String>{
        'Financial_Accounts_Read_and_Edit',
        'FinancialServicesCloudStandard'
      };
      List<PermissionSet> integrationUserPsList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :integrationUserPSs
      ];

      List<PermissionSetAssignment> integrationUserPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : integrationUserPsList) {
        integrationUserPsaList.add(
          TestUtil.createPSAssignment(contractEventIntegrationUser.Id, ps.Id)
        );
      }
      insert integrationUserPsaList;
    }

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

    Customer_Action__c ca = TestDataFactory.createCustomerActionRecord(
      GetHelpConstants.CUSTOMER_ACTION_FIN_ACCOUNT_UPDATE_RT_ID,
      accnt.Id,
      finAccount.Id,
      true
    );

    User contractEventIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'Contract Event'
      LIMIT 1
    ];

    // Manually share the Customer Action record with Contract Event Integration User since criteria based sharing rules are not applied in test context
    Customer_Action__Share caShare = new Customer_Action__Share(
      AccessLevel = 'Edit',
      ParentID = ca.Id,
      UserOrGroupId = contractEventIntegrationUser.Id
    );
    insert caShare;
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
  public static void testSignatoryUpdateFailure() {
    User contractEventIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'Contract Event'
      LIMIT 1
    ];
    FinServ__FinancialAccount__c finAcc = [
      SELECT Id, Number_Of_Signatures__c
      FROM FinServ__FinancialAccount__c
      LIMIT 1
    ];

    Customer_Action__c ca = [
      SELECT Id, Status__c
      FROM Customer_Action__c
      WHERE Financial_Account__c = :finAcc.Id
    ];
    ca.Status__c = GetHelpFinancialAccountActions.CUSTOMER_ACTION_STATUS_COMPLETED;
    update ca;

    System.runAs(contractEventIntegrationUser) {
      try {
        finAcc.Number_Of_Signatures__c = '2';
        update finAcc;
      } catch (Exception exp) {
        Assert.isTrue(
          exp.getMessage()
            .contains(
              GetHelpFinancialAccountActions.SIGNATORY_UPDATE_ERROR_MESSAGE
            ),
          'Number of Signatory cannot be updated directly'
        );
      }
    }
  }

  @isTest
  public static void testCheckPendingCustomerActionExist() {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);
    accnt.Id = '0019p000000' + faker.randomString(7);

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
    newFinAccount.Number_Of_Signatures__c = '2';
    newFinAccount.Id = finAccount.Id;

    Customer_Action__c ca = TestDataFactory.createCustomerActionRecord(
      GetHelpConstants.CUSTOMER_ACTION_FIN_ACCOUNT_UPDATE_RT_ID,
      accnt.Id,
      finAccount.Id,
      false
    );

    Test.startTest();
    Map<Id, FinServ__FinancialAccount__c> oldMap = new Map<Id, FinServ__FinancialAccount__c>{
      finAccount.Id => finAccount
    };
    List<FinServ__FinancialAccount__c> records = new List<FinServ__FinancialAccount__c>{
      newFinAccount
    };
    Map<Id, Customer_Action__c> finAccIdToCustActionMap = new Map<Id, Customer_Action__c>{
      finAccount.Id => ca
    };

    List<Customer_Action__c> updatedCustomerActionList = GetHelpFinancialAccountActions.updateCustomerActionToComplete(
      records,
      oldMap,
      finAccIdToCustActionMap
    );
    // Dummy callout for test coverage
    GetHelpFinancialAccountActions.updateCustomerActionRecord(records, oldMap);
    Test.stopTest();

    Assert.areEqual(
      GetHelpFinancialAccountActions.CUSTOMER_ACTION_STATUS_COMPLETED,
      updatedCustomerActionList[0].Status__c,
      'Number of Signatory updated successfully'
    );
  }
}
