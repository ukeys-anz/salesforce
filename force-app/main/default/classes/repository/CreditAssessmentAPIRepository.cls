/**
 * @author cruzb
 * @since May 2023
 * @description Credit Referral API repository for all Gearbox callouts
 * @group Repository
 */
public with sharing class CreditAssessmentAPIRepository extends RepositoryBase {
  /**
   * @param creditId request arg for gearbox callout
   * @param ocvId customer ocv id
   * @return `CreditReferralModel`
   * @description method to get list assessments from Gearbox
   */
  public CreditReferralModel getCreditAssessments(
    String creditId,
    String ocvId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.getCreditAssessments(creditId, ocvId);
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
   * @param recordId record id from case
   * @param collateralAssessmentId property valuation id from case
   * @param ocvId customer ocv id
   * @description submits the credit assessment for reassessment
   */
  public void submitReassessment(
    String creditId,
    String recordId,
    String collateralAssessmentId,
    String ocvId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    String payload = '{"creditEnquiryId": "' + creditId + '",';
    payload +=
      '"creditEnquiryAssessment": {"collateralAssessmentId": "' +
      collateralAssessmentId +
      '",';
    payload += '"type": "ASSESSMENT_TYPE_PROVISIONAL"}}';
    UUIDLog uuidLog = new UUIDLog(payload);
    HttpCalloutResponse response = s.creditReassessment(
      uuidLog.attachUUID(payload),
      ocvId
    );
    if (response.successful == false) {
      uuidLog.insertUUID(recordId, 'BOH - Credit Referral - Reassess');
      throw response.error;
    }
  }

  /**
   * @param creditId credit id from credit assessment
   * @param assessmentId id of assessment submitted for finalisation
   * * @param ocvId customer ocv id
   * @description submits the credit assessment for finalisation
   */
  public void finaliseAssessment(
    String creditId,
    String assessmentId,
    String ocvId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.finaliseAssessment(
      creditId,
      assessmentId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }
  }

  /**
   * @param creditId credit id from credit assessment
   * @param referralOutcome referral outcome code
   * @param recordId record id from case
   * @param ocvId customer ocv id
   * @param assessmentId assessment id of case
   * @param reasonCode reason code linked to referral outcome
   * @description updates referral outcome
   * @return `CreditReferralModel`
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public CreditReferralModel createCreditEnquiryAssessment(
    String creditId,
    String referralOutcome,
    String recordId,
    String ocvId,
    String assessmentId,
    String reasonCode
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    String payload =
      '{"creditEnquiryId": "' +
      creditId +
      '", "creditEnquiryAssessmentReferral_outcome": {' +
      '"creditEnquiryAssessmentId": "' +
      assessmentId +
      '","reasonCode":"' +
      reasonCode +
      '","referralOutcomeCode":"' +
      referralOutcome +
      '"}}';
    UUIDLog uuidLog = new UUIDLog(payload);
    HttpCalloutResponse response = s.createCreditEnquiryAssessment(
      uuidLog.attachUUID(payload),
      ocvId
    );
    if (response.successful == false) {
      uuidLog.insertUUID(recordId, 'BOH - Credit Referral - Referral Outcome');
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
}
