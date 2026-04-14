/**
 * @description       :  Handler class for ApplicationFormTrigger
 * @author            :  Akanksha Kulkarni | Salesforce
 * @last modified on  :  10-2025
 * @last modified by  :  Ali Mujtaba | Salesforce | 31-10-2025
 **/
public with sharing class ApplicationFormTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert/onBeforeDelete etc.
   */
  public ApplicationFormTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of AMBIT Application Form records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((ApplicationForm) record).RecordTypeId ==
      RTApplicationForm.ambitApplication;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @author Harshit Goyal | Salesforce | 02-13-2026
   **/
  public override void onBeforeInsert() {
    ApplicationFormActions.updateSourceSystemIdOnSyncChange(records, null);
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap old trigger values
   * @author Ali Mujtaba | Salesforce | 27-10-2025
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    ApplicationFormEventActions.publishSimpleApplicationFormEvent(
      (List<ApplicationForm>) records,
      (Map<Id, ApplicationForm>) oldMap,
      'add'
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap old trigger values
   * @author Ali Mujtaba | Salesforce | 30-10-2025
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ApplicationFormActions.updateBrokerOnApplicationForm(
      records,
      (Map<Id, ApplicationForm>) oldMap
    );
    ApplicationFormActions.preventCustomerChangeOnAppForm(
      records,
      (Map<Id, ApplicationForm>) oldMap
    );
    ApplicationFormActions.updateSourceSystemIdOnSyncChange(
      records,
      (Map<Id, ApplicationForm>) oldMap
    );
  }
}
