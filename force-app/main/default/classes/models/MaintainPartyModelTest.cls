/**
 * @author Ankit Garg
 * @since July 2023
 * @description test class for MaintainPartyModel class
 * @group Models
 */
@isTest
public with sharing class MaintainPartyModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_dcrmMaintainPartyModel'
    ];
    MaintainPartyModel obj = MaintainPartyModel.parse(sr.Body.toString());
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to MaintainPartyModel'
    );
  }
}
