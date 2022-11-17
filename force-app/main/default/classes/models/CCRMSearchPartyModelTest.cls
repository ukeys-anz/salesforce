/**
 * @author Boobalakrishnan Duraisamy
 * @since June 2022
 * @description test class for CCRMSearchPartyModel class
 * @group Models
 */
@isTest
public with sharing class CCRMSearchPartyModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_ccrmSearchPartyModel'
    ];
    CCRMSearchPartyModel obj = CCRMSearchPartyModel.parse(sr.Body.toString());
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMSearchPartyModel'
    );
  }
}
