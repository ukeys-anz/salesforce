/**
 * @author Naman Garg
 * @since May 2025
 * @description holds Lead Status Transformation metadata records
 */
public with sharing class QueryLeadStatusTransformation {
  private static List<Lead_Status_Transformation__mdt> leadStatusTransformList = [
    SELECT
      Id,
      MasterLabel,
      Lead_Status__c,
      Outcome_Type__c,
      UNICA_Lead_Status__c
    FROM Lead_Status_Transformation__mdt
    WITH SYSTEM_MODE
  ];
  private static Map<String, Lead_Status_Transformation__mdt> leadStatusTransformationMap = new Map<String, Lead_Status_Transformation__mdt>();
  static {
    for (Lead_Status_Transformation__mdt mdtRecord : leadStatusTransformList) {
      if (String.isNotBlank(mdtRecord.Outcome_Type__c)) {
        leadStatusTransformationMap.put(mdtRecord.MasterLabel, mdtRecord);
        continue;
      }
      leadStatusTransformationMap.put(mdtRecord.Lead_Status__c, mdtRecord);
    }
  }

  /**
   * @description Returns a metadata record for the Status
   * @param status Lead Status
   * @return The metadata record associated with Lead status
   */
  public static Lead_Status_Transformation__mdt get(String status) {
    return leadStatusTransformationMap.get(status);
  }
}
