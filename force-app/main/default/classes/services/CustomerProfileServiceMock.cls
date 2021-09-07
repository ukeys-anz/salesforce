/**
 * @author Adnan
 * @since Sep 2021
 * @description extended service class for mocking CMOS customer search callout
 * @group Service
 */
public with sharing class CustomerProfileServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public CustomerProfileServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String CUSTOMER_INFO_SUCCESS_RESPONSE = '{"profile": {"firstname": "TestFirstName","lastname": "TestLastName","mobile": "TestMobile"}}';

  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return HttpCalloutResponse the api response
   * @description fetches customer info fake response
   */
  public override HttpCalloutResponse getCustomerInformation(
    String customerId,
    String customerIdentifier
  ) {
    if (!preset) {
      response.body = CustomerProfileServiceMock.CUSTOMER_INFO_SUCCESS_RESPONSE;
    }
    return response;
  }
}
