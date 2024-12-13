/**
 * @description       : Handler Class for Case Trigger
 * @author            : Smruti Khobragade | Salesforce
 * @group             :
 * @last modified on  : 11-28-2024
 * @last modified by  :  Smruti Khobragade | Salesforce
 **/

public with sharing class BrokerRequestHelpCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public BrokerRequestHelpCaseTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Broker Enquiry Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.brokerEnquiry;
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    BrokerRequestHelpCaseEventActions.publishEventForCase(
      records,
      (Map<Id, Case>) oldMap,
      'update'
    );
  }
}
