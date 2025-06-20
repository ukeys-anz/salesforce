/**
 * @author Naman Garg
 * @since May 2025
 * @description holds CCRM Lead to Platform Event Mapping metadata records
 */
public with sharing class QueryLeadToPlatformEventMapping {
  static List<CCRM_Lead_to_Platform_Event_Mapping__mdt> leadToPlatformEventMappingList = [
    SELECT
      Id,
      Destination_System__c,
      Lead_Field_API_Name__c,
      Platform_Event_Field_API_Name__c
    FROM CCRM_Lead_to_Platform_Event_Mapping__mdt
    WITH SYSTEM_MODE
  ];
  static Map<String, List<CCRM_Lead_to_Platform_Event_Mapping__mdt>> leadToPlatformEventMappingMap = (Map<String, List<CCRM_Lead_to_Platform_Event_Mapping__mdt>>) ListUtil.groupBy(
    leadToPlatformEventMappingList,
    CCRM_Lead_to_Platform_Event_Mapping__mdt.Destination_System__c
  );

  /**
   * @description Returns list metadata record for the destination system
   * @param destinationSystem
   * @return List<CCRM_Lead_to_Platform_Event_Mapping__mdt> metadata record associated with that destination system
   */
  public static List<CCRM_Lead_to_Platform_Event_Mapping__mdt> get(
    String destinationSystem
  ) {
    return leadToPlatformEventMappingMap.get(destinationSystem);
  }
}
