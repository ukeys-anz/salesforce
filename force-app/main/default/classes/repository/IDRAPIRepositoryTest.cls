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
    Map<String, Object> info = IDRAPIRepository.getCustomerInfoLWC(
      '12345',
      'CAP ID'
    );
    Map<String, Object> profile = (Map<String, Object>) info.get('profile');

    // Verify response received contains fake values
    System.assertEquals(
      'TestFirstName',
      profile.get('firstname'),
      'Matches the first name'
    );
  }
}
