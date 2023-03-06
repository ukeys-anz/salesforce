/**
 * @author Boobalakrishnan Duraisamy
 * @since  01/2023
 * @group CCRM (Commercial CRM)
 * @description to handle all commercial CRM financial account actions
 */
public with sharing class CCRMFinancialAccountActions {
  private static Map<String, String> sourceStatusLabelByValue = new Map<String, String>();

  /**
   * @description checks if there is any change in source status field to populate source status display field for the end users
   * @name validateSourceStatus
   * @param records The Financial Account records passed from beforeUpdate()
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate.
   */
  public static void validateSourceStatus(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, SObject> oldMap
  ) {
    sourceStatusLabelByValue = CommonUtil.getPicklistLabelsByValues(
      FinServ__FinancialAccount__c.Source_System_Status__c
    );
    for (FinServ__FinancialAccount__c record : records) {
      FinServ__FinancialAccount__c oldRecord = oldMap != null
        ? (FinServ__FinancialAccount__c) oldMap.get(record.Id)
        : null;
      if (
        record.Source_System_Status__c != null &&
        (oldRecord == null ||
        record.Source_System_Status__c != oldRecord.Source_System_Status__c)
      ) {
        setSourceStatus(record);
      }
    }
  }

  /**
   * @description Populate source status display read only field from source status picklist field label.
   * @name setSourceStatus
   * @param record Financial account record from the trigger.
   */
  private static void setSourceStatus(FinServ__FinancialAccount__c record) {
    String sourceStatusLabel = sourceStatusLabelByValue.containsKey(
        record.Source_System_Status__c
      )
      ? sourceStatusLabelByValue.get(record.Source_System_Status__c)
      : null;
    if (sourceStatusLabel.length() > 9) {
      if (
        sourceStatusLabelByValue.get(record.Source_System_Status__c)
          .contains('CAPCIS')
      ) {
        record.Source_System_Status_Display__c = sourceStatusLabelByValue.get(
            record.Source_System_Status__c
          )
          .remove('CAPCIS');
      }
      if (
        sourceStatusLabelByValue.get(record.Source_System_Status__c)
          .contains('CACHE')
      ) {
        record.Source_System_Status_Display__c = sourceStatusLabelByValue.get(
            record.Source_System_Status__c
          )
          .remove('CACHE');
      }
    }
  }
}
