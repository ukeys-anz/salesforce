/**
 * @author Anuja Vats
 * @since April 2024
 * @description extended service class for mocking CMOS SNOW integration callout
 * @group Service
 */
public with sharing class SNOWIntegrationServiceMock extends SNOWIntegrationService {
/**
   * @description constructor which sets default status code and successful
   */
  public SNOWIntegrationServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
    @TestVisible
  private static final String RISK_INFO_SUCCESS_RESPONSE = '{ "result": [ { "number": "IRE0073261", "event_type": "1"} ] }';
  private static final String RISK_INFO_BLANK_RESPONSE = '{ "result": [] }';
  private static final String VALID_RISK_EVENT_ID = 'IRE0073261';

  /**
   * @param riskEventId riskEventId to be searched
   * @return HttpCalloutResponse the api response
   * @description fetches serviceNow info fake response
   */
  public override HttpCalloutResponse getSNOWRiskEventInformation(
    String riskEventId
  ) {
    if (!preset) {
        if(riskEventId == VALID_RISK_EVENT_ID){
            response.body = SNOWIntegrationServiceMock.RISK_INFO_SUCCESS_RESPONSE;
        }
        else{
            response.body = SNOWIntegrationServiceMock.RISK_INFO_BLANK_RESPONSE;
        }    
    }
    return response;
  }
}