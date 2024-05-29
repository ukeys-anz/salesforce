/**
 * @author Adnan
 * @since Sep 2021
 * @description test class for IDRAPIRepository
 * @group Repository
 */
@isTest
public with sharing class IDRAPIRepositoryTest {
  @isTest
  static void testGetCustomerInfoLWC() {
    IDRCustomerInformationModel info = IDRAPIRepository.getCustomerInfoLWC(
      '12345',
      'CAP ID'
    );

    // Verify response received contains fake values
    System.assertEquals(
      'PATRICK ABBISOGNI',
      info.profile.firstName,
      'Matches the first name'
    );
  }

  @isTest
  static void testGetSNOWEventInfoLWCforValidId() {
    Test.startTest();
    SNOWIntegrationModel info = IDRAPIRepository.getSNOWEventInfoLWC(
      'IRE0073261'
    );
    Test.stopTest();
    // Verify response received contains fake values
    System.assertEquals(
      'IRE0073261',
      info.result[0].eventNumber,
      'Risk Event Id Matches'
    );
  }
}
