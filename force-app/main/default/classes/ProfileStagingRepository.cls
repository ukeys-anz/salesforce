/**
 * @description Provide database operation for {@link ProfileStagingTracker}
 * @author Tan Phan
 * @since 06/2024
 */
public with sharing class ProfileStagingRepository {
  /**
   * @description Event configuration metadata records.
   */
  private static List<ProfileStagingEventConfig__mdt> allConfig = [
    SELECT
      DataSchema__c,
      EventType__c,
      PartitionKey__c,
      PayloadModel__c,
      RelatedIdField__c,
      Source__c,
      Subject__c,
      TriggeredFrom__c,
      PublishOldEvent__c,
      Active__c
    FROM ProfileStagingEventConfig__mdt
    WHERE TriggeredFrom__c != NULL AND Active__c = TRUE
    WITH SYSTEM_MODE
  ];

  /**
   * @description Event configuration metadata records with TriggeredFrom__c as the key for easy retrieval of
   * the configuration based on the trigger source.
   */
  private static Map<string, ProfileStagingEventConfig__mdt> eventConfigMap = (Map<String, ProfileStagingEventConfig__mdt>) ListUtil.mapBy(
    allConfig,
    Customer_Profile_Updates__c.TriggeredFrom__c
  );

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
    //This query is set to run in SYSTEM_MODE, by the time query is executed user has already created the CPU based on their access.
    //This query is for the purpose of firing events with latest info. This is system initiated action to fire event.
    return [
      SELECT
        Id,
        Action__c,
        AsIsValue__c,
        Case__c,
        Case__r.CaseNumber,
        Customer_Name__r.RecordType.Id,
        Customer_Name__r.RecordType.DeveloperName,
        Customer_Name__r.OCV_Id__c,
        Customer_Name__r.Source_System_ID__c,
        Customer_Name__r.Source_System_Name__c,
        Customer_Name__r.FinServ__Status__c,
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
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description Queries event configurations based on the provided list of triggers.
   * @param triggerFrom unique triggerFrom value to get the event configuration.
   * @return A event configuration record matching the provided triggerFrom.
   */
  public ProfileStagingEventConfig__mdt getEventConfig(String triggerFrom) {
    return eventConfigMap.get(triggerFrom);
  }
}
