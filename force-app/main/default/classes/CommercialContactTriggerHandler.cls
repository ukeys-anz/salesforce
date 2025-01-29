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
    return contactRecord.RecordTypeId == RTContact.organisation &&
      !CCRMLeadConversionActions.leadConverionFlow;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialContactActionsHelper.getExistingOrProspectContacts(records);
    CommercialContactActions.populateLastName(
      CommercialContactActionsHelper.existingAndProspectContactsList,
      null
    );
    CommercialContactActions.populateName(
      CommercialContactActionsHelper.existingAndProspectContactsList,
      null
    );

    CommercialContactActions.validateExistingOrProspectContacts(
      CommercialContactActionsHelper.existingAndProspectContactsList
    );

    CommercialContactActions.checkMaxContactsPerOrganisation(
      CommercialContactActionsHelper.existingAndProspectContactsList
    );
  }

  /**
   * @description After Insert Action of Contact.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    CommercialContactActionsHelper.getExistingOrProspectContacts(records);

    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      CommercialContactActionsHelper.prospectContactsList,
      null,
      true
    );

    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      CommercialContactActionsHelper.existingContactsList,
      null,
      false
    );

    CommercialContactActions.deleteCommercialContactsWithoutContactDetails(
      records
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialContactActionsHelper.getExistingOrProspectContacts(records);

    CommercialContactActions.validateExistingOrProspectContacts(
      CommercialContactActionsHelper.existingAndProspectContactsList
    );

    CommercialContactActions.populateLastName(
      CommercialContactActionsHelper.existingAndProspectContactsList,
      (Map<Id, Contact>) oldMap
    );
    CommercialContactActions.populateName(
      CommercialContactActionsHelper.existingAndProspectContactsList,
      (Map<Id, Contact>) oldMap
    );

    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      CommercialContactActionsHelper.prospectContactsList,
      (Map<Id, Contact>) oldMap,
      true
    );

    CCRMCustomerProfileUpdateHelper.restrictEdit(
      CommercialContactActionsHelper.existingContactsList,
      (Map<Id, Contact>) oldMap
    );

    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      CommercialContactActionsHelper.existingContactsList,
      (Map<Id, Contact>) oldMap,
      false
    );

    CommercialContactActions.deleteCommercialContactsWithoutContactDetails(
      records
    );
  }
}
