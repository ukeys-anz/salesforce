/**
 * @description       : Test Class for CustomerEventActions
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 09-17-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
@isTest
public with sharing class CustomerEventActionsTest {
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
    accList[0].Sync_Status__c = 'Blocked';

    Test.startTest();
    List<Account> result = CustomerEventActions.filterAccountsBasedOnSyncStatus(
      accList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.size(),
      'Expected one account with valid sync status'
    );
  }

  /*
   * @description unit test for filterAccountsBasedonOCVVersion
   */
  @isTest
  static void filterAccountsBasedonOCVVersionTest() {
    List<Account> accList = createCustomerAccount(1);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Test.startTest();
    List<Account> result = CustomerEventActions.filterAccountsBasedonOCVVersion(
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
    Map<Id, List<BrokerCloudEventModel.MasterNode>> result = CustomerEventActions.generateCustomerCEModelBundle(
      accList
    );
    Test.stopTest();
    Assert.areEqual(2, result.size(), 'Publish event failed');
  }

  /*
   * @description unit test for publishEventForCustomers
   */
  @isTest
  static void publishEventForCustomersTest() {
    List<Account> accList = createCustomerAccount(2);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Test.startTest();
    List<Cloud_Event__e> cloudEvents = CustomerEventActions.publishEventForCustomers(
      accList,
      oldMap,
      'update'
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      cloudEvents.size(),
      '2 Cloud Event Model instances should be created'
    );
  }

  /*
   * @description unit test for generateCloudEventModel
   */
  @isTest
  static void generateCloudEventModelTest() {
    List<Account> accList = createCustomerAccount(1);
    Map<Id, List<BrokerCloudEventModel.MasterNode>> masterNodes = CustomerEventActions.generateCustomerCEModelBundle(
      accList
    );
    Test.startTest();
    List<BrokerCloudEventModel> result = CustomerEventActions.generateCloudEventModel(
      accList,
      masterNodes,
      'update'
    );
    Test.stopTest();
    Assert.areEqual(
      'Broker/' + accList[0].External_Id__c,
      result[0].ce_xtargets,
      'The external id should be the same as the customer external id'
    );
  }

  /*
   * @description Test Method to create test Customers
   */
  static List<Account> createCustomerAccount(Integer count) {
    List<Account> accList = new List<Account>();
    for (Integer i = 0; i < count; i++) {
      Account acc = TestDataFactory.createAccount(false);
      acc.External_Id__c = 'Test0001' + i;
      acc.Sync_Status__c = 'Broker Org';
      acc.OCV_Event_Version__c = 1;
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
    for (Account acc : oldAccList) {
      acc.OCV_Event_Version__c = 0;
    }
    return new Map<Id, Account>(oldAccList);
  }
}
