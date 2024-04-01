/**
 * @author Tan Phan
 * @since 09/2022
 * @description ContactTriggerHandler is the handler class for Contact Trigger which extends Lib_TriggerHandler from the trigger framework used.
 * @runTests CCRMContactActionsTest
 */

public with sharing class ContactTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Before Insert Action of Contact.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    if (CCRMLeadConversionActions.leadConverionFlow) {
      return;
    }

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMContactActions.ContactWrapper existingOrProspectContacts = new CCRMContactActions.ContactWrapper();
      existingOrProspectContacts = CCRMContactActions.getExistingOrProspectContacts(
        records
      );

      List<Contact> conList = new List<Contact>();
      conList.addAll(existingOrProspectContacts.prospectContacts);
      conList.addAll(existingOrProspectContacts.existingContacts);

      CCRMContactActions.validateOrgIndividualContactsLinking(records);

      CCRMContactActions.validateExistingOrProspectContacts(conList);

      CCRMContactActions.checkMaxContactsPerOrganisation(records);
    }
  }

  /**
   * @description After Insert Action of Contact.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    if (CCRMLeadConversionActions.leadConverionFlow) {
      return;
    }

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMContactActions.ContactWrapper existingOrProspectContacts = new CCRMContactActions.ContactWrapper();
      existingOrProspectContacts = CCRMContactActions.getExistingOrProspectContacts(
        records
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectContacts.prospectContacts,
        null,
        true
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectContacts.existingContacts,
        null,
        false
      );
    }

    CCRMContactActions.deleteCommercialContactsWithoutContactDetails(records);
  }
  /**
   * @description Before Update Action of Contact.
   * @name onBeforeUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of contact.
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    if (CCRMLeadConversionActions.leadConverionFlow) {
      return;
    }
    CCRMContactActions.ContactWrapper existingOrProspectContacts = new CCRMContactActions.ContactWrapper();
    existingOrProspectContacts = CCRMContactActions.getExistingOrProspectContacts(
      records
    );

    Boolean isAllowedProfileCheck = CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging();
    if (isAllowedProfileCheck) {
      List<Contact> conList = new List<Contact>();
      conList.addAll(existingOrProspectContacts.prospectContacts);
      conList.addAll(existingOrProspectContacts.existingContacts);

      CCRMContactActions.validateExistingOrProspectContacts(conList);
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectContacts.prospectContacts,
        (Map<Id, Contact>) oldMap,
        true
      );
    }

    if (isAllowedProfileCheck) {
      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectContacts.existingContacts,
        (Map<Id, Contact>) oldMap
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectContacts.existingContacts,
        (Map<Id, Contact>) oldMap,
        false
      );
    }

    CCRMContactActions.deleteCommercialContactsWithoutContactDetails(records);
  }
}
