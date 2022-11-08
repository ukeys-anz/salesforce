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
    System.assertEquals('123456789', searchPartyInfo.certifiedResults[0].ocvId);
  }

  @isTest
  static void testCreatePartyInfo() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    Lead record = new Lead();
    CCRMCreatePartyModel createPartyInfo = apiRepo.createParty(record);

    // Verify response received contains fake values
    System.assertEquals('1234567891', createPartyInfo.capcisId);
  }
}
