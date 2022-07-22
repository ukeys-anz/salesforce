/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description extended service class for mocking CCRM ABN ACN Callout
 * @group Service
 */
public with sharing class CCRMValidateAbnAcnServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public CCRMValidateAbnAcnServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @param calloutUrl ABN or ACN callout url
   * @param abnOrAcn number to be validated
   * @return HttpCalloutResponse
   * @description fetches ABN or ACN information
   */
  public override HttpCalloutResponse getAbnAcnInformation(
    String calloutUrl,
    String abnOrAcn
  ) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmAbnAcnModel'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }
}
