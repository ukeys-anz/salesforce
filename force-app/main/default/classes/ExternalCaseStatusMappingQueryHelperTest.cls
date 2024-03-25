/**
 * @author Hrushikesh Pathak
 * @since 08/03/2024
 * @description test class for the ExternalCaseStatusMappingQueryHelper
 */
@isTest
public with sharing class ExternalCaseStatusMappingQueryHelperTest {
  // Test method to check if the statusToInternalDesMap map is not empty
  @isTest
  public static void testGetStatusToInternalDescriptionMap() {
    Test.startTest();
    Map<String, String> statusToInternalDesMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getStatusToInternalDescriptionMap();
    Test.stopTest();
    Assert.isTrue(!statusToInternalDesMap.isEmpty(), 'Map should not be empty');
  }

  // Test method to check if the statusToCaseStatusMap map is not empty
  @isTest
  public static void testGetStatusToCaseStatusMap() {
    Test.startTest();
    Map<String, String> statusToCaseStatusMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getStatusToCaseStatusMap();
    Test.stopTest();
    Assert.isTrue(!statusToCaseStatusMap.isEmpty(), 'Map should not be empty');
  }
}
