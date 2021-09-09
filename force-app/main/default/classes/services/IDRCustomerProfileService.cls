/**
 * @author Adnan
 * @since Sep 2021
 * @description extended service class for CMOS customer search callout
 * @group Service
 */
public with sharing class IDRCustomerProfileService extends Service {
  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public override HttpCalloutResponse getCustomerInformation(
    String customerId,
    String customerIdentifier
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('consumer_id', 'salesforce');
    headers.put('Content-type', 'application/json');
    String body = getBody(customerId, customerIdentifier);
    return calloutService.makeRestCallout(
      'callout:Mulesoft' + Label.MS_Get_Customer,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return String
   * @description creates the request body for callout
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
