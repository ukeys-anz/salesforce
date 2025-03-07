/**
 * @description Provide database operation for {@link ProfileStagingTracker}
 * @author Tan Phan
 * @since 06/2024
 */
public with sharing class ProfileStagingRepository {
  /**
   * @description Queries customer profile updates along with customer info based on the provided list of records.
   * @param recordIds The set of customer profile update Ids to query.
   * @return A list of customer profile update records matching the provided IDs.
   */
  public List<Customer_Profile_Updates__c> queryCustomerProfileUpdates(
    Set<Id> recordIds
  ) {
    if (recordIds.isEmpty()) {
      return new List<Customer_Profile_Updates__c>();
    }
    return [
      SELECT
        Id,
        Action__c,
        Case__c,
        Case__r.CaseNumber,
        Customer_Name__r.RecordType.DeveloperName,
        Customer_Name__c,
        Error_Description__c,
        Object_Name__c,
        Occurrence_Number__c,
        Name,
        NewValue__c,
        OCV_Id__c,
        Source_System_ID__c,
        Source_System_Name__c,
        Status__c,
        ToBeValue__c,
        TriggeredFrom__c
      FROM Customer_Profile_Updates__c
      WHERE Id IN :recordIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Queries event configurations based on the provided list of triggers.
   * @param triggers The set of trigger events to query.
   * @return A list of event configuration records matching the provided triggers.
   */
  public List<ProfileStagingEventConfig__mdt> queryEventConfig(
    Set<String> triggers
  ) {
    if (triggers.isEmpty()) {
      return new List<ProfileStagingEventConfig__mdt>();
    }
    return [
      SELECT
        DataSchema__c,
        EventType__c,
        PartitionKey__c,
        PayloadModel__c,
        RelatedIdField__c,
        Source__c,
        Subject__c,
        TriggeredFrom__c
      FROM ProfileStagingEventConfig__mdt
      WHERE TriggeredFrom__c IN :triggers
      WITH USER_MODE
    ];
  }
}
