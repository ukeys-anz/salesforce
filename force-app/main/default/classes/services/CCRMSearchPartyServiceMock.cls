/**
 * @author Boobalakrishnan Duraisamy
 * @since May 2022
 * @description extended service class for mocking CCRM OCV search party API
 * @group Service
 */
public with sharing class CCRMSearchPartyServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public CCRMSearchPartyServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @param record Lead record from lwc component
   * @return HttpCalloutResponse
   * @description fetches party information for lead conversion
   */
  public override HttpCalloutResponse searchPartyInfo(Lead record) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmSearchPartyModel'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }
}
