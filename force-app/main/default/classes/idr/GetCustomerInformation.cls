/**
 * @author Pavan Kuamr Ananta
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description  GetCustomerInformation is a class that handles all the information of the customer related to a case in IDR.
 */
public with sharing class GetCustomerInformation {
  /**
   * @description Currently the Case record page has a lwc which needs to fetch the customer information on demand on a case record page based on CAP SIS ID.
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
    map<String, Object> customerData = new Map<String, Object>();
    String responseBody = null;
    if (String.isNotBlank(capId)) {
      HttpRequest request = new HttpRequest();
      //TODO change this to real endpoint
      request.setEndpoint(
        'callout:Mulesoft' + Label.MS_Get_Customer + capId
      );
      request.setMethod('GET');
      //Todo mocked for now need to change based on mulesoft api
      request.setHeader('x-consumer-id', '12344');
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          responseBody = response.getBody();
        } else {
          throw new CalloutException(response.getBody());
        }
        if (!String.isBlank(responseBody)) {
          customerData = (map<String, Object>) JSON.deserializeUntyped(
            responseBody
          );
        }

        if (!customerData.isEmpty()) {
          return customerData;
        }
      } catch (Exception e) {
        Lib_SystemLog.logAPIError(
          GetCustomerInformation.class.getName(),
          'getCustomerData',
          e.getMessage(),
          e.getTypeName(),
          GetCustomerInformation.class.getName(),
          null,
          response != null ? response.getBody() : null
        );
      }

      return null;
    } else {
      return null;
    }
  }
}
