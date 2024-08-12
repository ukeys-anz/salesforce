/**
 * @description       : Test Class for CustomerGCPActions
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 08-05-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
@isTest
public with sharing class CustomerGCPActionsTest {
  private static final String PERSONACC_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();

  /*
   * @description unit test for filterAccountsBasedOnSyncStatus
   */
  @isTest
  static void filterAccountsBasedOnSyncStatusTest() {
    List<Account> accList = createCustomerAccount(2);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    for (Account acc : oldMap.values()) {
      acc.Sync_Status__c = 'Broker Org';
    }
    accList[0].Sync_Status__c = 'Blocked';
    accList[1].Sync_Status__c = 'Broker Org';

    Test.startTest();
    List<Account> result = CustomerGCPActions.filterAccountsBasedOnSyncStatus(
      accList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Valid Account number is 1');
  }

  /*
   * @description unit test for filterAccountsBasedonOCVVersion
   */
  @isTest
  static void filterAccountsBasedonOCVVersionTest() {
    List<Account> accList = createCustomerAccount(1);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Account acc = accList[0];
    acc.OCV_Event_Version__c = 2;

    Account oldAcc = oldMap.get(acc.id);
    oldAcc.OCV_Event_Version__c = 1;

    Test.startTest();
    List<Account> result = CustomerGCPActions.filterAccountsBasedonOCVVersion(
      accList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Expected One Valid OCV Version Account');
  }

  /*
   * @description unit test for generateCustomerCEModelBundle
   */
  @isTest
  static void generateCustomerCEModelBundleTest() {
    List<Account> accList = createCustomerAccount(2);
    Test.startTest();
    Map<Id, List<BrokerCloudEventModel.MasterNode>> result = CustomerGCPActions.generateCustomerCEModelBundle(
      accList
    );
    Test.stopTest();
    Assert.areEqual(2, result.size(), 'Publish event failed');
  }

  /*
   * @description unit test for publishGCPEventForCustomers
   */
  @isTest
  static void publishGCPEventForCustomersTest() {
    List<Account> accList = createCustomerAccount(2);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Account acc = accList[0];
    acc.OCV_Event_Version__c = 1;
    acc.Sync_Status__c = 'Broker Org';

    for (Account oldAcc : oldMap.values()) {
      oldAcc.OCV_Event_Version__c = 0;
      oldAcc.Sync_Status__c = 'Broker Org';
    }
    Test.startTest();
    CustomerGCPActions.publishGCPEventForCustomers(accList, oldMap, 'update');
    Test.stopTest();
  }

  /*
   * @description Test Method to create test Customers
   */
  static List<Account> createCustomerAccount(Integer count) {
    List<Account> accList = new List<Account>();
    for (Integer i = 0; i < count; i++) {
      Account acc = TestDataFactory.createAccount(false);
      acc.External_Id__c = 'Test0001' + i;
      acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
      acc.RecordTypeId = PERSONACC_RECORDTYPEID;
      accList.add(acc);
    }
    return accList;
  }

  /*
   * @description Test Method to create Record oldMap
   */
  static Map<Id, Account> convertRecordsToOldMap(List<Account> accList) {
    List<Account> oldAccList = accList.deepClone(true);
    return new Map<Id, Account>(oldAccList);
  }
}
