/**
 * @author Shivam Swaraj
 * @since September 2023
 * @description Test class for FInancialAccountService
 */

@isTest
public with sharing class FinancialAccountServiceTest {
  @TestSetup
  static void setup() {
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
    financialAccountsList[0].Source_System_Status__c = 'CAPCISOP';

    financialAccountsList[1].FinServ__PrimaryOwner__c = testAccount.Id;
    financialAccountsList[1].FinServ__Status__c = 'Closed';
    financialAccountsList[1].FinServ__FinancialAccountNumber__c = '342490982';
    financialAccountsList[1].Source_System_Status__c = 'CAPCISOP';

    insert financialAccountsList;

    FinServ__FinancialAccountRole__c financialAccountRoleRecord = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = testAccount.Id,
      FinServ__FinancialAccount__c = financialAccountsList[0].Id,
      FinServ__Active__c = true,
      Finserv__Role__c = 'Additional Owner'
    );
    insert financialAccountRoleRecord;
  }

  @isTest
  static void testValidFetchFinancialAccountsByStatus() {
    List<String> statusList = new List<String>{
      GetHelpConstants.CLOSED_STATUS
    };

    List<FinServ__FinancialAccount__c> financialAccountList = FinancialAccountService.fetchFinancialAccountsByStatus(
      'OCVID887766',
      statusList
    );
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
    List<FinServ__FinancialAccount__c> financialAccountList = FinancialAccountService.fetchFinancialAccountsByStatus(
      'OCVID88776',
      statusList
    );

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

    Map<String, List<String>> financialAccountNumbersMapByStatus = FinancialAccountService.getAccountNumbersByStatusMap(
      financialAccountList
    );

    System.assertEquals(
      2,
      financialAccountNumbersMapByStatus.get(GetHelpConstants.CLOSED_STATUS)
        .size(),
      'financialAccountNumberList size should be  as expected'
    );
  }
}
