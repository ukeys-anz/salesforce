/**
 * @author cruzb
 * @since May 2023
 * @description Credit Referral API repository for all Gearbox callouts
 * @group Repository
 */
public with sharing class CreditAssessmentAPIRepository extends RepositoryBase {
  /**
   * @param creditId request arg for gearbox callout
   * @return `CreditReferralModel`
   * @description method to get list assessments from Gearbox
   */
  public CreditReferralModel getCreditAssessments(String creditId) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.getCreditAssessments(creditId);
    if (response.successful == false) {
      throw response.error;
    }
    CreditReferralModel credRef;
    try {
      credRef = CreditReferralModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, CreditAssessmentAPIRepository.class);
    }
    return credRef;
  }

  /**
   * @param creditId credit id from credit assessment
   * @description submtis the credit assessment for reassessment
   */
  public void submitReassessment(String creditId) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.creditReassessment(creditId);
    if (response.successful == false) {
      throw response.error;
    }
  }

  /**
   * @param creditId credit id from credit assessment
   * @param assessmentId id of assessment submitted for finalisation
   * @description submtis the credit assessment for finalisation
   */
  public void finaliseAssessment(String creditId, String assessmentId) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.finaliseAssessment(creditId, assessmentId);
    if (response.successful == false) {
      throw response.error;
    }
  }
}
