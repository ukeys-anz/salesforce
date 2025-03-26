/**
 * @description To handle all the Additional Funds Purpose Mapping Metadata queries
 * @author Arpit Pittie
 * @since Nov 2024
 */
public with sharing class QueryAdditionalFundsPurposeMapping {
  @TestVisible
  private static Map<Id, Additional_Fund_Purpose_Mapping__mdt> recordsById = new Map<Id, Additional_Fund_Purpose_Mapping__mdt>();

  @TestVisible
  private static Map<String, Additional_Fund_Purpose_Mapping__mdt> recordsByMasterLabel = new Map<String, Additional_Fund_Purpose_Mapping__mdt>();

  static {
    for (Additional_Fund_Purpose_Mapping__mdt record : [
      SELECT Id, MasterLabel, Purpose__c, Sorting_Order__c
      FROM Additional_Fund_Purpose_Mapping__mdt
      WITH USER_MODE
      ORDER BY Sorting_Order__c
    ]) {
      recordsById.put(record.Id, record);
      recordsByMasterLabel.put(record.MasterLabel, record);
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
   * @description Retrieves a record by its key attribute
   * @param keyValue The key attribute value to look up
   * @return The corresponding record, or null if not found
   */
  public static Additional_Fund_Purpose_Mapping__mdt getByMasterLabel(
    String keyValue
  ) {
    return recordsByMasterLabel.get(keyValue);
  }

  /**
   * @description get all the values of its key attribute
   * @return the keySet for key attribute
   */
  public static Set<String> getAllMasterLabelKeys() {
    return recordsByMasterLabel.keySet();
  }
}
