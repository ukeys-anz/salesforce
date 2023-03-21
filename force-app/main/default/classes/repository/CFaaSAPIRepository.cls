/**
 * @author Emma Bindi
 * @since November 2022
 * @description CFaaS API repository for all CFaaS callouts
 * @group Repository
 */
public with sharing class CFaaSAPIRepository extends RepositoryBase {
  /**
   * @param ocvId customer id
   * @param docId document id reference in external system
   * @return CFaaSDocumentModel.CFaaSDownloadUrl containing signed URL to call for document content
   * @description cfaas get download url api endpoint
   */
  public CFaaSDocumentModel.CFaaSDownloadUrl getDownloadURL(
    String ocvId,
    String docId
  ) {
    CFaaSDocumentModel.CFaaSDownloadUrl result;

    Service s = ServiceProvider.getService(CFaaSService.class);
    HttpCalloutResponse response = s.getDownloadUrl(ocvId, docId);

    try {
      if (response.successful == false) {
        throw response.error;
      }
      result = CFaaSDocumentModel.CFaaSDownloadUrl.parseDownloadUrlResponse(
        response.body
      );
    } catch (Exception e) {
      handleErrors(response, e, CFaaSAPIRepository.class);
    }
    return result;
  }

  /**
   * @param url google bucket url pointing to document store
   * @param otp one time pin to be set in header in order to access above url
   * @param contentType represents document content type which is set in header
   * @return Blob containing the document content
   * @description calls google bucket signed url where document is stored
   */
  public Blob fetchDocumentContent(String url, String otp, String contentType) {
    Blob result;

    Service s = ServiceProvider.getService(CFaaSService.class);
    HttpCalloutResponse response = s.fetchDocumentContent(
      url,
      otp,
      contentType
    );

    try {
      if (response.successful == false) {
        throw response.error;
      }
      result = response.bodyAsBlob;
    } catch (Exception e) {
      handleErrors(response, e, CFaaSAPIRepository.class);
    }

    return result;
  }
}
