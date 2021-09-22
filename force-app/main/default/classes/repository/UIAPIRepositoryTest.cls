/**
 * @author Shermal Warnakula
 * @since Sep 2021
 * @description Test class for {@link UIAPIRepository}
 * @group Repository
 */
@isTest
public with sharing class UIAPIRepositoryTest {
  /**
   * @description validate fetching valid picklist values via UI-API (mocked values in force-app/main/default/classes/services/UIAPIServiceMock.cls)
   */
  @isTest
  static void testValidResponse() {
    // GIVEN
    // a picklist field in salesforce has multiple values defined against it

    // WHEN
    // 'getPickListValuesByRecordType()' method is called by passing in object name, field API name, and record type id
    Test.startTest();
    UIAPIRepository uiAPI = new UIAPIRepository();
    List<PicklistWrapper> plValues = uiAPI.getPickListValuesByRecordType(
      'Case',
      'Sub_Type__c',
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('General_Inquiry')
        .getRecordTypeId()
    );
    Test.stopTest();

    // THEN - 01
    // 'value' of the picklist value should be returned as a String
    System.assertEquals(
      'Privacy',
      plValues[0].value,
      'Failed to extract the "value" of picklist entry via UI-API'
    );

    // THEN - 02
    // 'label' of the picklist value should be returned as a String
    System.assertEquals(
      'About ANZ Plus',
      plValues[1].label,
      'Failed to extract the "label" of picklist entry via UI-API'
    );

    // THEN - 03
    // 'value' of the controlling picklist value should be returned as a String (if available)
    System.assertEquals(
      'Cards',
      plValues[2].controllingPLValues[0],
      'Failed to extract the "value" of controlling picklist entry via UI-API'
    );

    // THEN - 04
    // 'value' of all controlling picklist values (in case of more than one controlling/parent picklist values) should be returned as a list of Strings (if available)
    System.assert(
      plValues[3].controllingPLValues.size() == 2,
      'Failed to extract "value" of multiple controlling picklist entries via UI-API'
    );
  }
}
