/**
 * @author Aman Gupta
 * @since February 2025
 * @description Construct header & payload for COP request
 * @group Services
 * @runTests ConfirmationOfPayeeServiceTest
 */
public with sharing class ConfirmationOfPayeeServiceMock extends ConfirmationOfPayeeService {
  @TestVisible
  private static final string GET_ACCOUNT_COP_DETAILS = getStaticResource(
    'mock_getAccountCoPdetails'
  );

  @TestVisible
  private static final string UPDATE_ACCOUNT_COP_DETAILS = getStaticResource(
    'mock_updateAccountCoPdetails'
  );

  /**
   * @param request request for COP Details
   * @param ocvId required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description Mock HttpCalloutResponse from Callout for COP Details
   */
  public virtual override HttpCalloutResponse getAccountCoPdetails(
    String request,
    String ocvId
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = ConfirmationOfPayeeServiceMock.GET_ACCOUNT_COP_DETAILS;
    return super.response;
  }

  /**
   * @param request request for update COP Details
   * @param ocvId required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description Mock HttpCalloutResponse from Callout for COP Details
   */
  public override HttpCalloutResponse updateAccountCoPdetails(
    String request,
    String ocvId
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = ConfirmationOfPayeeServiceMock.UPDATE_ACCOUNT_COP_DETAILS;
    return super.response;
  }
}
