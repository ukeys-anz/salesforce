/**
 * @author Raman Gupta
 * @since Dec 2024
 * @description To handle all error code and message mapping
 */

public with sharing class QueryUpdateLoanPrefErrorCodeMapping {
  @TestVisible
  private static Map<Id, ErrorCode_Message_Mapping__mdt> recordsById = new Map<Id, ErrorCode_Message_Mapping__mdt>();

  @TestVisible
  private static Map<String, ErrorCode_Message_Mapping__mdt> recordsByMasterLabel = new Map<String, ErrorCode_Message_Mapping__mdt>();

  static {
    for (ErrorCode_Message_Mapping__mdt record : [
      SELECT Id, Message__c, MasterLabel
      FROM ErrorCode_Message_Mapping__mdt
      WITH USER_MODE
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
  public static ErrorCode_Message_Mapping__mdt getById(Id recordId) {
    return recordsById.get(recordId);
  }

  /**
   * @description Retrieves a record by its key attribute
   * @param keyValue The key attribute value to look up
   * @return The corresponding record, or null if not found
   */
  public static ErrorCode_Message_Mapping__mdt getByMasterLabel(
    String keyValue
  ) {
    return recordsByMasterLabel.get(keyValue);
  }

  /**
   * @description Retrieves a record by its key attribute
   * @param keyValue The key attribute value to look up
   * @return The corresponding record, or null if not found
   */
  public static ErrorCode_Message_Mapping__mdt getByMasterLabel(
    Integer keyValue
  ) {
    String keyStr = String.valueOf(keyValue);
    return getByMasterLabel(keyStr);
  }
}
