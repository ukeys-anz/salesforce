/**
 * @author Saurabh Chauhan
 * @since 8 Apr 2025
 * @description test class for BrokerSetTriggerHandler
 */
@isTest
public class BrokerSetTriggerHandlerTest {
  private static final Lib_MockProvider BROKER_RELATION_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );

  private static List<Broker_Relation__c> createBrokerSetList() {
    List<Broker_Relation__c> brokerSetList = new List<Broker_Relation__c>();
    Broker_Relation__c brokerSet = new Broker_Relation__c();
    brokerSet.Id = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    brokerSet.RecordTypeId = RTBrokerRelation.brokerSet;
    brokerSet.Name = 'Broker Set 1';
    brokerSet.State__c = 'WA';
    brokerSet.Segment__c = 'APN';
    brokerSet.External_Id__c = '';
    brokerSetList.add(brokerSet);
    return brokerSetList;
  }

  @isTest
  private static void testOnBeforeUpdate() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getBrokerSetWithBrokerAndOfficeGroup',
      createBrokerSetList()
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock('getBrokerMap', createBrokerSetList());
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getOfficeGroupRelatedToBrokerSet',
      createBrokerSetList()
    );
    Broker_Relation__c oldBrokerSet = createBrokerSetList()[0];
    Broker_Relation__c newBrokerSet = new Broker_Relation__c();
    newBrokerSet.Id = oldBrokerSet.Id;
    newBrokerSet.State__c = 'MH';
    newBrokerSet.Name = 'Broker Set 1';
    newBrokerSet.Segment__c = 'APN';

    BrokerSetTriggerHandler handler = new BrokerSetTriggerHandler();
    handler.records = new List<Broker_Relation__c>{ newBrokerSet };
    handler.onBeforeUpdate(
      new Map<Id, Broker_Relation__c>{ oldBrokerSet.Id => oldBrokerSet }
    );
    Assert.areEqual(
      newBrokerSet.External_Id__c,
      'Broker_Set_1-APN-MH',
      'Broker external Id not populated'
    );
  }

  @isTest
  private static void testOnBeforeInsert() {
    Broker_Relation__c newBrokerSet = createBrokerSetList()[0];
    newBrokerSet.State__c = 'MH';
    newBrokerSet.Name = 'Broker Set 1';
    newBrokerSet.Segment__c = 'APN';

    BrokerSetTriggerHandler handler = new BrokerSetTriggerHandler();
    handler.records = new List<Broker_Relation__c>{ newBrokerSet };
    handler.onBeforeInsert();
    Assert.areEqual(
      newBrokerSet.External_Id__c,
      'Broker_Set_1-APN-MH',
      'Broker external Id not populated'
    );
  }

  @IsTest
  private static void testIsValidRecordPositive() {
    Broker_Relation__c brokerSet = createBrokerSetList()[0];

    Test.startTest();
    BrokerSetTriggerHandler handler = new BrokerSetTriggerHandler();
    Boolean isBrokerRelation = handler.isValidRecord(brokerSet);
    Test.stopTest();

    Assert.isTrue(isBrokerRelation, 'Should return true for broker Set');
  }

  @IsTest
  private static void testIsValidRecordNegative() {
    Broker_Relation__c officeGroup = createBrokerSetList()[0];
    officeGroup.RecordTypeId = RTBrokerRelation.officeGroup;

    Test.startTest();
    BrokerSetTriggerHandler handler = new BrokerSetTriggerHandler();
    Boolean isBrokerRelation = handler.isValidRecord(officeGroup);
    Test.stopTest();

    Assert.isFalse(isBrokerRelation, 'Should return false for broker Relation');
  }
}
