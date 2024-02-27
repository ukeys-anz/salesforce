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
    CCRMValidateAddressModelV3 obj = CCRMValidateAddressModelV3.parse(
      Service.getStaticResource('mock_ccrmQasSuccessResponse')
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMValidateAddressModelV3'
    );
  }

  @isTest
  static void testParseGetSelectedAddress() {
    CCRMGetSelectedAddressModel obj = CCRMGetSelectedAddressModel.parse(
      Service.getStaticResource('mock_ccrmQaSelectedAddressResponse')
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMGetSelectedAddressModel'
    );
  }

  @isTest
  static void testParseGetSelectedAddressV3() {
    CCRMGetSelectedAddressModelV3 obj = CCRMGetSelectedAddressModelV3.parse(
      Service.getStaticResource('mock_ccrmQasSelectedAddressResponseV2')
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMGetSelectedAddressModelV3'
    );
  }
}
