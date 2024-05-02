/**
 * @author Peter Charalambous
 * @since Tue Mar 19 2024
 * @description trigger handler for Customer Action trigger
 */

public with sharing class CustomerActionTriggerHandler extends Lib_TriggerHandler {
  Set<Id> recordTypeIdSet = new Set<Id>{
    SObjectType.Customer_Action__c.getRecordTypeInfosByDeveloperName()
      .get('Loan_Offer_Acceptance')
      .recordTypeId,
    SObjectType.Customer_Action__c.getRecordTypeInfosByDeveloperName()
      .get('Mortgage_Contract_Acceptance')
      .recordTypeId,
    SObjectType.Customer_Action__c.getRecordTypeInfosByDeveloperName()
      .get('Customer_Action')
      .recordTypeId
  };

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CustomerActionTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Customer Action records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Customer_Action__c customerAction = (Customer_Action__c) record;
    return recordTypeIdSet.contains(customerAction.RecordTypeId);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CustomerActionTriggerActions.populateCustomerName(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CustomerActionTriggerActions.populateCustomerName(records);
  }
}
