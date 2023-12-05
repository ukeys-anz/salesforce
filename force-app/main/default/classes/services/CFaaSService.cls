/**
 * @author Emma Bindi
 * @since November 2022
 * @description CFaaS implementation of the API service
 * @group Services
 */
public with sharing class CFaaSService extends Service {
  /**
   * @param ocvId customer id
   * @param docId document id reference in external system
   * @param recordId record id for the cfaas file object
   * @param cvId content version Id if applicable
   * @return HttpCalloutResponse
   * @description cfaas get download url api
   */
  public override HttpCalloutResponse getDownloadUrl(
    String ocvId,
    String docId,
    String recordId,
    String cvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');

    Map<String, Object> callBody = new Map<String, Object>{
      'documentId' => docId,
      'urlType' => 1,
      'recordId' => recordId,
      'cvId' => cvId,
      'requester_sf_id' => UserInfo.getUserId()
    };

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_CFaaS_Download_Url,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(callBody)
    );

    return response;
  }

  /**
   * @param url google bucket url pointing to document store
   * @param otp one time pin to be set in header in order to access above url
   * @param contentType represents document content type which is set in header
   * @return HttpCalloutResponse
   * @description calls google bucket signed url where document is stored
   */
  public override HttpCalloutResponse fetchDocumentContent(
    String url,
    String otp,
    String contentType
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers.put('x-goog-meta-otp', otp);
    headers.put('Content-Type', contentType);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      url,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
}
