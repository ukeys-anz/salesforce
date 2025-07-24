/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description Mock implementation of AEM api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class AemServiceMock extends AemService {
  @TestVisible
  private static final String AEM_CONTENT_DATA_SUCCESS = getStaticResource(
    'mock_aemContentData'
  );

  /**
   * @param aemContentId Template id
   * @return `HttpCalloutResponse` method response
   * @description Mock APi call for returning success response from AEM
   */
  public virtual override HttpCalloutResponse getAemContentData(
    String aemContentId
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = AEM_CONTENT_DATA_SUCCESS;
    return super.response;
  }
}
