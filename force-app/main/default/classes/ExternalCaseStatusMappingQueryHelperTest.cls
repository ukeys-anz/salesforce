/**
 * @author Hrushikesh Pathak
 * @since 08/03/2024
 * @description test class for the ExternalCaseStatusMappingQueryHelper
 */
@isTest
public with sharing class ExternalCaseStatusMappingQueryHelperTest {
  // Test method to check if the statusToMetadataMap map is not empty
  @isTest
  public static void testGetStatusToInternalDescriptionMap() {
    Test.startTest();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getStatusToMetadataMap();
    Test.stopTest();
    Assert.isTrue(!statusToMetadataMap.isEmpty(), 'Map should not be empty');
  }

  // Test method to check if the statusToCaseStatusMap map is not empty
  @isTest
  public static void testGetStatusToCaseStatusMap() {
    Test.startTest();
    Map<String, External_Case_Status_Mapping__mdt> statusToCaseStatusMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getRecordTypeStatusToMetadataMap();
    Test.stopTest();
    Assert.isTrue(!statusToCaseStatusMap.isEmpty(), 'Map should not be empty');
  }
}
