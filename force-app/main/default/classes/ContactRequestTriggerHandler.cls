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
    ContactRequestTriggerActions.updateConfirmedCount(records, true);
    ContactRequestTriggerActions crTriggerActions = new ContactRequestTriggerActions();
    ContactRequestActions actions = new ContactRequestActions();
    List<ContactRequest> automatedRequests = actions.returnRequestsWithAutomatedPurpose(
      records
    );
    if (!automatedRequests.isEmpty()) {
      List<Interaction> interactions = actions.createInteractionsFromRequests(
        automatedRequests
      );
      actions.insertInteractions(interactions);
    }
  }

  /** @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    ContactRequestTriggerActions.handleCancelledRequest(oldMap, records);
  }

  /** @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    ContactRequestTriggerActions crActions = new ContactRequestTriggerActions();
    Map<Id, Appointment_Commitment__c> appointmentCommitmentMap = crActions.getRelatedAppCommtDetails(
      records
    );
    crActions.validateContactRequests(records);
    if (!appointmentCommitmentMap.isEmpty()) {
      crActions.prepopulateAppointmentCommitmentValues(
        records,
        appointmentCommitmentMap
      );
    }
  }
}
