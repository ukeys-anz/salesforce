/**
 * @description       :
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

  @isTest
  static void filterAccountsBasedOnSyncStatusTest() {
    List<Account> accList = createCustomerAccount(2);
    accList[0].Sync_Status__c = 'Blocked';
    accList[1].Sync_Status__c = 'Broker Org';

    Test.startTest();
    List<Account> result = CustomerGCPActions.filterAccountsBasedOnSyncStatus(
      accList
    );
    Test.stopTest();
    Assert.areEqual(result.size(), 1, 'Valid Account number is 1');
  }

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
    Assert.areEqual(result.size(), 1, 'Expected One Valid OCV Version Account');
  }

  @isTest
  static void generateCustomerCEModelBundleTest() {
    List<Account> accList = createCustomerAccount(2);
    Test.startTest();
    Map<Id, List<BrokerCloudEventModel.MasterNode>> result = CustomerGCPActions.generateCustomerCEModelBundle(
      accList
    );
    Test.stopTest();
    //Assert.areEqual(result.size(), 'Publish event failed');
  }

  @isTest
  static void publishGCPEventForCustomersTest() {
    List<Account> accList = createCustomerAccount(2);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Test.startTest();
    List<SObject> successEvents = CustomerGCPActions.publishGCPEventForCustomers(
      accList,
      oldMap,
      'update'
    );
    Test.stopTest();
    Assert.areEqual(
      accList.size(),
      successEvents.size(),
      'The size of success events should be the same as the input size'
    );
  }

  static List<Account> createCustomerAccount(Integer count) {
    List<Account> accList = new List<Account>();
    for (Integer i = 0; i < count; i++) {
      Account acc = TestDataFactory.createAccount(false);
      acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
      acc.RecordTypeId = PERSONACC_RECORDTYPEID;
      accList.add(acc);
    }
    return accList;
  }

  static Map<Id, Account> convertRecordsToOldMap(List<Account> accList) {
    List<Account> oldAccList = accList.deepClone(true);
    return new Map<Id, Account>(oldAccList);
  }
}
