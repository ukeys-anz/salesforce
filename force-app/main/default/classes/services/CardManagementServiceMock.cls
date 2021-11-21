/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description Mock implementation of card management api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class CardManagementServiceMock extends Service {
  private static HttpCalloutResponse response = new HttpCalloutResponse();

  @TestVisible
  private static HttpCalloutResponse fraudCardResponseAccordingStatus(
    String cardNumber
  ) {
    if (cardNumber == '23572357') {
      response.statusCode = 500;
      response.successful = false;
      response.error = new UnsuccessChangeStatusException(
        'Changing status on this card is not accepted'
      );
    } else {
      response.statusCode = 200;
      response.successful = true;
    }
    return response;
  }
  /**
   * @param fraudLockInformation `Map<String,String>` which contains:
   * - cardNumber card number to send to api
   * - ocvId customer id
   * - status chosen by fraud agent
   * - reason for fraud action. If chosen to cancel the card, this will be "Fraud"
   * @return `HttpCalloutResponse` the api response
   * @description fraud lock/unlock/cancel cards api
   */
  public override HttpCalloutResponse setFraudCardStatus(
    Map<String, String> fraudLockInformation
  ) {
    String cardNumber = fraudLockInformation.get('cardNumber');

    if (!preset) {
      response = CardManagementServiceMock.fraudCardResponseAccordingStatus(
        cardNumber
      );
    }
    return response;
  }
  /**
   * @author Farid Masjedi
   * @since Sep 2021
   * @description api service exception
   */
  public class UnsuccessChangeStatusException extends Exception {
  }
}
