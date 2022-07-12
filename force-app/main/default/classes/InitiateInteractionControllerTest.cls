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
      Name = faker.randomString(10),
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
}
