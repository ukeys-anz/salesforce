/*
 * @author Pragya Awasthi
 * @since  09/2025
 * @description MLInteractionTriggerHandlerTest is the test class to cover tests for InteractionTriggerHandler
 */
@isTest
public class MLInteractionTriggerHandlerTest {
  /**
   * @description create test data
   * @return Interaction
   */
  static Interaction getInteraction() {
    return new Interaction(
      RecordTypeId = RTInteraction.mlcrmInteraction,
      Name = 'A sample text with Passport12345678',
      Optional_Notes__c = 'A sample text with Passport12345678'
    );
  }

  @isTest
  static void testMaskingBeforeInsert() {
    Interaction interactionRec = getInteraction();

    Test.startTest();
    InteractionTriggerHandler handler = new InteractionTriggerHandler();
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
    InteractionTriggerHandler handler = new InteractionTriggerHandler();
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
}
