/**
 * @author Shivam Swaraj
 * @since June 2022
 * @description used for fetching recordtypename from interactionCreateOmniscriptWrapper
 */
public with sharing class InteractionFetchRecordTypeName {
  /**
   * @description Retrieves the existing values present in the Interaction Record on Load
   * @param recordTypeId
   * @return Returns a map of key and values of the recordtype id and recordtype.
   */
  @AuraEnabled(cacheable=true)
  public static RecordType getRecordTypeDeveloperName(String recordTypeId) {
    return [SELECT DeveloperName, Id FROM RecordType WHERE Id = :recordTypeId];
  }
}
