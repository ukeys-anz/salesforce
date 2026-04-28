/**
 * @description Repository for OCDD API responses and parsing.
 * @author  Supriya Kempanna
 * @created 2024-06-20
 */
public with sharing class OCDDApiRepository extends RepositoryBase {
  private static final OCDDService SERVICE = (OCDDService) Lib_InstanceProvider.forType(
    OCDDService.class
  );
  /**
   * @description Retrieves the KYC review status for the specified OCV ID.
   * @param ocvId The unique identifier of the OCV.
   * @return An OCDDResponseModel object containing the KYC review status.
   */
  public OCDDResponseModel getOCDDKycReviewStatus(String ocvId) {
    HttpCalloutResponse response = new ResponseHandler('OCDDService')
      .process(SERVICE.getOCDDKycReviewStatus(ocvId));
    return OCDDResponseModel.parse(response.body);
  }
}
