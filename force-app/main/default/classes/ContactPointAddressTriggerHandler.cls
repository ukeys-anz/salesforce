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
    CCRMContactPointAddressActions.checkExistingAddressOnProspect(records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    List<ContactPointAddress> prospectAddresses = CCRMContactPointAddressActions.extractProspectCpa(
      records
    );

    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      prospectAddresses,
      null
    );
  }

  /**
   * @description onBeforeUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<ContactPointAddress> prospectAddresses = CCRMContactPointAddressActions.extractProspectCpa(
      records
    );

    CCRMContactPointAddressActions.unlinkProspectParentOnDeactivation(
      prospectAddresses,
      (Map<Id, ContactPointAddress>) oldMap
    );
    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      prospectAddresses,
      (Map<Id, ContactPointAddress>) oldMap
    );
  }
}
