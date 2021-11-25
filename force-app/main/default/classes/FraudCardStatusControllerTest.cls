/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description FraudCardStatusControllerTest is the test class for {@link FraudCardStatusController}
 */
@isTest
public with sharing class FraudCardStatusControllerTest {
  @isTest
  static void validFraudCardStatusChange() {
    Test.startTest();
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'Test Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = false
    );
    insert acc;
    Map<String, Map<String, String>> fraudLockObject = new Map<String, Map<String, String>>();
    Map<String, String> chatterInformation = new Map<String, String>{
      'recordId' => acc.Id,
      'chatterMessage' => 'Testing chatter message'
    };
    Map<String, String> fraudLockInformation = new Map<String, String>{
      'cardNumber' => '123456789',
      'ocvId' => '1111',
      'status' => 'Block CNP',
      'reason' => ''
    };
    fraudLockObject.put('chatterInformation', chatterInformation);
    fraudLockObject.put('fraudLockInformation', fraudLockInformation);
    Boolean result = FraudCardStatusController.setFraudCardStatus(
      fraudLockObject
    );
    Test.stopTest();
    System.assertEquals(
      true,
      result,
      'Check if the fraud status change is valid'
    );
  }

  /*
   * @description invalid status change. The Account with card Number '23572357'
   * has been made to make the unsuccessful mock api response.
   */

  @isTest
  static void invalidFraudCardStatusChange() {
    Exception errorResult;

    Test.startTest();
    try {
      Faker faker = new Faker('AU');
      Account acc = new Account(
        Name = 'Test Account',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = false
      );
      insert acc;
      Map<String, Map<String, String>> fraudLockObject = new Map<String, Map<String, String>>();
      Map<String, String> chatterInformation = new Map<String, String>{
        'recordId' => acc.Id,
        'chatterMessage' => 'faild chatter post'
      };
      Map<String, String> fraudLockInformation = new Map<String, String>{
        'cardNumber' => '23572357',
        'ocvId' => '1111',
        'status' => 'Block CNP',
        'reason' => ''
      };
      fraudLockObject.put('chatterInformation', chatterInformation);
      fraudLockObject.put('fraudLockInformation', fraudLockInformation);

      Boolean result = FraudCardStatusController.setFraudCardStatus(
        fraudLockObject
      );
    } catch (Exception e) {
      errorResult = e;
    }

    Test.stopTest();

    System.assertEquals(
      errorResult.getMessage(),
      'Changing status on this card is not accepted',
      'Check if the fraud status change is invalid'
    );
  }
}
