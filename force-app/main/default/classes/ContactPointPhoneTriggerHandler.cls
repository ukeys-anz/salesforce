/**
 * @author Fawad Akhtar
 * @since 03/2023
 * @description ContactPointPhoneTriggerHandler is the handler class for ContactPointPhone Trigger which extends Lib_TriggerHandler from the trigger framework used.
 * @runTests CCRMContactPointPhoneActionsTest
 */
public with sharing class ContactPointPhoneTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforeInsert to handle Before insert trigger actions.
   */
  public override void onBeforeInsert() {
    //Added as part of CC-4737
    ContactPointPhoneActions.copyParentIdToCustomerName(records);
    ContactPointPhoneActions.validateUsageType(records);

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      ContactPointPhoneActions.ContactPointPhoneWrapper existingOrProspectAccountsCPP = new ContactPointPhoneActions.ContactPointPhoneWrapper();
      existingOrProspectAccountsCPP = ContactPointPhoneActions.getExistingOrProspectCPP(
        records
      );

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectAccountsCPP.existingCPP,
        null
      );
      ContactPointPhoneActions.validatePhones(records);
      ContactPointPhoneActions.checkExistingPhoneOnIndividualRecords(records);
    }
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      ContactPointPhoneActions.ContactPointPhoneWrapper existingOrProspectAccountsCPP = new ContactPointPhoneActions.ContactPointPhoneWrapper();
      existingOrProspectAccountsCPP = ContactPointPhoneActions.getExistingOrProspectCPP(
        records
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPP.prospectCPP,
        null,
        true
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPP.existingCPP,
        null,
        false
      );
    }
  }

  /**
   * @description onBeforUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ContactPointPhoneActions.preventEdit(
      records,
      (Map<Id, ContactPointPhone>) oldMap
    );
    ContactPointPhoneActions.ContactPointPhoneWrapper existingOrProspectAccountsCPP = new ContactPointPhoneActions.ContactPointPhoneWrapper();
    existingOrProspectAccountsCPP = ContactPointPhoneActions.getExistingOrProspectCPP(
      records
    );

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      ContactPointPhoneActions.validatePhones(records);
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPP.prospectCPP,
        (Map<Id, ContactPointPhone>) oldMap,
        true
      );
      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectAccountsCPP.existingCPP,
        (Map<Id, ContactPointPhone>) oldMap
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPP.existingCPP,
        (Map<Id, ContactPointPhone>) oldMap,
        false
      );
    }
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    ContactPointPhoneActions.deleteExpiredRecords(
      records,
      (Map<Id, ContactPointPhone>) oldMap
    );
  }
}
