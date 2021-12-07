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
}
