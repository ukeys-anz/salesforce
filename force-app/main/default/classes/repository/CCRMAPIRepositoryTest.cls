/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description test class for CCRMAPIRepository
 * @group Repository
 */
@isTest
public with sharing class CCRMAPIRepositoryTest {
  @isTest
  static void testGetValidateAbn() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel getAbnInfo = apiRepo.validateAbn('11005357522');

    // Verify response received contains fake values
    System.assertEquals(
      'Active',
      getAbnInfo.AbnStatus,
      'Validate response should be Active'
    );
  }

  @isTest
  static void testGetValidateAcn() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel getAcnInfo = apiRepo.validateAcn('005357522');

    // Verify response received contains fake values
    System.assertEquals(
      '11005357522',
      getAcnInfo.Abn,
      'Validated ABN should be returned'
    );
  }

  @isTest
  static void testSearchPartyInfo() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    Lead record = new Lead();
    CCRMSearchPartyModel searchPartyInfo = apiRepo.searchPartyInfo(record);

    // Verify response received contains fake values
    System.assertEquals(
      '123456789',
      searchPartyInfo.certifiedResults[0].ocvId,
      'Expected ocvId to be 123456789'
    );
  }

  @isTest
  static void testCreatePartyInfo() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    Lead record = new Lead();
    CCRMCreatePartyModel createPartyInfo = apiRepo.createParty(record);

    // Verify response received contains fake values
    System.assertEquals(
      '1234567891',
      createPartyInfo.capcisId,
      'The returned capcisId does not match'
    );
  }

  @isTest
  static void testMaintainParty() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    Lead record = new Lead();
    DCRMMaintainPartyModel maintainPartyResponse = apiRepo.maintainParty(
      record
    );

    // Verify response received contains fake values
    System.assertNotEquals(
      Null,
      maintainPartyResponse.ocvId,
      'The returned ocvId does not match'
    );
  }

  @isTest
  static void testGetAddressesLWC() {
    CCRMValidateAddressModel getAddressesLWC = CCRMAPIRepository.getAddressesLWC(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertEquals(
      6,
      getAddressesLWC.count,
      'address should score should return'
    );
  }

  @isTest
  static void testGetSelectedAddressLWC() {
    CCRMGetSelectedAddressModel getAddressesLWC = CCRMAPIRepository.getSelectedAddressLWC(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertEquals(
      'B',
      getAddressesLWC.addressType,
      'Select Address should return'
    );
  }

  @isTest
  static void testGetAddressesLwcV2() {
    CCRMValidateAddressModelV2 getAddressesLWC = CCRMAPIRepository.getAddressesLwcV2(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertNotEquals(
      null,
      getAddressesLWC.result.suggestions,
      'address suggestions should return'
    );
  }

  @isTest
  static void testGetSelectedAddressLwcV2() {
    CCRMGetSelectedAddressModelV2 getAddressesLWC = CCRMAPIRepository.getSelectedAddressLwcV2(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertNotEquals(
      null,
      getAddressesLWC.result,
      'address result should return'
    );
  }
}
