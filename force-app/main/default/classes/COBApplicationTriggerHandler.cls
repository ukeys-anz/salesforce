/**
 * @description COBApplicationTriggerHandler is the handler class for COB Application Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
public with sharing class COBApplicationTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public COBApplicationTriggerHandler() {
    super();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    COBApplicationActions.createKYCQACase(
      records,
      (Map<Id, CustomerOnboardingApplication__c>) oldMap
    );
  }
}
