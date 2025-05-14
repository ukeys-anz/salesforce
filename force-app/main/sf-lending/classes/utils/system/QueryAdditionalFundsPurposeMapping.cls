/**
 * @description To handle all the Additional Funds Purpose Mapping Metadata queries
 * @author Arpit Pittie
 * @since Nov 2024
 */
public with sharing class QueryAdditionalFundsPurposeMapping {
  @TestVisible
  private static Map<Id, Additional_Fund_Purpose_Mapping__mdt> recordsById = new Map<Id, Additional_Fund_Purpose_Mapping__mdt>();

  @TestVisible
  private static Map<String, Additional_Fund_Purpose_Mapping__mdt> recordsByPurpose = new Map<String, Additional_Fund_Purpose_Mapping__mdt>();

  @TestVisible
  private static List<Additional_Fund_Purpose_Mapping__mdt> additionalFundRecords = new List<Additional_Fund_Purpose_Mapping__mdt>();

  static {
    for (Additional_Fund_Purpose_Mapping__mdt record : [
      SELECT
        Id,
        MasterLabel,
        Purpose_Name__c,
        Sorting_Purpose__c,
        Sorting_Category__c,
        Category__c,
        Purpose_Label__c
      FROM Additional_Fund_Purpose_Mapping__mdt
      WITH USER_MODE
      ORDER BY Sorting_Category__c, Sorting_Purpose__c
    ]) {
      recordsById.put(record.Id, record);
      recordsByPurpose.put(record.Purpose_Name__c, record);
      additionalFundRecords.add(record);
    }
  }

  /**
   * @description Retrieves a record by its Id
   * @param recordId The unique identifier of the record
   * @return The corresponding record, or null if not found
   */
  public static Additional_Fund_Purpose_Mapping__mdt getById(Id recordId) {
    return recordsById.get(recordId);
  }

  /**
   * @description Retrieves a record by its purpose
   * @param purposeValue The purpose value to look up
   * @return The corresponding record, or null if not found
   */
  public static Additional_Fund_Purpose_Mapping__mdt getByPurpose(
    String purposeValue
  ) {
    return recordsByPurpose.get(purposeValue);
  }

  /**
   * @description Rerives all the records
   * @return List<Additional_Fund_Purpose_Mapping__mdt> list of records
   */
  public static List<Additional_Fund_Purpose_Mapping__mdt> getAll() {
    return additionalFundRecords;
  }
}
