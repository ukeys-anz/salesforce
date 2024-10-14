/**
 * @description       : Test Class for CustomerEventActions
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 10-08-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
@isTest
public with sharing class CustomerEventActionsTest {
  private static final Id PERSONACC_RECORDTYPEID = QueryRT.of(
      Account.SObjectType
    )
    .getId('PersonAccount');

  /*
   * @description unit test for filterOCVVersionUpdate
   */
  @isTest
  static void filterOCVVersionUpdateTest() {
    List<Account> accList = createCustomerAccount(1);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Test.startTest();
    List<Account> result = CustomerEventActions.filterOCVVersionUpdate(
      accList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Expected One Valid OCV Version Account');
    Assert.areEqual(
      1,
      result[0].OCV_Event_Version__c,
      'Expected version of OCV is 1'
    );
  }

  /*
   * @description unit test for generateCustomerCEModel
   */
  @isTest
  static void generateCustomerCEModelTest() {
    List<Account> accList = createCustomerAccount(2);
    Test.startTest();
    Map<Id, List<BrokerCloudEventModel.MasterNode>> result = CustomerEventActions.generateCustomerCEModel(
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
    CustomerEventActions.mockBrokerSettings = new BrokerSettings__c(
      BypassCustomerSyncEvents__c = false
    );
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
    Map<Id, List<BrokerCloudEventModel.MasterNode>> masterNodes = CustomerEventActions.generateCustomerCEModel(
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
