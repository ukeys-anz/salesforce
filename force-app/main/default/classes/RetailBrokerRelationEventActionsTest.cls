/**
 * @author Saurabh Chauhan
 * @since  10/03/2025
 * @description Test class for RetailBrokerRelationEventActions
 */
@IsTest
public with sharing class RetailBrokerRelationEventActionsTest {
  private static final Lib_MockProvider BROKER_RELATION_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );
  private static final Lib_MockProvider RETAIL_CONTACT_REPOSITORY_MOCK = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  private static final Lib_MockProvider BROKER_SETTINGS_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );

  /**
   * @description test method for publishBrokerRelationEvent
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testPublishBrokerRelationEvent() {
    RETAIL_CONTACT_REPOSITORY_MOCK.mock(
      'getContacts',
      new List<Contact>{ mockContact() }
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerList()
    );
    RETAIL_CONTACT_REPOSITORY_MOCK.mock(
      'getBrokerSetContacts',
      new List<Contact>{ mockContact() }
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock('queryRbmUsers', mockRbmUserList());
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = false;
    BROKER_SETTINGS_REPOSITORY_MOCK.mock('get', mockSettings);

    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = null;
    List<SObject> publishedEventsFromContact = RetailBrokerRelationEventActions.publishBrokerRelationEventFromContact(
      new Set<Id>{ mockContact().Id },
      new Map<Id, Contact>{ oldContact.Id => oldContact }
    );

    List<SObject> publishedEventsFromBrokerSet = RetailBrokerRelationEventActions.publishBrokerRelationEventFromBrokerSet(
      mockBrokerSetMap().values()
    );

    Assert.isFalse(
      publishedEventsFromBrokerSet.isEmpty(),
      'Events should have published from Broker Set'
    );
    Assert.isFalse(
      publishedEventsFromContact.isEmpty(),
      'Events should have published from Contact'
    );
  }

  /**
   * @description test method for publishEvents
   * @author  Saurabh Chauhan | Salesforce | 30-04-2025
   **/
  @isTest
  static void testPublishEvents() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForContacts(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );
    List<SObject> successPublishedEvents = RetailBrokerRelationEventActions.publishEvents(
      payloadInputList
    );
    Assert.isFalse(
      successPublishedEvents.isEmpty(),
      'Broker Relation events should have published'
    );
  }

  /**
   * @description test method for getPayloadInputListForBrokerSet
   * @author  Saurabh Chauhan | Salesforce | 30-04-2025
   **/
  @isTest
  static void testGetPayloadInputListForBrokerSet() {
    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForBrokerSet(
      new List<Contact>{ mockContact() },
      mockRbmUserMap(),
      mockBrokerSetMap()
    );

    Assert.isNotNull(
      payloadInputList[0].broker,
      'Broker was not set on the wrapper instance'
    );
    Assert.isNotNull(
      payloadInputList[0].rbmType,
      'rbmType was not set on the wrapper instance'
    );
    Assert.isNotNull(
      payloadInputList[0].oldBrokerSet,
      'oldBrokerSet was not set on the wrapper instance'
    );
  }

  /**
   * @description test method for getPayloadInputListForContacts
   * @author  Saurabh Chauhan | Salesforce | 30-04-2025
   **/
  @isTest
  static void testGetPayloadInputListForContacts() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForContacts(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );
    Assert.isNotNull(
      payloadInputList[0].broker,
      'Broker was not set on the wrapper instance'
    );
    Assert.isNotNull(
      payloadInputList[0].rbmType,
      'rbmType was not set on the wrapper instance'
    );
    Assert.isNotNull(
      payloadInputList[0].oldBrokerSet,
      'oldBrokerSet was not set on the wrapper instance'
    );
  }

  /**
   * @description test method for generateAddEventModel
   * @author  Saurabh Chauhan | Salesforce | 30-04-2025
   **/
  @isTest
  static void testGenerateAddEventModel() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForContacts(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd = RetailBrokerRelationEventActions.generateAddEventModel(
      payloadInputList
    );
    Assert.isFalse(
      cloudEventModelsAdd.isEmpty(),
      'Add events should have generated.'
    );
  }

  /**
   * @description test method for generateDeleteEventModel
   * @author  Saurabh Chauhan | Salesforce | 30-04-2025
   **/
  @isTest
  static void testGenerateDeleteEventModel() {
    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForContacts(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete = RetailBrokerRelationEventActions.generateDeleteEventModel(
      payloadInputList
    );
    Assert.isFalse(
      cloudEventModelsDelete.isEmpty(),
      'Delete events should have generated.'
    );
  }

  /**
   * @description test method for createCloudEvents
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testCreateCloudEvents() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerSetMap()
    );

    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForContacts(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );

    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd = RetailBrokerRelationEventActions.generateAddEventModel(
      payloadInputList
    );
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete = RetailBrokerRelationEventActions.generateDeleteEventModel(
      payloadInputList
    );
    List<BrokerCloudEventModel> cloudEventModels = RetailBrokerRelationEventActions.createCloudEvents(
      cloudEventModelsAdd,
      cloudEventModelsDelete
    );

    Assert.isFalse(
      cloudEventModels.isEmpty(),
      'A list of type BrokerCloudEventModel should have returned'
    );
  }

  /**
   * @description test method for createEventBatches
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testCreateEventBatches() {
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerSetMap()
    );

    Broker_Relation__c oldBrokerSet = mockBrokerSetMap().values()[0];
    Contact oldContact = mockContact();
    oldContact.Broker_Set__c = oldBrokerSet.Id;

    List<RetailBrokerRelationEventActions.PayloadInputWrapper> payloadInputList = RetailBrokerRelationEventActions.getPayloadInputListForContacts(
      new List<Contact>{ mockContact() },
      new Map<Id, Contact>{ mockContact().Id => oldContact },
      mockBrokerSetMap()
    );

    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd = RetailBrokerRelationEventActions.generateAddEventModel(
      payloadInputList
    );

    List<BrokerCloudEventModel.MasterNode> cloudEventModelsList = new List<BrokerCloudEventModel.MasterNode>();
    for (integer i = 0; i < 60; i++) {
      cloudEventModelsList.addAll(cloudEventModelsAdd);
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
   * @description test method for returnRbmType
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testReturnRbmType() {
    Set<String> rbmTypeSet = RetailBrokerRelationEventActions.returnRbmType(
      mockContact(),
      mockLanIdWrapper()
    );

    Assert.isTrue(
      rbmTypeSet.contains('PRBMadd') && rbmTypeSet.contains('PRBMdelete'),
      'As Primary RBM was changed to other value, set should return PRBMadd'
    );
    Assert.isTrue(
      rbmTypeSet.contains('PRBMdelete'),
      'As Primary RBM was changed to other value, set should return PRBMdelete'
    );
    Assert.isTrue(
      rbmTypeSet.contains('SRBMadd'),
      'As Primary RBM was changed to other value, set should return SRBMadd'
    );
    Assert.isTrue(
      rbmTypeSet.contains('SRBMdelete'),
      'As Primary RBM was changed to other value, set should return SRBMdelete'
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
}
