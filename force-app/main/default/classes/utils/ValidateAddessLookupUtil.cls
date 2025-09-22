/**
 * @author Shivsharan Giram
 * @since 10/2023
 * @description class to Find valid Country and State.
 */
public with sharing class ValidateAddessLookupUtil {
  /**
   * @description Return map of CountryName to CountryCode from DCRM_CountryMapping__mdt metadata
   * @return map of CountryName to CountryCode
   * @US CC-7217
   * @testClass - ValidateAddessLookupUtilTest
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getCountryNameToCodeMap() {
    Map<String, String> countryNameToCodeMap = new Map<String, String>();

    for (
      DCRM_CountryMapping__mdt mdt : DCRM_CountryMapping__mdt.getAll().values()
    ) {
      countryNameToCodeMap.put(
        (String) mdt.Label,
        (String) mdt.Country_Code__c
      );
    }
    return countryNameToCodeMap;
  }
  /**
   * @description Return map of StateName to StateCode from DCRM_StateMapping__mdt metadata
   * @return map of StateName to StateCode
   * @US CC-7217
   * @testClass ValidateAddessLookupUtilTest
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getStateNameToCodeMap() {
    Map<String, String> stateNameToCodeMap = new Map<String, String>();

    for (
      DCRM_StateMapping__mdt mdt : DCRM_StateMapping__mdt.getAll().values()
    ) {
      stateNameToCodeMap.put((String) mdt.Label, (String) mdt.State_Code__c);
    }
    return stateNameToCodeMap;
  }
}
