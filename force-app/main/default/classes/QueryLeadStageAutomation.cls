/**
 * @author Ashwin Mohan
 * @since May 2025
 * @description Query class for Lead Stage Automation metadata records
 */
public with sharing class QueryLeadStageAutomation {
  private static List<Lead_Stage_Automation__mdt> leadStageAutomationList = [
    SELECT
      Id,
      MasterLabel,
      Response_Status__c,
      Response_Type_CreateOpportunity__c,
      isActive__c,
      What_happens_next__c,
      Lead_Record_Type__c,
      Lead_Status__c,
      Next_Lead_Status__c
    FROM Lead_Stage_Automation__mdt
    WHERE isActive__c = TRUE
    WITH SYSTEM_MODE
  ];

  private static Map<String, Lead_Stage_Automation__mdt> leadStageAutomationMap = (Map<String, Lead_Stage_Automation__mdt>) ListUtil.mapBy(
    leadStageAutomationList,
    Lead_Stage_Automation__mdt.MasterLabel
  );

  /**
   * @description This method returns a map of metadata record w.r.t MasterLabel
   * @return The metadata record associated with MasterLabel
   */
  public static Map<String, Lead_Stage_Automation__mdt> getAll() {
    return leadStageAutomationMap;
  }
}
