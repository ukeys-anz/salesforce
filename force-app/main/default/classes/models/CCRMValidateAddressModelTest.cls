/**
 * @author Boobalakrishnan Duraisamy
 * @since Jun 2022
 * @description test class for address model classes
 * @group Models
 */
@isTest
public with sharing class CCRMValidateAddressModelTest {
  @isTest
  static void testParseGetAddresses() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_ccrmQasSuccessResponse'
    ];
    CCRMValidateAddressModel obj = CCRMValidateAddressModel.parse(
      sr.Body.toString()
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMValidateAddressModel'
    );
  }

  @isTest
  static void testParseGetSelectedAddress() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_ccrmQaSelectedAddressResponse'
    ];
    CCRMGetSelectedAddressModel obj = CCRMGetSelectedAddressModel.parse(
      sr.Body.toString()
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMGetSelectedAddressModel'
    );
  }
}
