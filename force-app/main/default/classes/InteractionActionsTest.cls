/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Testing Interaction Actions
 */
@isTest
public with sharing class InteractionActionsTest {
  /**
   * @description test for cancelling an Interaction
   */
  @isTest
  static void testCancellingAnInteraction() {
    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.OwnerId = contactRequestQueue[0].Queue.Id;
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    insert request;

    request.OwnerId = UserInfo.getUserId();

    update request;

    Interaction testInteraction = [SELECT Id, Status__c FROM Interaction];

    List<Event> events = [SELECT Id FROM Event];

    System.assertNotEquals(null, testInteraction, 'An Interaction must exist');
    System.assertEquals(1, events.size(), 'One event must be created');

    Interaction oldInteraction = new Interaction(
      Id = testInteraction.Id,
      Status__c = testInteraction.Status__c
    );
    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    oldMap.put(oldInteraction.Id, oldInteraction);

    test.startTest();
    testInteraction.Status__c = 'Cancelled';
    InteractionActions actions = new InteractionActions();
    List<Interaction> updatedInteractions = new List<Interaction>();
    updatedInteractions.add(testInteraction);

    List<Interaction> interactions = actions.findCancelledInteractions(
      oldMap,
      updatedInteractions
    );
    System.assertEquals(
      1,
      interactions.size(),
      'The interaction must be returned'
    );
    actions.deleteInteractionEvents(interactions);
    test.stopTest();

    events = [SELECT Id FROM Event];

    System.assertEquals(true, events.isEmpty(), 'All events must be deleted');
  }

  @isTest
  static void testDoesntFindNotOrStillCancelledInteractions() {
    Interaction notCancelledInteraction = new Interaction(
      Name = 'Not Cancelled Interaction',
      Status__c = 'Scheduled'
    );

    Interaction stillCancelledInteraction = new Interaction(
      Name = 'Still Cancelled Interaction',
      Status__c = 'Cancelled'
    );

    List<Interaction> oldInteractions = new List<Interaction>();
    oldInteractions.add(notCancelledInteraction);
    oldInteractions.add(stillCancelledInteraction);

    insert oldInteractions;

    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    for (Interaction currentInteraction : oldInteractions) {
      oldMap.put(currentInteraction.Id, currentInteraction);
    }

    List<Interaction> newInteractions = new List<Interaction>();
    for (Interaction currentInteraction : oldInteractions) {
      Interaction newInteraction = new Interaction(
        Name = currentInteraction.Name,
        Id = currentInteraction.Id,
        Status__c = currentInteraction.Status__c
      );
    }

    InteractionActions actions = new InteractionActions();
    List<Interaction> cancelledInteractions = actions.findCancelledInteractions(
      oldMap,
      newInteractions
    );
    System.assertEquals(
      true,
      cancelledInteractions.isEmpty(),
      'No Interactions have been cancelled so none should return'
    );
  }

  /**
   * @description helper method to create a person account
   * @param firstName String the first name of the person
   * @param lastName String the last name of the person
   * @param ocvId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static Account createTestAccount(
    String firstName,
    String lastName,
    String ocvId
  ) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.RecordTypeId = personAccountRecordTypeId;

    return testAccount;
  }
}
