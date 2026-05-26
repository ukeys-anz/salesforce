/**
 * @description Mock implementation of OCDDService for unit tests.
 *  @author  Supriya Kempanna
 * @created 2024-06-20
 */
public with sharing class OCDDServiceMock extends OCDDService {
  /**
   * @description Initializes the mock response as a successful callout.
   */
  public OCDDServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String OCDD_KYC_STATUS = getStaticResource(
    'mock_OcddStatus'
  );

  /**
   * @description Mock implementation of retrieving the KYC review status for the specified OCV ID.
   * @param ocvId The unique identifier of the OCV.
   * @return An HttpCalloutResponse object containing the mock KYC review status.
   */
  public override HttpCalloutResponse getOCDDKycReviewStatus(String ocvId) {
    if (!preset) {
      response.body = OCDD_KYC_STATUS;
    }
    return response;
  }
}
