/**
 * @author Saurabh Chauhan
 * @since 8 Apr 2025
 * @description test class for OfficeGroupTriggerHandler
 */
@isTest
public with sharing class OfficeGroupTriggerHandlerTest {
  private static final Lib_MockProvider BROKER_RELATION_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );

  private static List<Broker_Relation__c> createOfficeGroupList() {
    List<Broker_Relation__c> officeGroupList = new List<Broker_Relation__c>();
    Broker_Relation__c officeGroup = new Broker_Relation__c();
    officeGroup.Id = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    officeGroup.RecordTypeId = RTBrokerRelation.officeGroup;
    officeGroup.Name = 'Office Group 1';
    officeGroup.Associated_Broker_Set__c = null;
    officeGroupList.add(officeGroup);
    return officeGroupList;
  }

  @IsTest
  private static void testIsValidRecordPositive() {
    Broker_Relation__c officeGroup = new Broker_Relation__c();
    officeGroup.Id = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    officeGroup.RecordTypeId = RTBrokerRelation.officeGroup;

    Test.startTest();
    OfficeGroupTriggerHandler handler = new OfficeGroupTriggerHandler();
    Boolean isBrokerRelation = handler.isValidRecord(officeGroup);
    Test.stopTest();

    Assert.isTrue(isBrokerRelation, 'Should return true for Broker Set');
  }

  @IsTest
  private static void testIsValidRecordNegative() {
    Broker_Relation__c brokerSet = new Broker_Relation__c();
    brokerSet.Id = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    brokerSet.RecordTypeId = RTBrokerRelation.brokerSet;

    Test.startTest();
    OfficeGroupTriggerHandler handler = new OfficeGroupTriggerHandler();
    Boolean isBrokerRelation = handler.isValidRecord(brokerSet);
    Test.stopTest();

    Assert.isFalse(isBrokerRelation, 'Should return false for Broker Set');
  }

  @isTest
  private static void testOnBeforeUpdate() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getBrokerMapOfficeGroup',
      createOfficeGroupList()
    );
    Broker_Relation__c oldOfficeGroup = createOfficeGroupList()[0];
    Broker_Relation__c newOfficeGroup = new Broker_Relation__c();
    newOfficeGroup.Id = oldOfficeGroup.Id;
    newOfficeGroup.Associated_Broker_Set__c = oldOfficeGroup.Id;

    OfficeGroupTriggerHandler handler = new OfficeGroupTriggerHandler();
    handler.records = new List<Broker_Relation__c>{ newOfficeGroup };
    handler.onBeforeUpdate(
      new Map<Id, Broker_Relation__c>{ oldOfficeGroup.Id => oldOfficeGroup }
    );
    Assert.isNotNull(
      newOfficeGroup.Associated_Broker_Set__c,
      'Broker Association should be there'
    );
  }
}
