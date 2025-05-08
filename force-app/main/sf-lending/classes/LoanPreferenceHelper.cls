/**
 * @description Helper for the Loan Preference feature.
 * @author Raman Gupta
 * @since Jan 2025
 */
public with sharing class LoanPreferenceHelper {
  private static final ErrorCodeMessageMappingRepository LP_ERROR_MAPPING_REPOSITORY = (ErrorCodeMessageMappingRepository) Lib_InstanceProvider.forType(
    ErrorCodeMessageMappingRepository.class
  );

  /**
   * @description To get the error message correspond to error code
   * @param errorCode error code from response
   * @return String as error message
   */
  public static String getErrorCodeMapping(Integer errorCode) {
    try {
      String errorCodeStr = String.valueOf(errorCode);
      // Get Metadata Mapping
      List<ErrorCode_Message_Mapping__mdt> additionalFundPurposeList = LP_ERROR_MAPPING_REPOSITORY.queryErrorCodeMessageMapping();
      Map<String, ErrorCode_Message_Mapping__mdt> fundPurposeMap = (Map<String, ErrorCode_Message_Mapping__mdt>) ListUtil.mapBy(
        additionalFundPurposeList,
        ErrorCode_Message_Mapping__mdt.MasterLabel
      );
      if (fundPurposeMap.containsKey(errorCodeStr)) {
        return fundPurposeMap.get(errorCodeStr).Message__c;
      }
      return '';
    } catch (Exception exp) {
      Logger.error(
        'Exception in getting the funds Purpose and Category Mapping',
        exp
      );
      Logger.saveLog();
      return '';
    }
  }
}
