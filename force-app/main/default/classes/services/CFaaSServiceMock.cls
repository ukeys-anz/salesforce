/**
 * @author Emma Bindi
 * @since November 2022
 * @description Mock implementation of CFaaS api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class CFaaSServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public CFaaSServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String CFAAS_DOWNLOAD_URL_RESPONSE = getStaticResource(
    'mock_cfaasDownloadUrl'
  );

  @TestVisible
  private static final Blob CFAAS_DOCUMENT_RESPONSE = getStaticResourceAsBlob(
    'mock_cfaasImageDoc'
  );

  /**
   * @param ocvId customer id
   * @param docId document id reference in external system
   * @return `HttpCalloutResponse` api response
   * @description virtual gets CFaas download url
   */
  public override HttpCalloutResponse getDownloadUrl(
    String ocvId,
    String docId
  ) {
    if (!preset) {
      response.body = CFAAS_DOWNLOAD_URL_RESPONSE;
    }
    return response;
  }

  /**
   * @param url google bucket url pointing to document store
   * @param otp one time pin to be set in header in order to access above url
   * @param contentType represents document content type which is set in header
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches CFaaS document content
   */
  public override HttpCalloutResponse fetchDocumentContent(
    String url,
    String otp,
    String contentType
  ) {
    if (!preset) {
      response.bodyAsBlob = CFAAS_DOCUMENT_RESPONSE;
    }

    return response;
  }
}
