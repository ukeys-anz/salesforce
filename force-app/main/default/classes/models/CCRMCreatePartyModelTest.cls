/**
 * @author Boobalakrishnan Duraisamy
 * @since Aug 2022
 * @description test class for CCRMCreatePartyModel class
 * @group Models
 */
@isTest
public with sharing class CCRMCreatePartyModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_ccrmCreatePartyModel'
    ];
    CCRMCreatePartyModel obj = CCRMCreatePartyModel.parse(sr.Body.toString());
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMCreatePartyModel'
    );
  }
}
