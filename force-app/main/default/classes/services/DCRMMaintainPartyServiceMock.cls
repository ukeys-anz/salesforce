/**
 * @author Ankit Garg
 * @since June 2023
 * @description extended service class for mocking MLCRM OCV Maintain party API
 * @group Service
 */
public with sharing class DCRMMaintainPartyServiceMock extends Service {
    /**
     * @description constructor which sets default status code and successful
     */
    public DCRMMaintainPartyServiceMock() {
        response.statusCode = 200;
        response.successful = true;
    }

    /**
     * @param record Lead record from lwc component
     * @return HttpCalloutResponse
     * @description fetches party information for lead conversion
     */
    public override HttpCalloutResponse maintainParty(Lead record) {
        if (!preset) {
            StaticResource sr = [
                SELECT Body
                FROM StaticResource
                WHERE Name = 'mock_dcrmMaintainPartyModel'
                WITH SECURITY_ENFORCED
            ];
            response.body = sr.Body.toString();
        }
        return response;
    }
}