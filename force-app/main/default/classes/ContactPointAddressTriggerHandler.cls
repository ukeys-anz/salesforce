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
      CCRMContactPointAddressActions.ContactPointAddressWrapper cpaWrap = new CCRMContactPointAddressActions.ContactPointAddressWrapper();

      //This is used to get the list of Contact Point Address records which are linked to Existing or Prospect Customer.
      cpaWrap = CCRMContactPointAddressActions.getExistingOrProspectCPA(
        records
      );

      //Create the Customer Profile Update records for the ContactPointAddress against the Prospect Customer
      //and the fields values that will stage will be the Non-KYC fields that is store in ContactPointAddress FieldSet.
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpaWrap.prosCPA,
        null,
        true
      );

      //Create the Customer Profile Update records for the ContactPointAddress linked to Existing Customer
      //and the fields values that will stage will be the Non-KYC fields that is store in custom metadata (DCRM_Customer_Management_Non_KYC_Fields__mdt)
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpaWrap.activeCPA,
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
    CCRMContactPointAddressActions.ContactPointAddressWrapper cpaWrap = new CCRMContactPointAddressActions.ContactPointAddressWrapper();
    cpaWrap = CCRMContactPointAddressActions.getExistingOrProspectCPA(records);

    CCRMContactPointActions.updateContactPoints(records);

    CCRMContactPointAddressActions.unlinkProspectParentOnDeactivation(
      cpaWrap.prosCPA,
      (Map<Id, ContactPointAddress>) oldMap
    );

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpaWrap.prosCPA,
        (Map<Id, ContactPointAddress>) oldMap,
        true
      );

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        cpaWrap.activeCPA,
        (Map<Id, ContactPointAddress>) oldMap
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpaWrap.activeCPA,
        (Map<Id, ContactPointAddress>) oldMap,
        false
      );
    }
  }
}
