/**
 * @author  Laxmi Teja Vuyyuru
 * @since 11/2023
 * @description  ComplaintResolutionTriggerHandler is the handler class for Complaint Resolution Trigger for clearing the Remedy dependent values
 * based on Complaint Remedy and Complaint Sub Remedy
 */
public with sharing class ComplaintResolutionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public ComplaintResolutionTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    IDRComplaintResolutionActions.populateDependentFields(records);
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRComplaintResolutionActions.populateDependentFields(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
  }

  /**
   * @description onBeforeDelete
   */
  public override void onBeforeDelete() {
  }
}
