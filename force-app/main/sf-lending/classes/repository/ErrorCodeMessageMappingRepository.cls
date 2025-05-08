/**
 * @description To handle all error code and message mapping for Loan Preference
 * @author Raman Gupta
 * @since Dec 2024
 */
public with sharing class ErrorCodeMessageMappingRepository {
  /**
   * @description Get all the records for the Additional Funds Purpose Mapping
   * @return List<ErrorCode_Message_Mapping__mdt> list of all records
   */
  public List<ErrorCode_Message_Mapping__mdt> queryErrorCodeMessageMapping() {
    if (!PermissionUtils.canQuery('ErrorCode_Message_Mapping__mdt')) {
      return null;
    }

    return [
      SELECT Id, MasterLabel, Message__c
      FROM ErrorCode_Message_Mapping__mdt
      WITH USER_MODE
    ];
  }
}
