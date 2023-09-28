/**
 * @author Shivam Swaraj
 * @since September 2023
 * @description Test class for FInancialAccountService
 */

@isTest
public with sharing class FinancialAccountServiceTest {
  @TestSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');

    System.runAs(TestDataFactory.thisUser) {
      // Create coach user
      User coachUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'FinancialAccountTestCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coachUser;

      // Assign Coach User
      List<String> psNames = new List<String>{
        'Financial_Accounts_Read_and_Edit',
        'FinancialServicesCloudStandard',
        'FinancialServicesCloudExtension'
      };

      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :psNames
      ];

      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(coachUser.id, ps.Id));
      }
      insert psaList;

      Account testAccount = TestDataFactory.createPersonAccount(
        'OCVID887766',
        true
      );
      List<FinServ__FinancialAccount__c> financialAccountsList = TestDataFactory.createFinancialAccount(
        2,
        false
      );
      financialAccountsList[0].FinServ__PrimaryOwner__c = testAccount.Id;
      financialAccountsList[0].FinServ__Status__c = 'Closed';
      financialAccountsList[0].FinServ__FinancialAccountNumber__c = '342490981';

      financialAccountsList[1].FinServ__PrimaryOwner__c = testAccount.Id;
      financialAccountsList[1].FinServ__Status__c = 'Closed';
      financialAccountsList[1].FinServ__FinancialAccountNumber__c = '342490982';

      Test.startTest();
      insert financialAccountsList;
      Test.stopTest();
    }

  }

  @isTest
  static void testValidFetchFinancialAccountsByStatus() {
    List<String> statusList = new List<String>{
      GetHelpConstants.CLOSED_STATUS
    };

    List<FinServ__FinancialAccount__c> financialAccountList = new List<FinServ__FinancialAccount__c>();
    User coachUser = TestUtil.getUserByFirstName(
      'FinancialAccountTestCoachUser'
    );
    System.runAs(coachUser) {
      Test.startTest();
      financialAccountList = FinancialAccountService.fetchFinancialAccountsByStatus(
        'OCVID887766',
        statusList
      );
      Test.stopTest();
    }
    System.assertEquals(
      2,
      financialAccountList.size(),
      'financialAccountList size should be as expected'
    );
  }

  @isTest
  static void testInValidFetchFinancialAccountsByStatus() {
    List<String> statusList = new List<String>{
      GetHelpConstants.CLOSED_STATUS
    };
    List<FinServ__FinancialAccount__c> financialAccountList = new List<FinServ__FinancialAccount__c>();
    User coachUser = TestUtil.getUserByFirstName(
      'FinancialAccountTestCoachUser'
    );

    System.runAs(coachUser) {
      Test.startTest();
      financialAccountList = FinancialAccountService.fetchFinancialAccountsByStatus(
        'OCVID88776',
        statusList
      );
      Test.stopTest();
    }

    System.assertEquals(
      0,
      financialAccountList.size(),
      'financialAccountList size should be as expected'
    );
  }

  @isTest
  static void testGetAccountNumbersByStatusMap() {
    User coachUser = TestUtil.getUserByFirstName(
      'FinancialAccountTestCoachUser'
    );

    List<FinServ__FinancialAccount__c> financialAccountList = [
      SELECT FinServ__FinancialAccountNumber__c, FinServ__Status__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__PrimaryOwner__r.OCV_ID__c = 'OCVID887766'
    ];

    Map<String, List<String>> financialAccountNumbersMapByStatus = new Map<String, List<String>>();
    System.runAs(coachUser) {
      Test.startTest();
      financialAccountNumbersMapByStatus = FinancialAccountService.getAccountNumbersByStatusMap(
        financialAccountList
      );
      Test.stopTest();
    }

    System.assertEquals(
      2,
      financialAccountNumbersMapByStatus.get(GetHelpConstants.CLOSED_STATUS)
        .size(),
      'financialAccountNumberList size should be  as expected'
    );
  }
}
