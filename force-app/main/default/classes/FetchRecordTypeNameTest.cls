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
    String expectedJsonString = '{"012Bo0000005njFIAQ":{"attributes":{"type":"RecordType","url":"/services/data/v58.0/sobjects/RecordType/012Bo0000005njFIAQ"},"DeveloperName":"Store","Id":"012Bo0000005njFIAQ"}}';
    System.assertEquals(
      recordTypeNameJson,
      expectedJsonString,
      'Issue in Getting The RecordType Name'
    );
  }
}
