/**
 * @author Shivsharan Giram
 * @since 10/2024
 * @description ValidateAddessLookupUtilTest is provide unit test coverage for ValidateAddessLookupUtil.
 */
@isTest
public with sharing class ValidateAddessLookupUtilTest {
  /**
   * @description test method for getCountryNameToCodeMap
   */
  @isTest
  static void testGetCountryNameToCodeMap() {
    Test.startTest();
    Map<String, String> result = ValidateAddessLookupUtil.getCountryNameToCodeMap();
    Test.stopTest();
    // Validate the results
    Assert.areEqual(
      'USA',
      result.get('United States'),
      'DCRM_CountryMapping metadata does not have United State value'
    );
    Assert.areEqual(
      'CAN',
      result.get('Canada'),
      'DCRM_CountryMapping metadata does not have Canada value'
    );
  }
  /**
   * @description test method for getCountryNameToCodeMap
   */
  @isTest
  static void testGetStateNameToCodeMap() {
    Test.startTest();
    Map<String, String> result = ValidateAddessLookupUtil.getStateNameToCodeMap();
    Test.stopTest();
    Assert.areEqual(
      'NSW',
      result.get('New South Wales'),
      'DCRM_StateMapping metadata does not have New South Wales value'
    );
    Assert.areEqual(
      'NT',
      result.get('Northern Territory'),
      'DCRM_StateMapping metadata does not have Northern Territory value'
    );
  }
}
