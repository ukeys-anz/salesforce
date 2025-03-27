/**
 * @author Ashish
 * @since Feb 2025
 * @description extended service class for mocking  OCV Retrieve party API
 * @group Service
 */
public with sharing class RetrievePartyServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public RetrievePartyServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @param record Lead record from lwc component
   * @return HttpCalloutResponse
   * @description fetches party information for lead conversion
   */
  public virtual HttpCalloutResponse retrieveParty(
    OCVRetrievePartyPayloadWrapper record
  ) {
    response.body = 'Success';
    return response;
  }
}
