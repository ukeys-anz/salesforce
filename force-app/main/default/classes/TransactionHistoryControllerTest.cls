/**
 *
 * @author Lance Shi
 * @since 04/2020
 * @description TransactionHistoryControllerTest is the test class to cover tests for {@link TransactionHistoryController}
 */
@isTest
public with sharing class TransactionHistoryControllerTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addAccountsGoalsPs();
  }

  /**
   * @description test method for getDisputeRecordTypeMap
   */
  @isTest
  public static void testGetDisputeRecordTypeMap() {
    Test.startTest();
    String recordTypesString = TransactionHistoryController.getDisputeRecordTypeMap();
    Test.stopTest();
    Map<String, RecordType> disputeRecordTypeMap = (Map<String, RecordType>) JSON.deserialize(
      recordTypesString,
      Map<String, RecordType>.class
    );
    System.assertNotEquals(
      0,
      disputeRecordTypeMap.size(),
      'Dispute record types are returned'
    );
  }

  /*
   * @description test method for getPersonAccount
   */
  @isTest
  public static void testGetPersonAccount() {
    String recTypeId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'
    ]
    .Id;

    Account acc = new Account(
      RecordTypeId = recTypeId,
      FirstName = 'Steve',
      LastName = 'Rogers',
      OCV_ID__c = '123456',
      External_Id__c = 'a#@sjaf0832'
    );
    insert acc;
    FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
      Name = 'Savings Account',
      FinServ__PrimaryOwner__c = acc.Id,
      Account_Key__c = 'b#2fa8s0'
    );
    insert finAcc;
    Test.startTest();
    Map<String, Object> returnMap = TransactionHistoryController.getPersonAccount(
      finAcc.Id
    );
    Test.stopTest();
    System.assertEquals(
      acc.Id,
      returnMap.get('AccountId'),
      'Person Account Id was retrieved'
    );
  }
}
