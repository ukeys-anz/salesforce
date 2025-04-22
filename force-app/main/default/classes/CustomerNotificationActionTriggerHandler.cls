/**
 * @description Handler for Customer Notification Action which extends Lib_TriggerHandler framework.
 * @author Nilesh
 * @since April 2025
 */
public with sharing class CustomerNotificationActionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CustomerNotificationActionTriggerHandler() {
    super();
  }

  //Validate the record relevance to this handler based on record type
  public override Boolean isValidRecord(SObject record) {
    return ((Customer_Action__c) record).RecordTypeId ==
      RTCustomerAction.customerNotificationAction;
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CustomerNotificationActions.updateActionCounter(records);
  }
}
