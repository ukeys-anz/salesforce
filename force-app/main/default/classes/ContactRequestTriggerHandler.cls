/**
 * @author Prakash
 * @since 03/2022
 * @description  ContactRequestTriggerHandler is the handler class for ContactRequestTrigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class ContactRequestTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */

  public ContactRequestTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */

  public override void onAfterInsert() {
    ContactRequestTriggerActions.updateConfirmedCount(records);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */

  public override void onBeforeInsert() {
    ContactRequestTriggerActions.assignContactRequestQueue(records);
  }

  /** @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    ContactRequestTriggerActions.handleCancelledRequest(oldMap, records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ContactRequestActions actions = new ContactRequestActions();

    List<ContactRequest> requests = actions.findRequestsThatNowBelongToUser(
      oldMap,
      records
    );
    List<ContactRequest> acceptedRequests = actions.acceptContactRequests(
      requests
    );
    List<Interaction> interactions = actions.createInteractionsFromRequests(
      acceptedRequests
    );
    actions.insertInteractions(interactions);

    List<InteractionSummary> summaries = actions.createInteractionSummariesFromInteractions(
      interactions
    );
    actions.insertSummaries(summaries);

    List<Event> events = actions.createEventsFromInteractions(interactions);
    actions.insertEvents(events);
  }
}
