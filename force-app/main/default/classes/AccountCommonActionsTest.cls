/**
 * @description       :
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 07-31-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class AccountCommonActionsTest {
  private static final String PERSONACC_RECORDTYPEID = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
    .get('')
    .getRecordTypeId();

  static void validateSyncStatusTest() {
    Account acc = createCustomerAccount(1)[0];
    acc.Sync_Status__c = 'Blocked';
    Test.startTest();
    Boolean result = AccountCommonActions.validateSyncStatus(acc);
    Test.stopTest();
    Assert.isTrue(result, 'Sync Status is not Blocked');
  }

  static void validateOCVVersionTest() {
    List<Account> accList = createCustomerAccount(1);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Account acc = accList[0];
    acc.OCV_Event_Version__c = 2;

    Account oldAcc = oldMap.get(acc.id);
    oldAcc.OCV_Event_Version__c = 1;

    Test.startTest();
    Boolean result = AccountCommonActions.validateOCVVersion(acc, oldAcc);
    Test.stopTest();
    Assert.isTrue(result, 'OCV version is not valid');
  }

  static void isAccountValidForCustomerEventTest() {
    List<Account> accList = createCustomerAccount(1);
    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);
    Account acc = accList[0];
    acc.Sync_Status__c = 'Broker Org';
    acc.OCV_Event_Version__c = 2;

    Account oldAcc = oldMap.get(acc.id);
    oldAcc.OCV_Event_Version__c = 1;

    Test.startTest();
    Boolean result = AccountCommonActions.isAccountValidForCustomerEvent(
      acc,
      oldAcc
    );
    Test.stopTest();
    Assert.isTrue(result, 'Account is not valid for Customer Event');
  }

  static void filterAccountsBasedOnSyncStatusTest() {
    List<Account> accList = createCustomerAccount(2);

    Account positiveAcc = accList[0];
    positiveAcc.Sync_Status__c = 'Broker Org';
    positiveAcc.OCV_Event_Version__c = 3;

    Account negativeAcc = accList[1];
    negativeAcc.Sync_Status__c = 'Blocked';
    negativeAcc.OCV_Event_Version__c = 3;

    Map<Id, Account> oldMap = convertRecordsToOldMap(accList);

    Test.startTest();
    List<Account> resultList = AccountCommonActions.filterAccountsBasedOnSyncStatus(
      accList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      1,
      'Expected size of resultList should be 1'
    );
  }

  static void publishGCPEventForBrokersTest() {
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
    List<ResidentialLoanApplication> oldAccList = accList.deepClone(true);
    return new Map<Id, Account>(oldAccList);
  }
}
