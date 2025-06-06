/**
 * @author Raman Gupta
 * @since March 2025
 * @description Mock service class for SOP And Party Update
 */
public with sharing class SOPServiceMock extends SOPService {
  /**
   * @description constructor which sets default code as succesful
   */
  public SOPServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final String SOP_RESPONSE = getStaticResource('mock_sop');
  private static final String UPDATE_SOP_AND_PARTY = getStaticResource(
    'mock_updateSOPAndParty'
  );

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for sop api
   */
  public override HttpCalloutResponse getSOP(String ocvId, String sopId) {
    if (!preset) {
      response.body = SOPServiceMock.SOP_RESPONSE;
    }
    return response;
  }

  /**
   * @description update SOP and Party
   * @param ocvId ocv id of the customer account
   * @param updateSOPAndPartyRequest post data of party information
   * @param urlParameters parameters to retrieve customer information
   * @return `HttpCalloutResponse` the api response
   */
  public override HttpCalloutResponse updateSOPAndParty(
    String ocvId,
    SOPUpdateSOPAndPartyRequestModel updateSOPAndPartyRequest,
    List<String> urlParameters
  ) {
    if (!preset) {
      response.body = SOPServiceMock.UPDATE_SOP_AND_PARTY;
    }
    return response;
  }
}
