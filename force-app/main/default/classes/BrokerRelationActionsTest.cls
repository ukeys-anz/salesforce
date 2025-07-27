/**
 * @author Grace Anusha
 * @since 11 Feb 2025
 * @description BrokerRelationActionsTest is the test class for BrokerRelationActions
 */
@isTest
public class BrokerRelationActionsTest {
  // Mock provider for the BrokerRelationRepository class
  private static final Lib_MockProvider BROKER_RELATION_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );
  private static final Lib_MockProvider RETAIL_CONTACT_REPOSITORY_MOCK = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  private static final Lib_MockProvider BROKER_SETTINGS_REPOSITORY_MOCK = Lib_MockProvider.forType(
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
   * @description test method for populateExternalIdOnFilteredBrokerSet
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testPopulateExternalIdOnFilteredBrokerSet() {
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.Name = 'Broker Set 2';
    brokerSet2.state__c = 'SA';
    brokerSet2.segment__c = 'TD';

    BrokerRelationActions.populateExternalIdOnFilteredBrokerSet(
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
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getBrokerSetWithBrokerAndOfficeGroup',
      new List<Broker_Relation__c>{ mockBrokerRelation() }
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
    BrokerRelationActions.showErrorAggregatorChange(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSetNew }
    );
    Assert.isTrue(brokerSetNew.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for showErrorIfOfficeGroupHasBrokers
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testShowErrorIfOfficeGroupHasBrokers() {
    Broker_Relation__c officeGroup = mockOfficeGroup();
    BrokerRelationActions.showErrorIfOfficeGroupHasBrokers(
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
   * @description test method for restrictBrokerSetChangeOnOfficeGroup
   * @author  Grace Anusha | Salesforce | 11-02-2025
   **/
  @isTest
  static void testRestrictBrokerSetChangeOnOfficeGroup() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getBrokerMapOfficeGroup',
      new List<Broker_Relation__c>{ mockOfficeGroup() }
    );
    Broker_Relation__c officeGroupNew = mockOfficeGroup().clone(true, true);
    officeGroupNew.Associated_Broker_Set__c = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    BrokerRelationActions.restrictBrokerSetChangeOnOfficeGroup(
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
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getBrokerMapOfficeGroup',
      new List<Broker_Relation__c>{ mockBrokerRelation() }
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
      'Broker Set should not have errors.'
    );
  }

  /**
   * @description This method tests the case where no deactivation restrictions apply
   * and the Broker_Relation__c record can be deactivated without errors.
   * @author  Utkarsh Singh | Salesforce | 20-02-2025
   **/
  @isTest
  static void testNoDeactivationRestriction() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getBrokerMap',
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
   * @description test method for restrictDeactivationRelatedOfficeGroup
   * @author  Saurabh Chauhan | Salesforce | 07-04-2025
   **/
  @isTest
  static void testRestrictDeactivationRelatedOfficeGroup() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getOfficeGroupRelatedToBrokerSet',
      new List<Broker_Relation__c>{ mockBrokerRelation() }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.restrictDeactivationRelatedOfficeGroup(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isFalse(
      brokerSet2.Office_Groups__r.isEmpty(),
      'Broker set should have office groups.'
    );
    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for showErrorIfBrokerSetHasOfficeGroups
   * @author  Saurabh Chauhan | Salesforce | 07-04-2025
   **/
  @isTest
  static void testShowErrorIfBrokerSetHasOfficeGroups() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getOfficeGroupRelatedToBrokerSet',
      new List<Broker_Relation__c>{ mockBrokerRelation() }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.showErrorIfBrokerSetHasOfficeGroups(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isFalse(
      brokerSet2.Office_Groups__r.isEmpty(),
      'Broker set should have office groups.'
    );
    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for showErrorIfBrokerSetHasBrokers
   * @author  Saurabh Chauhan | Salesforce | 07-04-2025
   **/
  @isTest
  static void testShowErrorIfBrokerSetHasBrokers() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'getOfficeGroupRelatedToBrokerSet',
      new List<Broker_Relation__c>{ mockBrokerRelation() }
    );
    Broker_Relation__c brokerSet2 = mockBrokerRelation().clone(true, true);
    brokerSet2.IsActive__c = false;

    BrokerRelationActions.showErrorIfBrokerSetHasBrokers(
      new Map<Id, Broker_Relation__c>{
        mockBrokerRelation().Id => mockBrokerRelation()
      },
      new List<Broker_Relation__c>{ brokerSet2 }
    );

    Assert.isFalse(
      brokerSet2.Broker_Set_Brokers__r.isEmpty(),
      'Broker set should have office groups.'
    );
    Assert.isTrue(brokerSet2.hasErrors(), 'Broker set should have errors.');
  }

  /**
   * @description test method for publishBrokerRelationEvents
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testPublishBrokerRelationEvents() {
    RETAIL_CONTACT_REPOSITORY_MOCK.mock(
      'getContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerList()
    );
    RETAIL_CONTACT_REPOSITORY_MOCK.mock(
      'getBrokerSetContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock('queryRbmUsers', mockRbmUserList());
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = false;
    BROKER_SETTINGS_REPOSITORY_MOCK.mock('get', mockSettings);

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

    Assert.isFalse(
      publishedEvents.isEmpty(),
      'No published events were returned'
    );
  }

  /**
   * @description to create mock Broker Relation List
   * @author  Atharv Jakate | Salesforce | 23-06-2025
   * @return List<Broker_Relation__c>
   **/
  private static List<Broker_Relation__c> mockBrokerList() {
    Broker_Relation__c newBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZI5JYAW"},"Id":"a2oAD000000ZI5JYAW","Primary_RBM__c":"005Oa000005OyubIAC","Secondary_RBM__c":"005Oa000003fFuDIAU","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Lan_Id__c":"manish5"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"}}',
      Broker_Relation__c.class
    );

    Broker_Relation__c oldBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZUuTYAW"},"Id":"a2oAD000000ZUuTYAW","Primary_RBM__c":"005Oa000003fFuDIAU","Secondary_RBM__c":"005Oa000003wiQMIAY","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003wiQMIAY"},"Id":"005Oa000003wiQMIAY","Lan_Id__c":"utkarsh9"}}',
      Broker_Relation__c.class
    );

    return new List<Broker_Relation__c>{ oldBrokerSet, newBrokerSet };
  }

  /**
   * @description to create mock rbm users
   * @author  Atharv Jakate | Salesforce | 23-06-2025
   * @return List<User>
   **/
  private static List<User> mockRbmUserList() {
    List<User> userList = (List<User>) JSON.deserialize(
      '[{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Name":"Saurabh Chauhan","Lan_Id__c":"sauDevtest"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/0055m000000XnEPAA0"},"Id":"0055m000000XnEPAA0","Name":"Jasmine Nguyen","Lan_Id__c":"jasTest"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Name":"Manish Bisht","Lan_Id__c":"manish5"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003wiQMIAY"},"Id":"005Oa000003wiQMIAY","Name":"Utkarsh Singh","Lan_Id__c":"utkarsh9"}]',
      List<User>.class
    );

    return userList;
  }
}
