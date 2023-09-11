/**
 * @author Shivam Swaraj
 * @since June 2022
 * @description Test Class for FetchRecordTypeName
 */
@isTest
public with sharing class FetchRecordTypeNameTest {
  /**
   * @description This test just tests that the Store Record Type exists in salesforce
   */
  @isTest
  static void getRecordTypeDeveloperNameTest() {
    String recordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get('Store')
      .getRecordTypeId();
    RecordType storeRecordType = FetchRecordTypeName.getRecordTypeDeveloperName(
      recordTypeId
    );
    System.assertNotEquals(
      null,
      storeRecordType,
      'Store record type should exist'
    );
  }
}
