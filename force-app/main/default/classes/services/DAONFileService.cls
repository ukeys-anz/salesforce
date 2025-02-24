/**
 * @author Tan Phan
 * @since 01/2025
 * @description Service class for DAONFile related operations
 */
public with sharing virtual class DAONFileService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @description Downloads files based on the provided request and customer information.
   * @param request The DAONFileRequestModel containing the request data.
   * @param customerId The ID of the customer.
   * @param customerIdType The type of the customer ID.
   * @return HttpCalloutResponse The response from the HTTP callout.
   */
  public virtual HttpCalloutResponse downloadFiles(
    DAONFileRequestModel request,
    String customerId,
    String customerIdType
  ) {
    HttpCalloutResponse response = CALLOUT.makeRestCallout(
      Label.MS_OnboardingUpload_API,
      HTTP_METHOD.HTTP_POST,
      this.getHeaders(customerId, customerIdType),
      request.serialize()
    );
    return response;
  }

  @TestVisible
  private Map<String, String> getHeaders(
    String customerId,
    String customerIdType
  ) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.valueOf(customerIdType);
    staffModel.idValue = customerId;
    staffModel.anzTokenType = 'staffRqfCustomer';

    Map<String, String> headers = super.setCalloutCommonHeaders(staffModel);
    headers.put('x-correlation-id', UUID.randomUUID().toString());
    headers.put('x-anz-application-id', 'salesforce');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    headers.put('Content-Type', 'application/json');
    return headers;
  }
}
