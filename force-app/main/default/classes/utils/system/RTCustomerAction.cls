/**
 * @author Nilesh Kalal
 * @since April 2025
 * @description Holds cached Customer Action Record Types.
 */
public with sharing class RTCustomerAction {
  static QueryRT base = QueryRT.of(Customer_Action__c.SObjectType);
  public static Id customerNotificationAction = base.getId(
    'Customer_Notification_Action'
  );
}
