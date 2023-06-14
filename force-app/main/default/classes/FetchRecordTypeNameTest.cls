/**
 * @author Shivam Swaraj
 * @since June 2022
 * @description Test Class for FetchRecordTypeName
 */
@isTest
public with sharing class FetchRecordTypeNameTest {
  /**
   * @description getOptionsValues tests successful response of visitdetails lwc component
   */
  @isTest
  static void getRecordTypeDeveloperNameTest() {
    String recordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get('Store')
      .getRecordTypeId();
    String recordTypeNameJson = FetchRecordTypeName.getRecordTypeDeveloperName(
      recordTypeId
    );
    String expectedJsonString = 'Store';
    Boolean isStoreExist = recordTypeNameJson.contains(expectedJsonString);
    System.assertEquals(true, isStoreExist, 'Store record type should exist');
  }
}
