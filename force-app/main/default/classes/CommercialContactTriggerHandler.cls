/**
 * @author       : Naman Garg
 * @since        : Oct 2024
 * @description  : CommercialContactTriggerHandler is the handler class for Contact Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialContactTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialContactTriggerHandler
   */
  public CommercialContactTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of commercial contacts
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Contact contactRecord = (Contact) record;
    return contactRecord.RecordTypeId == RTContact.organisation;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    if (CCRMLeadConversionActions.leadConverionFlow) {
      return;
    }
    List<Contact> existingAndProspectContactsList = CommercialContactActionsHelper.getExistingOrProspectContacts(
      records
    );
    CommercialContactActions.populateLastName(
      existingAndProspectContactsList,
      null
    );
    CommercialContactActions.populateName(
      existingAndProspectContactsList,
      null
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    if (CCRMLeadConversionActions.leadConverionFlow) {
      return;
    }
    List<Contact> existingAndProspectContactsList = CommercialContactActionsHelper.getExistingOrProspectContacts(
      records
    );
    CommercialContactActions.populateLastName(
      existingAndProspectContactsList,
      (Map<Id, Contact>) oldMap
    );
    CommercialContactActions.populateName(
      existingAndProspectContactsList,
      (Map<Id, Contact>) oldMap
    );
  }
}
