/**
 * @author Batya Aisman Sufrin
 * @since 10/2024
 * @description  AutoKYCQACustomerUpdateTriggerHandler is the handler class for Customer Profile Update Trigger.
 */
public with sharing class AutoKYCQACustomerUpdateTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public AutoKYCQACustomerUpdateTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Customer Profile Updates records
   * for Add Restraints or Remove Restraints
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Customer_Profile_Updates__c cpuRecord = (Customer_Profile_Updates__c) record;
    return cpuRecord.Object_Name__c == 'Case' &&
      (cpuRecord.TriggeredFrom__c == AutoKYCQACaseActions.ADD_RESTRAINTS ||
      cpuRecord.TriggeredFrom__c == AutoKYCQACaseActions.REMOVE_RESTRAINTS);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_After_Update started: ' + System.now());
    if (Label.CustomerRestraintEnabled.equalsIgnoreCase('true')) {
      AutoKYCQACaseActions.updateRestraintResults(
        records,
        (Map<Id, Customer_Profile_Updates__c>) oldMap,
        AutoKYCQACaseActions.ADD_RESTRAINTS
      );
      AutoKYCQACaseActions.updateRestraintResults(
        records,
        (Map<Id, Customer_Profile_Updates__c>) oldMap,
        AutoKYCQACaseActions.REMOVE_RESTRAINTS
      );
    }
    Logger.debug('On_After_Update finished: ' + System.now()).save();
  }
}
