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

    List<ContactPointEmail> prospectEmails = CCRMContactPointEmailActions.extractProspectCpe(
      records
    );
    CCRMContactPointEmailActions.validateProspectEmails(prospectEmails);
    CCRMContactPointEmailActions.checkExistingEmailOnProspect(prospectEmails);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    List<ContactPointEmail> prospectEmails = CCRMContactPointEmailActions.extractProspectCpe(
      records
    );

    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      prospectEmails,
      null
    );
  }

  /**
   * @description onBeforUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<ContactPointEmail> prospectEmails = CCRMContactPointEmailActions.extractProspectCpe(
      records
    );

    CCRMContactPointActions.updateContactPoints(records);

    CCRMContactPointEmailActions.validateProspectEmails(prospectEmails);
    CCRMContactPointEmailActions.unlinkProspectParentOnDeactivation(
      prospectEmails,
      (Map<Id, ContactPointEmail>) oldMap
    );
    CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
      prospectEmails,
      (Map<Id, ContactPointEmail>) oldMap
    );
  }
}
