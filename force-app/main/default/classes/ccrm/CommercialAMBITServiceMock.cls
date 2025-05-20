/**
 * @author Naman Garg
 * @since  Jan 2025
 * @description Service Mock class for CommercialAMBITService
 */

public with sharing class CommercialAMBITServiceMock extends CommercialAMBITService {
  /**
   * @description mock createAMBITQuote response
   * @param payload requires to call AMBIT API
   * @return HttpCalloutResponse
   */
  public virtual override HttpCalloutResponse createAMBITQuote(
    CommercialAMBITRequestModel payload
  ) {
    super.response.body = '{"data": {"responseMessage" : "AMBIT Quote created Successfully", "isSuccessful":true} }';
    super.response.statusCode = 200;
    super.response.successful = true;
    return response;
  }
}
