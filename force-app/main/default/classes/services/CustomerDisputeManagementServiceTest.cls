/**
 * @author Shivam Swaraj
 * @since 02/2024
 * @description CustomerDisputeManagementServiceTest is the test class for CustomerDisputeManagementService Class functionality.
 */
@isTest
public with sharing class CustomerDisputeManagementServiceTest {
  private static final Id NPP_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('NPP_Dispute')
    .getRecordTypeId();

  @TestSetup
  static void setup() {
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    Map<String, User> userMap = new Map<String, User>();
    System.runAs(thisUser) {
      /*----------Create users for tests----------*/

      Profile integrationProfile = CommonUtil.getProfileByName(
        'Integration User'
      );
      UserRole anzxRole = CommonUtil.getUserRoleByDevName('ANZx');

      // Create an Integration User
      User integrationUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'IntegrationTest',
          'ProfileId' => integrationProfile.Id,
          'UserRoleId' => anzxRole.Id
        }
      );
      userMap.put('integrationUser', integrationUser);

      insert userMap.values();

      /*----------Assign permission sets to users----------*/

      // Integration User permission sets
      List<String> integrationPsets = new List<String>{
        'View_And_Edit_Tasks',
        'Case_Read_Write_Get_Help',
        'Case_Read_Write_Dispute',
        'Customer_Dispute_Management_Read_Write',
        'Read_Only_Admin'
      };

      List<PermissionSet> integrationPsList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :integrationPsets
      ];

      List<PermissionSetAssignment> integrationPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : integrationPsList) {
        integrationPsaList.add(
          TestUtil.createPSAssignment(userMap.get('integrationUser').Id, ps.Id)
        );
      }
      insert integrationPsaList;
    }

  }

  @isTest
  private static void testHandleCustomerDisputeManagementActionsPositive() {
    User integrationUser = TestUtil.getUserByFirstName('IntegrationTest');
    List<Case> oldNppCases = createMockDisputeCases('false', 'App');
    List<Case> newNppCases = createMockDisputeCases('true', 'App');

    Map<Id, Case> oldMapOfCases = new Map<Id, Case>{
      oldNppCases.get(0).Id => oldNppCases.get(0)
    };

    Test.startTest();
    System.runAs(integrationUser) {
        CustomerDisputeManagementService.handleCustomerDisputeManagementActions(
          newNppCases,
          oldMapOfCases
        );
    }
    Test.stopTest();
  }

  @isTest
  private static void testHandleCustomerDisputeManagementActionsNegative() {
    User integrationUser = TestUtil.getUserByFirstName('IntegrationTest');
    List<Case> newNppCases = createMockDisputeCases('true', 'Store');
    Test.startTest();
    System.runAs(integrationUser) {
      try {
        CustomerDisputeManagementService.handleCustomerDisputeManagementActions(
          newNppCases,
          null
        );
      } catch (Exception e) {
        System.assertEquals(
          'Attempt to de-reference a null object',
          e.getMessage(),
           'Error in Customer Dispute Management Service'
        );
      }
    }

    Test.stopTest();
  }

  @isTest
  private static void testfilterCasesAndReturnUniqueCustomerIdsNegative() {
    List<Case> oldNppCases = createMockDisputeCases('false', 'App');
    List<Case> newNppCases = createMockDisputeCases('false', 'App');

    Map<Id, Case> oldMapOfCases = new Map<Id, Case>{
      oldNppCases.get(0).Id => oldNppCases.get(0)
    };

    Test.startTest();
    Set<Id> customerids = CustomerDisputeManagementService.filterCasesAndReturnUniqueCustomerIds(
      newNppCases,
      oldMapOfCases
    );
    Test.stopTest();

    System.assertEquals(
      true,
      customerids.isEmpty(),
      'Customer Ids should be empty when there no change in IsClosed'
    );
  }

  @isTest
  private static void testfilterCasesAndReturnUniqueCustomerIdsPositive() {
    List<Case> oldNppCases = createMockDisputeCases('false', 'App');
    List<Case> newNppCases = createMockDisputeCases('true', 'App');

    Map<Id, Case> oldMapOfCases = new Map<Id, Case>{
      oldNppCases.get(0).Id => oldNppCases.get(0)
    };

    Test.startTest();
    Set<Id> customerids = CustomerDisputeManagementService.filterCasesAndReturnUniqueCustomerIds(
      newNppCases,
      oldMapOfCases
    );
    Test.stopTest();

    System.assertEquals(
      true,
      !customerids.isEmpty(),
      'Customer Ids should not be empty when there is change in IsClosed'
    );
  }

  @isTest
  private static void testSetCdmBlockFlagsPositive() {
    Customer_Dispute_Management__c mockCdmRecord = createMockCdmRecord();

    Test.startTest();
    Customer_Dispute_Management__c cdmToBeUpserted = CustomerDisputeManagementService.setCdmBlockFlags(
      4,
      mockCdmRecord
    );
    Test.stopTest();

    System.assertEquals(
      true,
      !cdmToBeUpserted.Temporary_Block__c,
      'Temporary_Block__c will be false because active case count is less than 5'
    );
    System.assertEquals(
      true,
      !cdmToBeUpserted.Temporary_Block_Overridden__c,
      'Temporary_Block_Overridden__c will be false because Temporary_Block__c is disabled'
    );
  }

  @isTest
  private static void testSetCdmBlockFlagsNegative() {
    Test.startTest();
    Customer_Dispute_Management__c cdmToBeUpserted = CustomerDisputeManagementService.setCdmBlockFlags(
      5,
      null
    );
    Test.stopTest();

    System.assertEquals(
      true,
      cdmToBeUpserted.Temporary_Block__c,
      'Temporary_Block__c will be true because active case count is greater than or equal to 5'
    );
    System.assertEquals(
      true,
      !cdmToBeUpserted.Temporary_Block_Overridden__c,
      'Temporary_Block_Overridden__c will remain same as default value i.e false'
    );
  }

  @isTest
  private static void testUpsertCDMRecordsAndReturnUpsertedListPositive() {
    List<Account> accountList = createMockPersonAccount();

    Test.startTest();
    List<Database.UpsertResult> cdmUpsertedResult = CustomerDisputeManagementService.upsertCDMRecordsAndReturnUpsertedList(
      accountList
    );
    Test.stopTest();

    System.assertEquals(
      true,
      cdmUpsertedResult.size() > 0,
      'CDM record should be upserted successfully'
    );
  }

  @isTest
  private static void testUpsertCDMRecordsAndReturnUpsertedListNegative() {
    List<Account> accountList = createMockPersonAccount();
    accountList[0].Customer_Dispute_Management__c = null;

    Test.startTest();
    List<Database.UpsertResult> cdmUpsertedResult = CustomerDisputeManagementService.upsertCDMRecordsAndReturnUpsertedList(
      accountList
    );
    Test.stopTest();

    System.assertEquals(
      true,
      cdmUpsertedResult.size() > 0,
      'CDM record should be upserted successfully'
    );
  }

  @isTest
  private static void testGetAccountsWithMissingCDMPositive() {
    List<Account> accountList = createMockPersonAccount();
    accountList[0].Customer_Dispute_Management__c = null;

    Test.startTest();
    List<Database.UpsertResult> cdmUpsertedResult = CustomerDisputeManagementService.upsertCDMRecordsAndReturnUpsertedList(
      accountList
    );
    List<Account> accountToBeUpdated = CustomerDisputeManagementService.getAccountsWithMissingCDM(
      accountList,
      cdmUpsertedResult
    );
    Test.stopTest();

    System.assertEquals(
      true,
      accountToBeUpdated.size() > 0,
      'Update Accounts To Link CDM should not be empty'
    );
  }

  @isTest
  private static void testGetAccountsWithMissingCDMNegative() {
    List<Account> accountList = createMockPersonAccount();

    Test.startTest();
    List<Database.UpsertResult> cdmUpsertedResult = CustomerDisputeManagementService.upsertCDMRecordsAndReturnUpsertedList(
      accountList
    );
    List<Account> accountToBeUpdated = CustomerDisputeManagementService.getAccountsWithMissingCDM(
      accountList,
      cdmUpsertedResult
    );
    Test.stopTest();

    System.assertEquals(
      true,
      accountToBeUpdated.size() == 0,
      'Update Accounts To Link CDM should be empty'
    );
  }

  private static List<Case> createMockDisputeCases(
    String isClosed,
    String origin
  ) {
    String strDisputeCase =
      '[{"attributes":{"type":"Case","url":"/services/data/v60.0/sobjects/Case/500AD00000DYbnKYAT"},"Id":"500AD00000DYbnKYAT","RecordTypeId":"' +
      NPP_DISPUTE_RT_ID +
      '","Origin":"' +
      origin +
      '","IsClosed":"' +
      isClosed +
      '","AccountId":"001AD00000LwiSoYAJ"}]';
    List<Case> disputeCasesList = (List<Case>) JSON.deserialize(
      strDisputeCase,
      List<Case>.class
    );
    return disputeCasesList;
  }

  private static List<Account> createMockPersonAccount() {
    String strPersonAccount =
      '[{"attributes":{"type":"Account","url":"/services/data/v60.0/sobjects/Account/001AD00000LwwkHYAR"},"Id":"001AD00000LwwkHYAR","Customer_Dispute_Management__c":"a20AD000000FwwXYAS","Cases":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Case","url":"/services/data/v60.0/sobjects/Case/500AD00000E6TIcYAN"},"AccountId":"001AD00000LwwkHYAR","Id":"500AD00000E6TIcYAN","IsClosed":false,"Origin":"App","RecordTypeId":"' +
      NPP_DISPUTE_RT_ID +
      '"}]},"Customer_Dispute_Management__r":{"attributes":{"type":"Customer_Dispute_Management__c","url":"/services/data/v60.0/sobjects/Customer_Dispute_Management__c/a20AD000000FwwXYAS"},"Id":"a20AD000000FwwXYAS","Temporary_Block__c":true}}]';
    List<Account> personAccountList = (List<Account>) JSON.deserialize(
      strPersonAccount,
      List<Account>.class
    );
    return personAccountList;
  }

  private static Customer_Dispute_Management__c createMockCdmRecord() {
    String strCdmRecord = '{"attributes":{"type":"Customer_Dispute_Management__c","url":"/services/data/v60.0/sobjects/Customer_Dispute_Management__c/a20AD000000FwwXYAS"},"Id":"a20AD000000FwwXYAS","Temporary_Block__c":true,"Temporary_Block_Overridden__c":true}';
    Customer_Dispute_Management__c cdmRecordToBeUpserted = (Customer_Dispute_Management__c) JSON.deserialize(
      strCdmRecord,
      Customer_Dispute_Management__c.class
    );
    return cdmRecordToBeUpserted;
  }
}