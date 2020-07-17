/**
 * @author Boobalakrishnan Duraisamy
 * @since  07/2020
 * @description This class will be called in User Provisioning Request Trigger to update User Object based on the Request Type.
 */
public with sharing class CustomerFeedbackActions {
  // Invalid OCV ID Error Message
  private static final String INVALID_OCV_ID_ERROR = 'OCV_ID__c is not present in Salesforce';

  /**
   * @description This function is called to get the Account Id based on OCV ID received from qualtrics.
   * @param custFbList List of Customer Feedback records from the trigger
   * @param ocvIds Set of OCV IDs from trigger
   */
  public static void getAccountId(
    List<Customer_Feedback__c> custFbList,
    Set<String> ocvIds
  ) {
    Map<String, String> accountIdMap = new Map<String, String>();

    for (Account acc : [
      SELECT Id, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN :ocvIds
    ]) {
      accountIdMap.put(acc.OCV_ID__c, acc.Id);
    }

    for (
      Customer_Feedback__c record : (List<Customer_Feedback__c>) custFbList
    ) {
      if (accountIdMap.containsKey(record.OCV_ID__c)) {
        record.Account_Name__c = accountIdMap.get(record.OCV_ID__c);
      } else {
        record.addError(INVALID_OCV_ID_ERROR);
      }
    }
  }
}
