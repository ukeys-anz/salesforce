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
    RecordType storeRecordType = InteractionFetchRecordTypeName.getRecordTypeDeveloperName(
      recordTypeId
    );
    System.assertNotEquals(
      null,
      storeRecordType,
      'Store record type should exist'
    );
  }
}
