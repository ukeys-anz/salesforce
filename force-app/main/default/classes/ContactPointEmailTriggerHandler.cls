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
      Map<Id, Account> relatedAccMap = CCRMContactPointEmailActions.getRelatedAccountMap(
        records
      );
      CCRMContactPointEmailActions contactPointEmailActionsVar = new CCRMContactPointEmailActions(
        relatedAccMap
      );

      CCRMContactPointEmailActions.ContactPointEmailWrapper existingOrProspectAccountsCPE = new CCRMContactPointEmailActions.ContactPointEmailWrapper();
      existingOrProspectAccountsCPE = contactPointEmailActionsVar.getExistingOrProspectCPE(
        records
      );

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectAccountsCPE.existingCPE,
        null
      );

      List<ContactPointEmail> conPointEmailList = new List<ContactPointEmail>();
      conPointEmailList.addAll(existingOrProspectAccountsCPE.prospectCPE);
      conPointEmailList.addAll(existingOrProspectAccountsCPE.existingCPE);

      contactPointEmailActionsVar.validateOrgIndividualEmailsLinking(records);

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
      Map<Id, Account> relatedAccMap = CCRMContactPointEmailActions.getRelatedAccountMap(
        records
      );
      CCRMContactPointEmailActions contactPointEmailActionsVar = new CCRMContactPointEmailActions(
        relatedAccMap
      );

      CCRMContactPointEmailActions.ContactPointEmailWrapper existingOrProspectAccountsCPE = new CCRMContactPointEmailActions.ContactPointEmailWrapper();
      existingOrProspectAccountsCPE = contactPointEmailActionsVar.getExistingOrProspectCPE(
        records
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPE.prospectCPE,
        null,
        true
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPE.existingCPE,
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
    Map<Id, Account> relatedAccMap = CCRMContactPointEmailActions.getRelatedAccountMap(
      records
    );
    CCRMContactPointEmailActions contactPointEmailActionsVar = new CCRMContactPointEmailActions(
      relatedAccMap
    );

    CCRMContactPointEmailActions.ContactPointEmailWrapper existingOrProspectAccountsCPE = new CCRMContactPointEmailActions.ContactPointEmailWrapper();
    existingOrProspectAccountsCPE = contactPointEmailActionsVar.getExistingOrProspectCPE(
      records
    );

    CCRMContactPointActions.updateContactPoints(records);

    CCRMContactPointEmailActions.unlinkProspectParentOnDeactivation(
      existingOrProspectAccountsCPE.prospectCPE,
      (Map<Id, ContactPointEmail>) oldMap
    );

    if (CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging()) {
      List<ContactPointEmail> conPointEmailList = new List<ContactPointEmail>();
      conPointEmailList.addAll(existingOrProspectAccountsCPE.prospectCPE);
      conPointEmailList.addAll(existingOrProspectAccountsCPE.existingCPE);

      CCRMContactPointEmailActions.validateExistingOrProspectEmails(
        conPointEmailList
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPE.prospectCPE,
        (Map<Id, ContactPointEmail>) oldMap,
        true
      );

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectAccountsCPE.existingCPE,
        (Map<Id, ContactPointEmail>) oldMap
      );

      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccountsCPE.existingCPE,
        (Map<Id, ContactPointEmail>) oldMap,
        false
      );
    }
  }
}
