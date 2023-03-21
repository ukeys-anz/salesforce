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
    CCRMValidateAddressModel obj = CCRMValidateAddressModel.parse(
      Service.getStaticResource('mock_ccrmQasSuccessResponse')
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMValidateAddressModel'
    );
  }

  @isTest
  static void testParseGetAddressesV2() {
    CCRMValidateAddressModelV2 obj = CCRMValidateAddressModelV2.parse(
      Service.getStaticResource('mock_ccrmQasSuccessResponseV2')
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMValidateAddressModelV2'
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
  static void testParseGetSelectedAddressV2() {
    CCRMGetSelectedAddressModelV2 obj = CCRMGetSelectedAddressModelV2.parse(
      Service.getStaticResource('mock_ccrmQasSelectedAddressResponseV2')
    );
    System.assertNotEquals(
      null,
      obj,
      'JSON string must be parsed to CCRMGetSelectedAddressModelV2'
    );
  }
}
