/**
 * @author Grace Anusha
 * @since 11 Feb 2025
 * @description BrokerRelationActionsTest is the test class for BrokerRelationActions
 */
@isTest
public class BrokerRelationActionsTest {
  // Mock provider for the BrokerRelationRepository class
  static Lib_MockProvider brokerRelationMock = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );
  static Lib_MockProvider retailContactMock = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );

  static Broker_Relation__c mockBrokerRelation() {
    Broker_Relation__c brokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000YmrpYAC"},"Id":"a2oAD000000YmrpYAC","Name":"Broker Set 1","State__c":"WA","Segment__c":"APN","Aggregator__c":"001AD00000hBhx3YAC","IsActive__c":true,"Office_Groups__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000YmtRYAS"},"Id":"a2oAD000000YmtRYAS"}]},"Primary_RBM__c":"005AD00000CcmkVYAR","Secondary_RBM__c":"005AD00000CP437YAD","RecordTypeId":"012AD000001sGQbYAM","Broker_Set_Brokers__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Contact","url":"/services/data/v63.0/sobjects/Contact/003AD00000aZN8VYAW"},"Broker_Set__c":"a2oAD000000YmrpYAC","Id":"003AD00000aZN8VYAW","RecordTypeId":"012Oa000001rCvLIAU"}]}}',
      Broker_Relation__c.class
    );
    return brokerSet;
  }

  static Broker_Relation__c mockOfficeGroup() {
    Broker_Relation__c officeGroup = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000Yq0zYAC"},"Id":"a2oAD000000Yq0zYAC","Name":"OG 4 1","Segment__c":"APN","Aggregator__c":"001AD00000hBhx3YAC","IsActive__c":true,"RecordTypeId":"012AD000001sGQcYAM","Office_Group_Brokers__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Contact","url":"/services/data/v63.0/sobjects/Contact/003AD00000aZN8VYAW"},"Office_Group__c":"a2oAD000000Yq0zYAC","Id":"003AD00000aZN8VYAW","RecordTypeId":"012Oa000001rCvLIAU"}]}}',
      Broker_Relation__c.class
    );
    return officeGroup;
  }

  /**
   * @description test method for populateExternalId
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testPopulateExternalIdOnInsert() {
    Broker_Relation__c brokerSet = mockBrokerRelation();
    BrokerRelationActions.populateExternalId(
      new List<Broker_Relation__c>{ brokerSet }
    );

    Assert.areEqual(
      'Broker_Set_1-APN-WA',
      brokerSet.External_Id__c,
      'External Id should be in the format Name_Segment_State.'
    );
  }

  /**
   * @description test method for populateExternalIdOnFilteredBS
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testPopulateExternalIdOnFilteredBS() {
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.Name = 'Broker Set 2';
    brokerSet2.state__c = 'SA';
    brokerSet2.segment__c = 'TD';

    BrokerRelationActions.populateExternalIdOnFilteredBS(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.areEqual(
      'Broker_Set_2-TD-SA',
      brokerSet2.External_Id__c,
      'External Id should be in the format Name_Segment_State.'
    );
  }
  /**
   * @description test method for RestrictAggregatorChange
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testRestrictAggregatorChange() {
    brokerRelationMock.mock(
      'getBrokerMap',
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      }
    );
    Broker_Relation__c brokerSetNew = mockBrokerRelation().clone(true, true);
    brokerSetNew.Aggregator__c = Lib_FakeIdGenerator.getMockId(
      Account.SObjectType
    );
    BrokerRelationActions.restrictAggregatorChange(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSetNew }
    );

    Assert.isTrue(brokerSetNew.hasErrors(), 'Broker set should have errors.');
  }
  /**
   * @description test method for showError
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testShowError() {
    Broker_Relation__c brokerSetNew = mockBrokerRelation().clone(true, true);
    brokerSetNew.Aggregator__c = Lib_FakeIdGenerator.getMockId(
      Account.SObjectType
    );
    BrokerRelationActions.showError(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSetNew }
    );

    Assert.isTrue(brokerSetNew.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for showErrorOfficeGroupHasBrokers
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testShowErrorOfficeGroupHasBrokers() {
    Broker_Relation__c officeGroup = mockOfficeGroup();
    BrokerRelationActions.showErrorOfficeGroupHasBrokers(
      new Map<Id, Broker_Relation__c>{ officeGroup.Id => officeGroup },
      new List<Broker_Relation__c>{ officeGroup },
      'error msg'
    );

    Assert.isFalse(
      officeGroup.Office_Group_Brokers__r.isEmpty(),
      'There are brokers associated with office group'
    );
    Assert.isTrue(officeGroup.hasErrors(), 'Broker set should have errors.');
  }
  /**
   * @description test method for restrictBrokerSetChangeOnOG
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testRestrictBrokerSetChangeOnOG() {
    brokerRelationMock.mock(
      'getBrokerMapOfficeGroup',
      new Map<Id, Broker_Relation__c>{
        mockOfficeGroup().Id => mockOfficeGroup()
      }
    );
    Broker_Relation__c officeGroupNew = mockOfficeGroup().clone(true, true);
    officeGroupNew.Associated_Broker_Set__c = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    BrokerRelationActions.restrictBrokerSetChangeOnOG(
      new Map<Id, Broker_Relation__c>{
        mockOfficeGroup().Id => mockOfficeGroup()
      },
      new List<Broker_Relation__c>{ officeGroupNew }
    );

    Assert.isTrue(officeGroupNew.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for blockDeactivationOfficeGroup
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testBlockDeactivationOfficeGroup() {
    brokerRelationMock.mock(
      'getBrokerMapOfficeGroup',
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      }
    );
    Broker_Relation__c officeGroupNew = mockOfficeGroup().clone(true, true);
    officeGroupNew.IsActive__c = false;
    BrokerRelationActions.blockDeactivationOfficeGroup(
      new Map<Id, Broker_Relation__c>{
        mockOfficeGroup().Id => mockOfficeGroup()
      },
      new List<Broker_Relation__c>{ officeGroupNew }
    );

    Assert.isFalse(
      officeGroupNew.hasErrors(),
      'Broker set should have errors.'
    );
  }
  /**
   * @description This method tests the case where no deactivation restrictions apply
   * and the Broker_Relation__c record can be deactivated without errors.
   * @author  Utkarsh Singh | Salesforce | 20-02-2025
   **/
  @isTest
  static void testNoDeactivationRestriction() {
    brokerRelationMock.mock(
      'getBrokerMap',
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      }
    );
    brokerRelationMock.mock(
      'brokerRelationMock',
      new List<Broker_Relation__c>{ mockBrokerRelation() }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.restrictDeactivationOfBrokerSet(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for restrictDeactivationRelatedOG
   * @author  Saurabh Chauhan | Salesforce | 07-04-2025
   **/
  @isTest
  static void testRestrictDeactivationRelatedOG() {
    brokerRelationMock.mock(
      'getOfficeGroupRelatedToBrokerSet',
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.restrictDeactivationRelatedOG(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isFalse(
      brokerSet2.Office_Groups__r.isEmpty(),
      'Broker set has office group.'
    );
    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for showErrorBrokerSetHasOGs
   * @author  Saurabh Chauhan | Salesforce | 07-04-2025
   **/
  @isTest
  static void testShowErrorBrokerSetHasOGs() {
    brokerRelationMock.mock(
      'getOfficeGroupRelatedToBrokerSet',
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.showErrorBrokerSetHasOGs(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isFalse(
      brokerSet2.Office_Groups__r.isEmpty(),
      'Broker set has office group.'
    );
    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for showErrorBrokerSetHasBrokers
   * @author  Saurabh Chauhan | Salesforce | 07-04-2025
   **/
  @isTest
  static void testShowErrorBrokerSetHasBrokers() {
    brokerRelationMock.mock(
      'getOfficeGroupRelatedToBrokerSet',
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.showErrorBrokerSetHasBrokers(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isFalse(
      brokerSet2.Broker_Set_Brokers__r.isEmpty(),
      'Broker set has office group.'
    );
    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for publishBrokerRelationEvents
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testPublishBrokerRelationEvents() {
    retailContactMock.mock(
      'getContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    brokerRelationMock.mock(
      'queryBrokerRelationWithRbmDetails',
      RetailBrokerRelationEventActionsTest.mockBrokerSetMap()
    );
    retailContactMock.mock(
      'getBrokerSetContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    brokerRelationMock.mock(
      'queryRbmUsers',
      RetailBrokerRelationEventActionsTest.mockRbmUserMap()
    );
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = false;
    brokerSettingsMock.mock('get', mockSettings);

    Broker_Relation__c newBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZI5JYAW"},"Id":"a2oAD000000ZI5JYAW","Primary_RBM__c":"005Oa000005OyubIAC","Secondary_RBM__c":"005Oa000003fFuDIAU","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Lan_Id__c":"manish5"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"}}',
      Broker_Relation__c.class
    );

    Broker_Relation__c oldBrokerSet = newBrokerSet;
    oldBrokerSet.Primary_RBM__c = Lib_FakeIdGenerator.getMockId(
      User.SObjectType
    );

    List<SObject> publishedEvents = BrokerRelationActions.publishBrokerRelationEvents(
      new Map<Id, Broker_Relation__c>{ oldBrokerSet.Id => oldBrokerSet },
      new Map<Id, Broker_Relation__c>{ newBrokerSet.Id => newBrokerSet }
    );

    Assert.isFalse(publishedEvents.isEmpty(), 'Published events were returned');
  }
}
