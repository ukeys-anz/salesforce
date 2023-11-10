/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description ContactPointAddressTriggerHandler is the handler class for ContactPointAddress Trigger which extends Lib_TriggerHandler from the trigger framework used.
 * @runTests CCRMContactPointAddressActionsTest
 */
public with sharing class ContactPointAddressTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforeInsert to handle Before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMContactPointAddressActions.copyParentIdToCustomerName(records);

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMContactPointAddressActions.checkExistingAddressOnProspectOrExistingCust(
        records
      );
    }
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMContactPointAddressActions.ContactPointAddressWrapper existingOrProspectAccountsCPA = new CCRMContactPointAddressActions.ContactPointAddressWrapper();

      //This is used to get the list of Contact Point Address records which are linked to Existing or Prospect Customer.
      existingOrProspectAccountsCPA = CCRMContactPointAddressActions.getExistingOrProspectCPA(
        records
      );

      //Create the Customer Profile Update records for the ContactPointAddress against the Prospect Customer
      //and the fields values that will stage will be the Non-KYC fields that is store in ContactPointAddress FieldSet.
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPA.prospectCPA,
        null,
        true
      );

      //Create the Customer Profile Update records for the ContactPointAddress linked to Existing Customer
      //and the fields values that will stage will be the Non-KYC fields that is store in custom metadata (DCRM_Customer_Management_Non_KYC_Fields__mdt)
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPA.existingCPA,
        null,
        false
      );
    }
  }

  /**
   * @description onBeforeUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMContactPointAddressActions.ContactPointAddressWrapper existingOrProspectAccountsCPA = new CCRMContactPointAddressActions.ContactPointAddressWrapper();
    existingOrProspectAccountsCPA = CCRMContactPointAddressActions.getExistingOrProspectCPA(
      records
    );

    CCRMContactPointActions.updateContactPoints(records);

    CCRMContactPointAddressActions.unlinkProspectParentOnDeactivation(
      existingOrProspectAccountsCPA.prospectCPA,
      (Map<Id, ContactPointAddress>) oldMap
    );

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPA.prospectCPA,
        (Map<Id, ContactPointAddress>) oldMap,
        true
      );

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectAccountsCPA.existingCPA,
        (Map<Id, ContactPointAddress>) oldMap
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPA.existingCPA,
        (Map<Id, ContactPointAddress>) oldMap,
        false
      );
    }
  }
}
