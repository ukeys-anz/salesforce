/**
 * @description Aura-enabled controller for retrieving OCDD KYC review status.
 * @author  Supriya Kempanna
 * @created 2024-06-20
 */
public with sharing class OCDDController {
  private static final OCDDApiRepository REPO = (OCDDApiRepository) Lib_InstanceProvider.forType(
    OCDDApiRepository.class
  );
  private static final String MSG_ERROR_GENERIC = 'OCDD information is not available at the moment';

  /**
   * @description Retrieves the KYC review status for the specified OCV ID.
   * @param ocvId The unique identifier of the OCV.
   * @return The description of the KYC review status, or an error message if retrieval fails.
   */
  @AuraEnabled
  public static String getOCDDKycReviewStatus(String ocvId) {
    try {
      OCDDResponseModel ocddResponse = REPO.getOCDDKycReviewStatus(ocvId);
      return ocddResponse.kycReviewStatus.description;
    } catch (Exception ex) {
      throw new AuraHandledException(MSG_ERROR_GENERIC);
    }
  }
}
