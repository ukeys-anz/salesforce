/**
 * @author Mildeep Pahwa
 * @since Feb 2025
 * @description Service Mock class for MaintainPartyServiceMock
 */

public with sharing class MaintainPartyServiceMock extends MaintainPartyService {
  /**
   * @param record Lead record in OCVRequestPayloadWrapper format
   * @description fetches party information for lead conversion
   * @return HttpCalloutResponse
   */
  public virtual override HttpCalloutResponse maintainPartyOrganisation(
    OCVRequestPayloadWrapper record
  ) {
    super.response.body = '{"sourceSystems": [{"sourceSystemId": "1212201901","sourceSystemName": "CAP-CIS"}],"ocvId": 8019989879,"profileIds": ["string"],"newCustomer": "true"}';
    super.response.statusCode = 200;
    super.response.successful = true;
    return response;
  }

  /**
   * @param record Lead record from lwc component
   * @return HttpCalloutResponse
   * @description fetches party information for lead conversion
   */
  public virtual override HttpCalloutResponse maintainPartyForIndividual(
    OCVRequestPayloadWrapper record
  ) {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_dcrmMaintainPartyModel'
      WITH USER_MODE
    ];
    super.response.body = sr.Body.toString();
    super.response.statusCode = 200;
    super.response.successful = true;
    return response;
  }
}
