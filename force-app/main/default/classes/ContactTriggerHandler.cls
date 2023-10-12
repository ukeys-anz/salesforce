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
      CCRMContactActions.ContactWrapper conWrap = new CCRMContactActions.ContactWrapper();
      conWrap = CCRMContactActions.getExistingOrProspectContacts(records);

      List<Contact> conList = new List<Contact>();
      conList.addAll(conWrap.prosContact);
      conList.addAll(conWrap.activeContact);

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
      CCRMContactActions.ContactWrapper conWrap = new CCRMContactActions.ContactWrapper();
      conWrap = CCRMContactActions.getExistingOrProspectContacts(records);

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        conWrap.prosContact,
        null,
        true
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        conWrap.activeContact,
        null,
        false
      );
    }
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
    CCRMContactActions.ContactWrapper conWrap = new CCRMContactActions.ContactWrapper();
    conWrap = CCRMContactActions.getExistingOrProspectContacts(records);

    Boolean isAllowedProfileCheck = CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging();
    if (isAllowedProfileCheck) {
      List<Contact> conList = new List<Contact>();
      conList.addAll(conWrap.prosContact);
      conList.addAll(conWrap.activeContact);

      CCRMContactActions.validateExistingOrProspectContacts(conList);
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        conWrap.prosContact,
        (Map<Id, Contact>) oldMap,
        true
      );
    }

    CCRMContactActions.hideCommercialContacts(
      records,
      (Map<Id, Contact>) oldMap
    );

    if (isAllowedProfileCheck) {
      CCRMCustomerProfileUpdateHelper.restrictEdit(
        conWrap.activeContact,
        (Map<Id, Contact>) oldMap
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        conWrap.activeContact,
        (Map<Id, Contact>) oldMap,
        false
      );
    }
  }
}
