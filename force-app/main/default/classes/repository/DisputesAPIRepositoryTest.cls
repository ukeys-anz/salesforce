/**
 * @author Emma Bindi
 * @date July 2022
 * @description Test class for {@link DisputesAPIRepository}
 * @group Repository
 */
@isTest
public with sharing class DisputesAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'Raise_Dispute' });
  }

  /**
   * @description fetch search tokenized card, mocked values in force-app/main/default/staticresources/mock_searchTokenizedCard.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void getTokenizedCardNumberValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      Test.startTest();
      DisputesAPIRepository disputesAPI = new DisputesAPIRepository();

      String tokenizedCardNumber = disputesAPI.getTokenizedCardNumber(
        '1111',
        'f5491d5d-06fa-48ba-af94-ccaddebfe744'
      );

      Test.stopTest();
      System.assertEquals(
        '8051997368527878',
        tokenizedCardNumber,
        'Tokenized card number from mock response should be received'
      );
    }
  }

  private static HttpCalloutResponse getTokenizedCardNumberInvalidResponse() {
    return generateInvalidResponse('Tokenized card number search failed');
  }

  /**
   * @description invalid search tokenized card number response
   */
  @isTest
  static void testGetTokenizedCardNumberInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      String tokenizedCardNumber;
      HttpCalloutResponse res = getTokenizedCardNumberInvalidResponse();

      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;

      Test.startTest();
      DisputesAPIRepository disputesAPI = new DisputesAPIRepository();
      try {
        tokenizedCardNumber = disputesAPI.getTokenizedCardNumber(
          '1111',
          'f5491d5d-06fa-48ba-af94-ccaddebfe744'
        );
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        null,
        tokenizedCardNumber,
        'Null value should be returned if invalid response as error should not block'
      );
    }
  }

  private static HttpCalloutResponse generateInvalidResponse(
    String exceptionMsg
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(exceptionMsg);
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
