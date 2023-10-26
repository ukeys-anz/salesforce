/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description ContactPointEmailTriggerHandler is the handler class for ContactPointEmail Trigger which extends Lib_TriggerHandler from the trigger framework used.
 * @runTests CCRMContactPointEmailActionsTest
 */
public with sharing class ContactPointEmailTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforeInsert to handle Before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMContactPointEmailActions.copyParentIdToCustomerName(records);

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMContactPointEmailActions.ContactPointEmailWrapper cpeWrap = new CCRMContactPointEmailActions.ContactPointEmailWrapper();
      cpeWrap = CCRMContactPointEmailActions.getExistingOrProspectCPE(records);

      List<ContactPointEmail> conPointEmailList = new List<ContactPointEmail>();
      conPointEmailList.addAll(cpeWrap.prosCPE);
      conPointEmailList.addAll(cpeWrap.activeCPE);

      CCRMContactPointEmailActions.validateOrgIndividualEmailsLinking(records);

      CCRMContactPointEmailActions.validateExistingOrProspectEmails(
        conPointEmailList
      );

      CCRMContactPointEmailActions.checkExistingEmailOnProspectOrExistingCust(
        records
      );
    }
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      CCRMContactPointEmailActions.ContactPointEmailWrapper cpeWrap = new CCRMContactPointEmailActions.ContactPointEmailWrapper();
      cpeWrap = CCRMContactPointEmailActions.getExistingOrProspectCPE(records);

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpeWrap.prosCPE,
        null,
        true
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpeWrap.activeCPE,
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
    CCRMContactPointEmailActions.ContactPointEmailWrapper cpeWrap = new CCRMContactPointEmailActions.ContactPointEmailWrapper();
    cpeWrap = CCRMContactPointEmailActions.getExistingOrProspectCPE(records);

    CCRMContactPointActions.updateContactPoints(records);

    CCRMContactPointEmailActions.unlinkProspectParentOnDeactivation(
      cpeWrap.prosCPE,
      (Map<Id, ContactPointEmail>) oldMap
    );

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      List<ContactPointEmail> conPointEmailList = new List<ContactPointEmail>();
      conPointEmailList.addAll(cpeWrap.prosCPE);
      conPointEmailList.addAll(cpeWrap.activeCPE);

      CCRMContactPointEmailActions.validateExistingOrProspectEmails(
        conPointEmailList
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpeWrap.prosCPE,
        (Map<Id, ContactPointEmail>) oldMap,
        true
      );

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        cpeWrap.activeCPE,
        (Map<Id, ContactPointEmail>) oldMap
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        cpeWrap.activeCPE,
        (Map<Id, ContactPointEmail>) oldMap,
        false
      );
    }
  }
}
