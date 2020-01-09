/**
 * @author Pavan Kuamr Ananta
 * @since 2020 
 * @group IDR(Internal Dispute Resolution)
 * @description  GetCustomerInformation is a class that handles all the information of the customer related to a case in IDR.
 */
public with sharing class GetCustomerInformation {
	//TODO remove this once actual service is up
	private final static String MOCK_RESPONSE ='{"profile": {"complainant_type": "Small Business","businessname":"Smith Co.","firstname": "John","lastname": "Smith","mobile": "0411 222 333","phone":"0411 222 333","middlename":"","gender":"Male","aboriginal":"No","email":"john.smith@abc123.com.au","age":"55","suburb":"Hoppers Crossing","street":"1 West Street","state":"VIC","postcode":"3029","country":"Australia"}}';

/**
 * @description Currently the Case record page has a lwc which needs to fetch the customer information on demand on a case record page based on CAP SIS ID
 * This api call is made to mulesoft to fetch the required customer information.
 * The following is the call sequence Salesforce -> Mulessoft -> B2B -> APIc -> CAP
 * The cache is turned off as we need to get the latest data from cap everytime.
 * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to cap to have the logs recorded for monitoring.
 * 
 * @param capId 
 * @return `map<String, Object>`
 * @exception CalloutException
 */
@AuraEnabled(cacheable=false)
public static map<String, Object> getCustomerData(String capId) {
	map<String, Object> customerData = new map<String, Object>();
	String responseBody = null;
	if(String.isNotBlank(capId)) {
		HttpRequest request = new HttpRequest();
		//TODO change this to real endpoint
		request.setEndpoint('callout:My_Named_Credential/some_path');
		request.setMethod('GET');
		HTTPResponse response = null;
		try {
			Http http = new Http();
			//TODO remove the IsRunningTest line once we have a real endpoint and remove mocking
			if (Test.IsRunningTest()) {
			response = http.send(request);
			} else {
			response = new HttpResponse();
			response.setStatusCode(200);
			response.setBody(MOCK_RESPONSE);
			}
			if (response.getStatusCode() == 200 ) {
				responseBody = response.getBody();
			}
			else {
				throw new CalloutException(response.getBody());
			}
            if(!String.isBlank(responseBody)) {
            customerData = (map<String, Object>)JSON.deserializeUntyped(responseBody);
        }

        if(!customerData.isEmpty()) {
            return customerData;
        }
		}
		catch(Exception e) {
			Lib_SystemLog.logAPIError(GetCustomerInformation.class.getName(),'getCustomerData', e.getMessage(), e.getTypeName(), GetCustomerInformation.class.getName(), null, response != null ? response.getBody() : null);
		}

		return null;

	} else {
		return null;
	}
}
}
