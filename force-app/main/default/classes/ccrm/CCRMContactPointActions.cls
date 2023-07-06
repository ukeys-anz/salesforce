/**
 * @author Fawad Akhtar
 * @since 03/2023
 * @description CCRMContactPointActions is class to handle all the CCRM Contact Point Object Actions
 * @runTests CCRMContactPointActionsTest
 */
public with sharing class CCRMContactPointActions {
  public static final String ACTIVE_TO_DATE = 'ActiveToDate';
  public static final String PREVIOUS_RELATED_ACCOUNT = 'Previous_Related_Account__c';
  public static final String PARENT_ID = 'ParentId';

  /**
   * @description Update ParentId to null for ContactPoint records where ActiveToDate is in the past and isUpdateable returns true.
   * @name updateContactPoints
   * @param records - List of ContactPoint records to update
   */
  public static void updateContactPoints(List<SObject> records) {
    List<SObject> updatedRecords = new List<SObject>();
    for (SObject cp : records) {
      Date activeToDate = (Date) cp.get(ACTIVE_TO_DATE);
      if (
        activeToDate != null &&
        Date.today() > activeToDate &&
        cp.get(PARENT_ID) != null
      ) {
        updatedRecords.add(cp);
      }
    }
    hideContactPoints(updatedRecords);
  }

  /**
   * @description Helper method to hide contact point records by clearing out ParentId (after backup to Previous_Related_Account__c)
   * @param records List of contact point records
   */
  public static void hideContactPoints(List<SObject> records) {
    for (SObject record : records) {
      record.put(PREVIOUS_RELATED_ACCOUNT, record.get(PARENT_ID));
      record.put(PARENT_ID, null);
    }
  }
}
