/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description test class for CCRMValidateAbnAcnModel class
 * @group Models
 */
@isTest
public with sharing class CCRMValidateAbnAcnModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_ccrmAbnAcnModel'
    ];
    CCRMValidateAbnAcnModel obj = CCRMValidateAbnAcnModel.parse(
      sr.Body.toString()
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMValidateAbnAcnModel'
    );
  }
}
