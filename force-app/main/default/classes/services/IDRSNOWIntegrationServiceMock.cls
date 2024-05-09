/**
 * @author Anuja Vats
 * @since April 2024
 * @description extended service class for mocking CMOS SNOW integration callout
 * @group Service
 */
public with sharing class IDRSNOWIntegrationServiceMock extends IDRSNOWIntegrationService {
/**
   * @description constructor which sets default status code and successful
   */
  public IDRSNOWIntegrationServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
    @TestVisible
  private static final String RISK_INFO_SUCCESS_RESPONSE = '{ "result": [ { "number": "IRE0073261", "event_type": "1"} ] }';

  /**
   * @param riskEventId riskEventId to be searched
   * @return HttpCalloutResponse the api response
   * @description fetches serviceNow info fake response
   */
  public override HttpCalloutResponse getSNOWInformation(
    String riskEventId
  ) {
    if (!preset) {
      response.body = IDRSNOWIntegrationServiceMock.RISK_INFO_SUCCESS_RESPONSE;
    }
    return response;
  }
}