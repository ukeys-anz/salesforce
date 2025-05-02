/**
 * @author Saurabh Chauhan
 * @since  10/03/2025
 * @description Test class for RetailBrokerRelationEventActions
 */
@IsTest
public with sharing class RetailBrokerRelationEventActionsTest {
  static Lib_MockProvider brokerRelationMock = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );
  static Lib_MockProvider retailContactMock = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );

  /**
   * @description test method for publishBrokerRelationEvent
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testPublishBrokerRelationEvent() {
    retailContactMock.mock('getContacts', new List<Contact>{ mockContact() });
    brokerRelationMock.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerSetMap()
    );
    retailContactMock.mock(
      'getBrokerSetContacts',
      new List<Contact>{ mockContact() }
    );
    brokerRelationMock.mock('queryRbmUsers', mockRbmUserMap());
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = false;
    brokerSettingsMock.mock('get', mockSettings);

    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = null;
    List<SObject> publishedEventsFromContact = RetailBrokerRelationEventActions.publishEventForBrokerRelation(
      new Map<Id, String>{ mockContact().Id => 'add' },
      new Map<Id, Contact>{ oldContact.Id => oldContact }
    );

    List<SObject> publishedEventsFromBrokerSet = RetailBrokerRelationEventActions.publishEventForBrokerRelation(
      mockBrokerSetMap().values()
    );

    Assert.isFalse(
      publishedEventsFromBrokerSet.isEmpty(),
      'Events got published from Broker Set'
    );
    Assert.isFalse(
      publishedEventsFromContact.isEmpty(),
      'Events got published from Contact'
    );
  }

  /**
   * @description test method for createContactAndLanIdMap
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testCreateContactAndLanIdMap() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    Map<Id, RetailBrokerRelationEventActions.LanIdWrapper> contIdAndOldRbmLanIdMap = RetailBrokerRelationEventActions.createContactAndLanIdMap(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );

    Assert.isFalse(
      contIdAndOldRbmLanIdMap.isEmpty(),
      'Map should not be empty'
    );
    Assert.areEqual(
      contIdAndOldRbmLanIdMap.get(mockContact().Id).prbmLanId,
      oldBrokerSet.Primary_RBM__r.Lan_Id__c,
      'Old Broker set\'s primary rbm lan id is set as prbmLanId'
    );
    Assert.areEqual(
      contIdAndOldRbmLanIdMap.get(mockContact().Id).srbmLanId,
      oldBrokerSet.Secondary_RBM__r.Lan_Id__c,
      'Old Broker set\'s secondary rbm lan id is set as srbmLanId'
    );
  }

  /**
   * @description test method for createBsAndLanIdMap
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testCreateBsAndLanIdMap() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[1];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    Map<Id, RetailBrokerRelationEventActions.LanIdWrapper> bsIdAndOldRbmLanIdMap = RetailBrokerRelationEventActions.createBsAndLanIdMap(
      new List<Contact>{ mockContact() },
      mockRbmUserMap(),
      mockBrokerSetMap()
    );

    Assert.isFalse(bsIdAndOldRbmLanIdMap.isEmpty(), 'Map should not be empty');
    Assert.areEqual(
      bsIdAndOldRbmLanIdMap.get(mockContact().Broker_Set__c).prbmLanId,
      oldBrokerSet.Primary_RBM__r.Lan_Id__c,
      'Old Broker set\'s primary rbm lan id is set as prbmLanId'
    );
    Assert.areEqual(
      bsIdAndOldRbmLanIdMap.get(mockContact().Broker_Set__c).srbmLanId,
      oldBrokerSet.Secondary_RBM__r.Lan_Id__c,
      'Old Broker set\'s secondary rbm lan id is set as srbmLanId'
    );
  }

  /**
   * @description test method for getBrokerRelationEvent triggered from Contact Update
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testGetBrokerRelationEventFromContact() {
    brokerRelationMock.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerSetMap()
    );

    RetailBrokerRelationEventActions.BrokerRelationEventWrapper brokerRelationAddEvent = RetailBrokerRelationEventActions.getBrokerRelationEvent(
      new List<Contact>{ mockContact() },
      new Map<Id, String>{ mockContact().Id => 'add' },
      new Map<Id, RetailBrokerRelationEventActions.LanIdWrapper>{
        mockContact().Id => mockLanIdWrapper()
      }
    );
    RetailBrokerRelationEventActions.BrokerRelationEventWrapper brokerRelationDeleteEvent = RetailBrokerRelationEventActions.getBrokerRelationEvent(
      new List<Contact>{ mockContact() },
      new Map<Id, String>{ mockContact().Id => 'delete' },
      new Map<Id, RetailBrokerRelationEventActions.LanIdWrapper>{
        mockContact().Id => mockLanIdWrapper()
      }
    );
    Assert.isFalse(
      brokerRelationAddEvent.cloudEventModelsAdd.isEmpty(),
      'Add events were returned'
    );
    Assert.isFalse(
      brokerRelationDeleteEvent.cloudEventModelsDelete.isEmpty(),
      'Delete events were returned'
    );
  }

  /**
   * @description test method for getBrokerRelationEvent triggered from Broker Set Update
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testGetBrokerRelationEvent() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[1];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    Map<Id, RetailBrokerRelationEventActions.LanIdWrapper> bsIdAndOldRbmLanIdMap = RetailBrokerRelationEventActions.createBsAndLanIdMap(
      new List<Contact>{ mockContact() },
      mockRbmUserMap(),
      mockBrokerSetMap()
    );

    RetailBrokerRelationEventActions.BrokerRelationEventWrapper brokerRelationEvent = RetailBrokerRelationEventActions.getBrokerRelationEvent(
      new List<Contact>{ mockContact() },
      bsIdAndOldRbmLanIdMap
    );

    Assert.isFalse(
      brokerRelationEvent.cloudEventModelsAdd.isEmpty(),
      'Add events were returned'
    );
    Assert.isFalse(
      brokerRelationEvent.cloudEventModelsDelete.isEmpty(),
      'Delete events were returned'
    );
  }

  /**
   * @description test method for createCloudEvents
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testCreateCloudEvents() {
    brokerRelationMock.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerSetMap()
    );

    RetailBrokerRelationEventActions.BrokerRelationEventWrapper brokerRelationAddEvent = RetailBrokerRelationEventActions.getBrokerRelationEvent(
      new List<Contact>{ mockContact() },
      new Map<Id, String>{ mockContact().Id => 'add' },
      new Map<Id, RetailBrokerRelationEventActions.LanIdWrapper>{
        mockContact().Id => mockLanIdWrapper()
      }
    );

    List<BrokerCloudEventModel> cloudEventModels = RetailBrokerRelationEventActions.createCloudEvents(
      brokerRelationAddEvent
    );

    Assert.isFalse(
      cloudEventModels.isEmpty(),
      'A list of type BrokerCloudEventModel is returned'
    );
  }

  /**
   * @description test method for createEventBatches
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testCreateEventBatches() {
    brokerRelationMock.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerSetMap()
    );

    RetailBrokerRelationEventActions.BrokerRelationEventWrapper brokerRelationAddEvent = RetailBrokerRelationEventActions.getBrokerRelationEvent(
      new List<Contact>{ mockContact() },
      new Map<Id, String>{ mockContact().Id => 'add' },
      new Map<Id, RetailBrokerRelationEventActions.LanIdWrapper>{
        mockContact().Id => mockLanIdWrapper()
      }
    );

    List<BrokerCloudEventModel.MasterNode> cloudEventModelsList = new List<BrokerCloudEventModel.MasterNode>();
    for (integer i = 0; i < 60; i++) {
      cloudEventModelsList.addAll(brokerRelationAddEvent.cloudEventModelsAdd);
    }
    List<BrokerCloudEventModel> listOfBatches = RetailBrokerRelationEventActions.createEventBatches(
      cloudEventModelsList,
      'add'
    );
    BrokerCloudEventModel.BrokerCloudEventDataModel firstBatch = (BrokerCloudEventModel.BrokerCloudEventDataModel) listOfBatches[0]
      .ce_data;
    BrokerCloudEventModel.BrokerCloudEventDataModel secondBatch = (BrokerCloudEventModel.BrokerCloudEventDataModel) listOfBatches[1]
      .ce_data;

    Assert.areEqual(2, listOfBatches.size(), 'There should be 2 add events');
    Assert.areEqual(
      100,
      firstBatch.data.size(),
      'There should be 100 records in this list (50 SRBM + 50 PRBM)'
    );
    Assert.areEqual(
      20,
      secondBatch.data.size(),
      'There should be 20 records in this list (10 SRBM + 10 PRBM)'
    );
  }

  /**
   * @description test method for generateBrokerRelationCEModel
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testGenerateBrokerRelationCEModel() {
    List<BrokerCloudEventModel.MasterNode> returnNodesForRbms = RetailBrokerRelationEventActions.generateBrokerRelationCEModel(
      mockContact(),
      'add',
      mockLanIdWrapper()
    );

    Assert.isTrue(
      returnNodesForRbms[0].sourceObjectExtId.contains('PRBM'),
      'Node for Primary RBM is returned'
    );
    Assert.isTrue(
      returnNodesForRbms[1].sourceObjectExtId.contains('SRBM'),
      'Node for Secondary RBM is returned'
    );
  }

  /**
   * @description test method for returnRbmType
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testReturnRbmType() {
    Set<String> rbmTypeSet = RetailBrokerRelationEventActions.returnRbmType(
      mockContact(),
      mockLanIdWrapper(),
      'add'
    );

    Assert.isTrue(
      rbmTypeSet.contains('PRBM'),
      'As Primary RBM was changed, set should return PRBM'
    );
    Assert.isTrue(
      rbmTypeSet.contains('SRBM'),
      'As Primary RBM was changed, set should return SRBM'
    );
  }

  /**
   * @description test method for buildBrokerRelationAdd
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testBuildBrokerRelationAdd() {
    List<BrokerCloudEventModel.MasterNode> addEventNode = RetailBrokerRelationEventActions.buildBrokerRelationAdd(
      mockContact(),
      'PRBM'
    );

    Assert.isFalse(
      addEventNode[0].targetObjects.parent.isEmpty(),
      'There is a parent node for add event'
    );
  }

  /**
   * @description test method for buildBrokerRelationDelete
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testBuildBrokerRelationDelete() {
    List<BrokerCloudEventModel.MasterNode> deleteEventNode = RetailBrokerRelationEventActions.buildBrokerRelationDelete(
      mockContact(),
      'PRBM',
      mockLanIdWrapper()
    );

    Assert.isTrue(
      deleteEventNode[0].targetObjects.parent == null,
      'There is no parent node for delete event'
    );
  }

  /**
   * @description to create mock contact
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   * @return Contact
   **/
  public static Contact mockContact() {
    Contact con = (Contact) JSON.deserialize(
      '{"attributes":{"type":"Contact","url":"/services/data/v63.0/sobjects/Contact/003AD00000abYnbYAE"},"Id":"003AD00000abYnbYAE","Name":"Saurabh Chauhan Test","Broker_Set__c":"a2oAD000000ZI5JYAW","External_Id__c":"1234","OCV_Event_Version__c":1.00,"Sync_Status__c":"Broker Org","RecordTypeId":"012Oa000001rCvLIAU","Broker_Set__r":{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZI5JYAW"},"Id":"a2oAD000000ZI5JYAW","Primary_RBM__c":"005Oa000003fFuDIAU","Secondary_RBM__c":"005Oa000003fFuDIAU","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Lan_Id__c":"manish5"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/0055m000000XnEPAA0"},"Id":"0055m000000XnEPAA0","Lan_Id__c":"jasTest"}}}',
      Contact.class
    );
    return con;
  }

  /**
   * @description to create wrapper mock of type LanIdWrapper
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   * @return RetailBrokerRelationEventActions.LanIdWrapper
   **/
  public static RetailBrokerRelationEventActions.LanIdWrapper mockLanIdWrapper() {
    RetailBrokerRelationEventActions.LanIdWrapper oldBrokerLanIds = new RetailBrokerRelationEventActions.LanIdWrapper();
    oldBrokerLanIds.prbmLanId = mockBrokerSetMap().values()[0]
      .Primary_RBM__r.Lan_Id__c;
    oldBrokerLanIds.srbmLanId = mockBrokerSetMap().values()[0]
      .Secondary_RBM__r.Lan_Id__c;
    return oldBrokerLanIds;
  }

  /**
   * @description to create mock contact
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   * @return Map<Id, Broker_Relation__c>
   **/
  public static Map<Id, Broker_Relation__c> mockBrokerSetMap() {
    Broker_Relation__c newBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZI5JYAW"},"Id":"a2oAD000000ZI5JYAW","Primary_RBM__c":"005Oa000005OyubIAC","Secondary_RBM__c":"005Oa000003fFuDIAU","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Lan_Id__c":"manish5"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"}}',
      Broker_Relation__c.class
    );

    Broker_Relation__c oldBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZUuTYAW"},"Id":"a2oAD000000ZUuTYAW","Primary_RBM__c":"005Oa000003fFuDIAU","Secondary_RBM__c":"005Oa000003wiQMIAY","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003wiQMIAY"},"Id":"005Oa000003wiQMIAY","Lan_Id__c":"utkarsh9"}}',
      Broker_Relation__c.class
    );

    return new Map<Id, Broker_Relation__c>{
      oldBrokerSet.Id => oldBrokerSet,
      newBrokerSet.Id => newBrokerSet
    };
  }

  /**
   * @description to create mock rbm users
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   * @return Map<Id, User>
   **/
  public static Map<Id, User> mockRbmUserMap() {
    List<User> userList = (List<User>) JSON.deserialize(
      '[{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Name":"Saurabh Chauhan","Lan_Id__c":"sauDevtest"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/0055m000000XnEPAA0"},"Id":"0055m000000XnEPAA0","Name":"Jasmine Nguyen","Lan_Id__c":"jasTest"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Name":"Manish Bisht","Lan_Id__c":"manish5"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003wiQMIAY"},"Id":"005Oa000003wiQMIAY","Name":"Utkarsh Singh","Lan_Id__c":"utkarsh9"}]',
      List<User>.class
    );

    return new Map<Id, User>{
      userList[0].Id => userList[0],
      userList[1].Id => userList[1],
      userList[2].Id => userList[2],
      userList[3].Id => userList[3]
    };
  }
}
