/**
 * @author Adnan
 * @since Sep 2021
 * @description test class for CMOSAPIRepository
 * @group Repository
 */
@isTest
public with sharing class CMOSAPIRepositoryTest {
  @isTest
  static void testGetCustomerInfoLWC() {
    Map<String, Object> info = CMOSAPIRepository.getCustomerInfoLWC(
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
