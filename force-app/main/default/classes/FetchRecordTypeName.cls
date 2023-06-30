/**
 * @author Shivam Swaraj
 * @since June 2022
 * @description used for fetching recordtypename from interactionCreateOmniscriptWrapper
 */
public with sharing class FetchRecordTypeName {
  /**
   * @description Retrieves the existing values present in the Interaction Record on Load
   * @param recordTypeId
   * @return Returns a map of key and values of the recordtype id and recordtype.
   */
  @AuraEnabled(cacheable=true)
  public static String getRecordTypeDeveloperName(String recordTypeId) {
    Map<Id, RecordType> rts = new Map<Id, RecordType>(
      [SELECT DeveloperName, Id FROM RecordType WHERE Id = :recordTypeId]
    );
    return JSON.serialize(rts);
  }

  /**
   * @description Retrieves the existing values present in the Interaction Record on Load
   * @param recordId
   * @return Returns a map of key and values of the interaction id and recordtype.
   */
  @AuraEnabled(cacheable=true)
  public static String getRecordTypeDeveloperNameEdit(String recordId) {
    Map<Id, Interaction> rts = new Map<Id, Interaction>(
      [
        SELECT Id, RecordType.DeveloperName
        FROM Interaction
        WHERE Id = :recordId
      ]
    );
    return JSON.serialize(rts);
  }
}
