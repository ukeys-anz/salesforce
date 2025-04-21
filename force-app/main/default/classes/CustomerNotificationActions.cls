/**
 * @author Nilesh
 * @since 04/2025
 * @description CustomerNotificationActions class is to handle all the Customer Notification Action Actions
 */
public with sharing class CustomerNotificationActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Update Action Counter if action performed by the customer
   * @param recordsWhereStatusChanged List of Cases
   */
  public static void updateActionCounter(
    List<Customer_Action__c> recordsWhereStatusChanged
  ) {
    List<Customer_Action__c> listOfCustomerActionToUpdate = new List<Customer_Action__c>();

    for (Customer_Action__c eachRecord : recordsWhereStatusChanged) {
      eachRecord.Action_Counter__c = eachRecord.Action_Counter__c + 1;
      listOfCustomerActionToUpdate.add(eachRecord);
    }
  }
}
