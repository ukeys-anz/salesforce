/**
 * @author Boobalakrishnan Duraisamy
 * @since 07/2020
 * @description  CustomerFeedbackTriggerHandler is the handler class for Customer Feedbacks Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class CustomerFeedbackTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CustomerFeedbackTriggerHandler() {
    super();
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   */
  public override void onApplyDefaults() {
    Set<String> ocvIds = new Set<String>();
    List<Customer_Feedback__c> custFbList = new List<Customer_Feedback__c>();

    for (Customer_Feedback__c record : (List<Customer_Feedback__c>) records) {
      if (
        String.isNotBlank(record.OCV_ID__c) &&
        String.isBlank(record.Account_Name__c)
      ) {
        ocvIds.add(record.OCV_ID__c);
        custFbList.add(record);
      }
    }
    if (!ocvIds.isEmpty()) {
      CustomerFeedbackActions.getAccountId(custFbList, ocvIds);
    }
  }
}