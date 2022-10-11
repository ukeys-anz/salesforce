/**
 * @author Farid Masjedi
 * @date Sep 2021
 * @description Test class for {@link CardManagementAPIRepository}
 * @group Repository
 */
@IsTest
public inherited sharing class CardManagementAPIRepositoryTest {
  @isTest
  static void testSetFraudCardStatusSuccess() {
    Test.startTest();
    CardManagementAPIRepository cardManagementApi = new CardManagementAPIRepository();
    Map<String, String> fraudLockInformation = new Map<String, String>{
      'cardNumber' => '123456789',
      'ocvId' => '1111',
      'status' => 'Block CNP',
      'reason' => ''
    };
    Boolean successStatusChanged = cardManagementApi.setFraudCardStatus(
      fraudLockInformation
    );
    Test.stopTest();
    System.assertEquals(
      true,
      successStatusChanged,
      'Check if the fraud status change is valid'
    );
  }

  @isTest
  static void testSetFraudCardStatusFailure() {
    Exception errorException;
    Test.startTest();
    CardManagementAPIRepository cardManagementApi = new CardManagementAPIRepository();
    Map<String, String> fraudLockInformation = new Map<String, String>{
      'cardNumber' => '23572357',
      'ocvId' => '1111',
      'status' => 'Block CNP',
      'reason' => ''
    };
    try {
      cardManagementApi.setFraudCardStatus(fraudLockInformation);
    } catch (Exception e) {
      errorException = e;
    }

    Test.stopTest();
    System.assertEquals(
      'Changing status on this card is not accepted',
      errorException.getMessage(),
      false
    );
  }
}
