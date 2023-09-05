/**
 * @author Shivam Swaraj
 * @since June 2022
 * @description Test Class for InteractionFetchRecordTypeName
 */
@isTest
public with sharing class InteractionFetchRecordTypeNameTest {
  /**
   * @description get recordtype name on create
   */
  @isTest
  static void getRecordTypeDeveloperNameTest() {
    String recordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get('Store')
      .getRecordTypeId();
    String recordTypeNameJson = InteractionFetchRecordTypeName.getRecordTypeDeveloperName(
      recordTypeId
    );
    String expectedJsonString = 'Store';
    Boolean isStoreExist = recordTypeNameJson.contains(expectedJsonString);
    System.assertEquals(true, isStoreExist, 'Store record type should exist');
  }
}
