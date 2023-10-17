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
    MLCRMContactPointPhoneActions.copyParentIdToCustomerName(records);

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      MLCRMContactPointPhoneActions.validatePhones(records);
      MLCRMContactPointPhoneActions.checkExistingPhoneOnIndividualRecords(
        records
      );
    }
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      MLCRMContactPointPhoneActions.ContactPointPhoneWrapper cppWrap = new MLCRMContactPointPhoneActions.ContactPointPhoneWrapper();
      cppWrap = MLCRMContactPointPhoneActions.getExistingOrProspectCPP(records);
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cppWrap.prosCPP,
        null,
        true
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cppWrap.activeCPP,
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
    CCRMContactPointActions.updateContactPoints(records);
    MLCRMContactPointPhoneActions.ContactPointPhoneWrapper cppWrap = new MLCRMContactPointPhoneActions.ContactPointPhoneWrapper();
    cppWrap = MLCRMContactPointPhoneActions.getExistingOrProspectCPP(records);
    MLCRMContactPointPhoneActions.unlinkProspectParentOnDeactivation(
      cppWrap.prosCPP,
      (Map<Id, ContactPointPhone>) oldMap
    );

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cppWrap.prosCPP,
        (Map<Id, ContactPointPhone>) oldMap,
        true
      );
      CCRMCustomerProfileUpdateHelper.restrictEdit(
        cppWrap.activeCPP,
        (Map<Id, ContactPointPhone>) oldMap
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cppWrap.activeCPP,
        (Map<Id, ContactPointPhone>) oldMap,
        false
      );
    }
  }
}
