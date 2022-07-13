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
    System.assertEquals('Active', getAbnInfo.AbnStatus);
  }

  @isTest
  static void testGetValidateAcn() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel getAcnInfo = apiRepo.validateAcn('005357522');

    // Verify response received contains fake values
    System.assertEquals('11005357522', getAcnInfo.Abn);
  }
}
