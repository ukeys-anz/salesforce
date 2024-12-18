/**
 * @description       : Test Class for CaseEventActionsTest
 * @author            : Smruti Khobragade | Salesforce
 * @last modified on  : 12-01-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/
@isTest
public with sharing class BrokerEnquiryCaseEventActionsTest {
  static Lib_MockProvider brokerRepoMock = Lib_MockProvider.forType(
    BrokerSettingRepository.class
  );
  /*
   * @description unit test for publishCaseEvent
   */
  @isTest
  static void testPublishCaseEvent() {
    BrokerSettings__c brokerCustomSetting = createBrokerSettingRecord();
    brokerRepoMock.mock('getBrokerSettings', brokerCustomSetting);
    List<Case> caseList = createTestCases(2);
    Map<Id, Case> oldMap = convertRecordsToOldMap(caseList);
    Test.startTest();
    List<Cloud_Event__e> cloudEvents = BrokerEnquiryCaseEventActions.publishCaseEvent(
      caseList,
      oldMap,
      'update'
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      cloudEvents.size(),
      '2 case cloud event model instances should be created'
    );
  }

  /*
   * @description unit test for generateCustomerCEModel
   */
  @isTest
  static void testGenerateCaseCEModel() {
    List<Case> caseList = createTestCases(2);
    Test.startTest();
    Map<Id, List<BrokerCloudEventModel.MasterNode>> result = BrokerEnquiryCaseEventActions.generateCaseCEModel(
      caseList
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      result.size(),
      '2 case cloud events model should have been returned'
    );
  }
  /*
   * @description unit test for generateCloudEventModel
   */
  @isTest
  static void testGenerateCloudEventModel() {
    List<Case> caseList = createTestCases(1);
    String caseRecordJson = JSON.serialize(caseList[0]);
    Map<String, Object> caseRecordMap = (Map<String, Object>) JSON.deserializeUntyped(
      caseRecordJson
    );
    caseRecordMap.put(
      'CaseNumber',
      (String.valueOf(Math.random()).remove('.')).subString(0, 6)
    );
    String updatedCaseRecordJson = JSON.serialize(caseRecordMap);
    Case updatedCaseRecord = (Case) JSON.deserialize(
      updatedCaseRecordJson,
      Case.class
    );
    List<Case> updatedCaseList = new List<Case>{ updatedCaseRecord };
    Map<Id, List<BrokerCloudEventModel.MasterNode>> masterNodes = BrokerEnquiryCaseEventActions.generateCaseCEModel(
      updatedCaseList
    );
    Test.startTest();
    List<BrokerCloudEventModel> result = BrokerEnquiryCaseEventActions.generateCloudEventModel(
      updatedCaseList,
      masterNodes,
      'update'
    );
    Test.stopTest();
    Assert.areEqual(
      'Broker/' + updatedCaseList[0].External_Case_Id__c,
      result[0].ce_xtargets,
      'The external Id should be the same as the case external Id'
    );
    Assert.areEqual(
      'Case/' + updatedCaseList[0].CaseNumber,
      result[0].ce_subject,
      'The Subject should be the same as the case Subject'
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
    BrokerSettings__c brokerCustomSetting = new BrokerSettings__c();
    brokerCustomSetting.Name = 'Default';
    brokerCustomSetting.BypassCaseSyncEvents__c = false;
    brokerCustomSetting.Id = Lib_FakeIdGenerator.getMockId(
      BrokerSettings__c.SObjectType
    );
    return brokerCustomSetting;
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
      caseRec.External_Case_ID__c = (String.valueOf(Math.random()).remove('.'))
        .subString(0, 6);
      caseList.add(caseRec);
    }
    return caseList;
  }
}
