/**
 * @description       : Test Class for CaseEventActionsTest
 * @author            : Smruti Khobragade | Salesforce
 * @last modified on  : 12-13-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/
@isTest
public with sharing class BrokerRequestHelpCaseEventActionsTest {
  static Lib_MockProvider brokerRepoMock = Lib_MockProvider.forType(
    BrokerSettingRepository.class
  );
  /*
   * @description unit test for publishEventForCustomers
   */
  @isTest
  static void testPublishEventForCase() {
    BrokerSettings__c brokerCustomSetting = createBrokerSettingRecord();
    brokerRepoMock.mock('getBrokerSettings', brokerCustomSetting);
    List<Case> caseList = createTestCases(2);
    Map<Id, Case> oldMap = convertRecordsToOldMap(caseList);
    Test.startTest();
    List<Cloud_Event__e> cloudEvents = BrokerRequestHelpCaseEventActions.publishEventForCase(
      caseList,
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
   * @description unit test for generateCustomerCEModel
   */
  @isTest
  static void testGenerateCaseCEModel() {
    List<Case> caseList = createTestCases(2);
    Test.startTest();
    Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> result = BrokerRequestHelpCaseEventActions.generateCaseCEModel(
      caseList
    );
    Test.stopTest();
    Assert.areEqual(2, result.size(), 'Publish event failed');
  }
  /*
   * @description unit test for generateCloudEventModel
   */
  @isTest
  static void testGenerateCloudEventModel() {
    List<Case> caseList = createTestCases(1);
    Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> masterNodes = BrokerRequestHelpCaseEventActions.generateCaseCEModel(
      caseList
    );
    Test.startTest();
    List<BrokerRequestHelpCaseCloudEventModel> result = BrokerRequestHelpCaseEventActions.generateCloudEventModel(
      caseList,
      masterNodes,
      'update'
    );
    Test.stopTest();
    Assert.areEqual(
      'Broker/' + caseList[0].External_Case_Id__c,
      result[0].ce_xtargets,
      'The external Id should be the same as the case external Id'
    );
  }

  /*
   * @description Test Method to create Record oldMap
   */
  static Map<Id, Case> convertRecordsToOldMap(List<Case> caseList) {
    List<Case> oldCaseList = caseList.deepClone(true);
    for (Case caseRec : oldCaseList) {
      caseRec.Description = 'Test Description';
    }
    return new Map<Id, Case>(oldCaseList);
  }
  /*
   * @description Test Method to create BrokerSetting record
   */
  static BrokerSettings__c createBrokerSettingRecord() {
    BrokerSettings__c brokerCustomSettting = new BrokerSettings__c();
    brokerCustomSettting.Name = 'Default';
    brokerCustomSettting.BypassCaseSyncEvents__c = false;
    brokerCustomSettting.Id = Lib_FakeIdGenerator.getMockId(
      BrokerSettings__c.SObjectType
    );
    return brokerCustomSettting;
  }

  /*
   * @description Test Method to create test cases
   */
  static List<Case> createTestCases(Integer count) {
    List<Case> caseList = new List<Case>();
    for (Integer i = 0; i < count; i++) {
      Case caseRec = new Case();
      caseRec.Sync_Status__c = 'Broker Org';
      caseRec.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRec.RecordTypeId = RTCase.brokerEnquiry;
      caseRec.Description = 'Test';
      caseRec.Origin = 'Email';
      caseRec.Status = 'Open';
      caseRec.Subject = 'Testing 001';
      caseList.add(caseRec);
    }
    return caseList;
  }
}
