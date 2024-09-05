/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description Mock implementation of Vault api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class VaultServiceMock extends VaultService {
    /**
     * @description constructor which sets default status code and successful
     */
    public VaultServiceMock() {
      response.statusCode = 200;
      response.successful = true;
    }
  
    @TestVisible
    private static final String FULL_CARD_NUMBER_SUCCESS = getStaticResource(
      'mock_fullCardNumberSuccess'
    );

  /**
   * @param ocvId customer ocvId
   * @param cardNumberToBeDetokenizedRequest customer id
   * @return `HttpCalloutResponse` method response
   * @description stravinsky package closure api
   */
    public override HttpCalloutResponse getFullCardNumberDetails(
      String ocvId,
      DetokenizationRequestModel cardNumberToBeDetokenizedRequest
      ) {
      if (!preset) {
      response.body = FULL_CARD_NUMBER_SUCCESS;
      }
      return response;
    }
}