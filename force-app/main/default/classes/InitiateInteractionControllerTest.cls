/**
 *
 * @author Rebecca Jan
 * @since 07/2022
 * @description Tests interaction creation which powers the initiateInteraction LWC
 */

@isTest
public with sharing class InitiateInteractionControllerTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      FirstName = faker.randomString(10),
      LastName = faker.randomString(10),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert acc;
  }

  /**
   * @description createInteractionSuccessTest tests creation of an interaction
   */
  @isTest
  static void createInteractionSuccessTest() {
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Map<String, String> fields = new Map<String, String>{
      'recordType' => 'General',
      'accountId' => testAcc.Id,
      'interactionType' => 'Call',
      'direction' => 'Outbound',
      'reason' => 'Customer'
    };
    Interaction newInteraction = InitiateInteractionController.createInteraction(
      fields
    );
    Interaction findInteraction = [
      SELECT Id
      FROM Interaction
      WHERE AccountId = :testAcc.Id
      LIMIT 1
    ];
    System.assertEquals(
      newInteraction.Id,
      findInteraction.Id,
      'Interaction is not found.'
    );
  }

  /**
   * @description createInteractionSuccessTest tests creation of an interaction
   */
  @isTest
  static void createInteractionFailureTest() {
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Map<String, String> fields = new Map<String, String>{
      'accountId' => testAcc.Id,
      'interactionType' => 'Call',
      'direction' => 'Outbound',
      'reason' => 'Customer'
    };
    try {
      InitiateInteractionController.createInteraction(fields);
      System.assert(
        false,
        'Interaction is missing record type and was expected to fail'
      );
    } catch (AuraHandledException e) {
      System.assertEquals(
        e.getMessage(),
        'Script-thrown exception',
        'Error should be thrown.'
      );
    }
  }

  /**
   * @description initiateChatTest tests successful response of initiate chat
   */
  @isTest
  static void initiateChatTest() {
    User thisUser = [
      SELECT Id, Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    System.runAs(thisUser) {
      Account testAcc = [SELECT Id FROM Account LIMIT 1];
      String messageContent = 'Test message content to be sent';

      Test.startTest();
      InitiateChatModel response = InitiateInteractionController.initiateChat(
        testAcc.Id,
        messageContent
      );
      Test.stopTest();

      System.assertEquals(
        'CH000001',
        response.conversationSid,
        'Mock conversationSid should be returned'
      );
    }
  }

  /**
   * @description reinitiateChatTest tests successful response of reinitiate chat
   */
  @isTest
  static void reinitiateChatTest() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Account testAcc = [SELECT Id FROM Account LIMIT 1];
      Faker faker = new Faker('AU');
      Test.startTest();
      ReinitiateChatModel response = InitiateInteractionController.reinitiateChat(
        testAcc.Id,
        faker.randomString(10)
      );
      Test.stopTest();

      System.assertEquals(
        'FW000001',
        response.executionSid,
        'Mock executionSid should be returned'
      );
    }
  }
}
