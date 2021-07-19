/**
 * @author Pavan Kuamr Ananta
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description  GetCustomerInformation is a class that handles all the information of the customer related to a case in IDR.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class GetCustomerInformation {
  /**
   * @description Currently the Case record page has a lwc which needs to fetch the customer information on demand on a case record page based on CAP SIS ID.
   * This api call is made to mulesoft to fetch the required customer information.
   * The following is the call sequence Salesforce -> Mulessoft -> B2B -> APIc -> CAP
   * The cache is turned off as we need to get the latest data from cap everytime.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to cap to have the logs recorded for monitoring.
   *
   * @param customerId Customer Identidfier Id
   * @param customerIdentifier Customer Identidfier Type
   * @return `map<String, Object>`
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=false)
  public static map<String, Object> getCustomerData(
    String customerId,
    String customerIdentifier
  ) {
    map<String, Object> customerData = new Map<String, Object>();
    String responseBody = null;
    if (String.isNotBlank(customerId)) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:Mulesoft' + Label.MS_Get_Customer);
      request.setMethod('POST');
      request.setHeader('consumer_id', 'salesforce');
      request.setHeader('Content-type', 'application/json');
      request.setBody(getBody(customerId, customerIdentifier));
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
        Boolean logResult = Lib_SystemLog.logAPIError(
          GetCustomerInformation.class.getName(),
          'getCustomerData',
          e.getMessage(),
          e.getTypeName(),
          null,
          response != null ? response.getBody() : null,
          request.getEndpoint(),
          HTTP_METHOD.HTTP_GET.name(),
          response != null ? response.getStatusCode() : 400
        );
        //throw new AuraHandledException(e.getMessage());
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
      return customerData;
    } else {
      return customerData;
    }
  }

  /**
   * @description prepares the body for the callout
   * @param customerId Customer Identifier Id
   * @param customerIdentifier Customer Identifier Type
   * @return `map<String, Object>`
   * @exception CalloutException
   */
  public static String getBody(String customerId, String customerIdentifier) {
    CustomerIdentifiers cusIden = new CustomerIdentifiers();
    IdentifierDetails cls = new IdentifierDetails();
    cls.identifierUsageType = ((String.isNotBlank(customerIdentifier) &&
      customerIdentifier.contains('CAP ID'))
      ? 'CAP ID'
      : customerIdentifier);
    cls.identifier = customerId;
    cusIden.identifiers.add(cls);

    return Json.serialize(cusIden);
  }

  /**
   * @description  Wrapper class to build the body
   *
   */
  public class CustomerIdentifiers {
    public List<IdentifierDetails> identifiers = new List<IdentifierDetails>();
  }

  /**
   * @description  Wrapper class to build the body
   *
   */
  public class IdentifierDetails {
    public String identifierUsageType = '';
    public String identifier = '';
  }
}
