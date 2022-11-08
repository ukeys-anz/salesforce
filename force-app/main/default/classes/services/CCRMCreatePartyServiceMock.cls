/**
 * @author Boobalakrishnan Duraisamy
 * @since Aug 2022
 * @description extended service class for mocking CCRM CAP create party API
 * @group Service
 */
public with sharing class CCRMCreatePartyServiceMock extends Service {
    /**
     * @description constructor which sets default status code and successful
     */
    public CCRMCreatePartyServiceMock() {
      response.statusCode = 200;
      response.successful = true;
    }
  
    /**
     * @param record Lead record from lwc component
     * @return HttpCalloutResponse
     * @description fetches party information for lead conversion
     */
    public override HttpCalloutResponse createParty(Lead record) {
      if (!preset) {
        StaticResource sr = [
          SELECT Body
          FROM StaticResource
          WHERE Name = 'mock_ccrmCreatePartyModel'
          WITH SECURITY_ENFORCED
        ];
        response.body = sr.Body.toString();
      }
      return response;
    }
  }
  