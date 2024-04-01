/**
 * @author Ankit Garg
 * @since July 2023
 * @description test class for DCRMMaintainPartyModel class
 * @group Models
 */
@isTest
public with sharing class DCRMMaintainPartyModelTest {
  @isTest
  static void testParse() {
    User ocvIntegrationUser = CCRMTestDataFactory.createOCVIntegrationUser();
    System.runAs(ocvIntegrationUser) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_dcrmMaintainPartyModel'
      ];
      DCRMMaintainPartyModel obj = DCRMMaintainPartyModel.parse(
        sr.Body.toString()
      );
      System.assertNotEquals(
        null,
        obj,
        'JSON string must be parsed to DCRMMaintainPartyModel'
      );
    }
  }
}
