/**
 * @description Service layer for OCDD callouts.
 * @author  Supriya Kempanna
 * @created 2024-06-20
 */
public with sharing virtual class OCDDService extends service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  /**
   * @description Makes a REST callout to retrieve the KYC review status for the specified OCV ID.
   * @param ocvId The unique identifier of the OCV.
   * @return An HttpCalloutResponse object containing the response from the OCDD API.
   */
  public virtual HttpCalloutResponse getOCDDKycReviewStatus(String ocvId) {
    return CALLOUT.makeRestCallout(
      Label.Ocdd_KYC_Status_Endpoint,
      HTTP_METHOD.HTTP_POST,
      this.getHeaders(ocvId),
      JSON.serialize(new Map<String, Object>())
    );
  }
  /**
   * @description Constructs the headers for the OCDD API callout, including authentication and correlation ID.
   * @param ocvId The unique identifier of the OCV.
   * @return A map of headers for the OCDD API callout.
   */
  @TestVisible
  private Map<String, String> getHeaders(String ocvId) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.apiScopesRequested = 'GENESIS';
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.realm = 'customer';
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = ocvId;
    staffModel.isSecureWafFlow = true;
    Map<String, String> headers = super.setCalloutCommonHeaders(staffModel);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('traceparent', CommonUtil.generateTraceParent());
    headers.put('Content-Type', 'application/json');
    return headers;
  }
}
