/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Service class for Pega related operations
 **/
public with sharing virtual class PegaCaseService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  @TestVisible
  private static final String PEGA_CASE_CREATE_API_SCOPE = 'CCRM_Pega_Case_Create';

  /**
   * @description Creates case to Pega.
   * @param payload The PegaCaseRequestModel containing the request data.
   * @return HttpCalloutResponse The response from the HTTP callout.
   */
  public virtual HttpCalloutResponse createCase(PegaCaseRequestModel payload) {
    HttpCalloutResponse response = CALLOUT.makeRestCallout(
      Label.PEGA_Create_Case_Endpoint,
      HTTP_METHOD.HTTP_POST,
      getHeaders(PEGA_CASE_CREATE_API_SCOPE),
      JSON.serialize(payload, true)
    );
    return response;
  }

  private Map<String, String> getHeaders(String apiScope) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.apiScopesRequested = apiScope;
    staffModel.realm = 'system';
    staffModel.isSecureWafFlow = true;

    Map<String, String> headers = super.setCalloutCommonHeaders(staffModel);
    headers.put('x-span-id', UniqueIdUtil.generateSpanId());
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Content-Type', 'application/json');
    headers.put('version', 'v1.0');
    return headers;
  }
}
