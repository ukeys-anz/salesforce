/*
 * @author Pragya Awasthi
 * @since  09/2025
 * @description MLInteractionTriggerHandlerTest is the test class to cover tests for InteractionTriggerHandler
 */
@isTest
public class MLInteractionTriggerHandlerTest {
  static Lib_MockProvider dmlRepoMock;
  static Id interactionID = Lib_FakeIdGenerator.getMockId(
    Schema.Interaction.getSObjectType()
  );

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }
  /**
   * @description create test data
   * @return Interaction
   */
  static Interaction getInteraction() {
    return new Interaction(
      id = interactionID,
      RecordTypeId = RTInteraction.mlcrmInteraction,
      Name = 'A sample text with Passport12345678',
      Optional_Notes__c = 'A sample text with Passport12345678',
      Territory__c = null
    );
  }

  @IsTest
  static void testIsValidRecord() {
    Interaction interactionRec = getInteraction();
    MobileLendingInteractionTriggerHandler handler = new MobileLendingInteractionTriggerHandler();
    Test.startTest();
    Boolean checkRecord = handler.isValidRecord(interactionRec);
    Test.stopTest();
    Assert.isTrue(checkRecord, 'This is a valid record');
  }

  @isTest
  static void testMaskingBeforeInsert() {
    Interaction interactionRec = getInteraction();
    Test.startTest();
    MobileLendingInteractionTriggerHandler handler = new MobileLendingInteractionTriggerHandler();
    handler.records = new List<Interaction>{ interactionRec };
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(
      'A sample text with Passport****5678',
      interactionRec.Name,
      'Keyword entered in Name should be masked'
    );
    Assert.areEqual(
      'A sample text with Passport****5678',
      interactionRec.Optional_Notes__c,
      'Keyword entered in Optional Notes should be masked'
    );
  }

  @isTest
  static void testMaskingBeforeUpdate() {
    Interaction interactionRec = getInteraction();

    interactionRec.Name = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    interactionRec.Optional_Notes__c = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>{
      interactionRec.Id => interactionRec
    };

    Test.startTest();
    MobileLendingInteractionTriggerHandler handler = new MobileLendingInteractionTriggerHandler();
    handler.records = new List<Interaction>{ interactionRec };
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      interactionRec.Name,
      'Keyword entered in Name should be masked'
    );
    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      interactionRec.Optional_Notes__c,
      'Keyword entered in Optional Notes should be masked'
    );
  }

  @isTest
  static void testAfterInsert() {
    registerMocks();
    Interaction interactionRec = getInteraction();
    Test.startTest();
    MobileLendingInteractionTriggerHandler handler = new MobileLendingInteractionTriggerHandler();
    handler.records = new List<Interaction>{ interactionRec };
    handler.onAfterInsert();
    Test.stopTest();
    Territory_Base_Sharing_Event__e event = (Territory_Base_Sharing_Event__e) dmlRepoMock
      .getHistory('doPublish')
      .listOfArgs[0];
    Assert.areEqual(
      'Interaction',
      event.Trigger_Object__c,
      'Event should contains info for Interaction Sharing'
    );
    Assert.isTrue(
      event.Record_Ids__c.contains(interactionRec.Id),
      'Event should contains info for Interaction Sharing'
    );
  }

  @isTest
  static void testAfterUpdate() {
    registerMocks();

    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Interaction interactionRec = getInteraction();
    interactionRec.OwnerId = idOwner2;
    Interaction oldInteractionRec = getInteraction();
    oldInteractionRec.OwnerId = idOwner;
    Test.startTest();
    Map<Id, Interaction> oldMap = new Map<Id, Interaction>{
      oldInteractionRec.Id => oldInteractionRec
    };
    MobileLendingInteractionTriggerHandler handler = new MobileLendingInteractionTriggerHandler();
    handler.records = new List<Interaction>{ interactionRec };
    handler.onAfterUpdate(oldMap);
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'Territory Share Event is not published'
    );
    Territory_Base_Sharing_Event__e event = (Territory_Base_Sharing_Event__e) dmlRepoMock
      .getHistory('doPublish')
      .listOfArgs[0];
    Assert.areEqual(
      'Interaction',
      event.Trigger_Object__c,
      'Event should contains info for Interaction Sharing'
    );
    Assert.isTrue(
      event.Record_Ids__c.contains(interactionRec.Id),
      'Event should contains info for Interaction Sharing'
    );
  }
}
