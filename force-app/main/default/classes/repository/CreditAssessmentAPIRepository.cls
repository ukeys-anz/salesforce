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
   * @param payload payload containing values to send
   * @description updates referral outcome
   * @return `CreditReferralModel`
   */
  public CreditReferralModel createCreditEnquiryAssessment(
    Map<String, String> payload
  ) {
    Service s = ServiceProvider.getService(BOHService.class);

    EnquiryBody enquiry = new EnquiryBody();
    EnquiryAssessmentReferralOutcome enquiryAssessment = new EnquiryAssessmentReferralOutcome();
    enquiry.creditEnquiryId = payload.get('creditId');
    enquiryAssessment.creditEnquiryAssessmentId = payload.get('assessmentId');
    enquiryAssessment.reasonCode = payload.get('reasonCode');
    enquiryAssessment.referralOutcomeCode = payload.get('referralOutcome');
    enquiryAssessment.applicantId = payload.get('applicantId');
    enquiry.creditEnquiryAssessmentReferralOutcome = enquiryAssessment;

    //Serialise payload so any null values are removed
    String requestPayload = json.serialize(enquiry, true);

    UUIDLog uuidLog = new UUIDLog(requestPayload);
    HttpCalloutResponse response = s.createCreditEnquiryAssessment(
      uuidLog.attachUUID(requestPayload),
      payload.get('ocvId')
    );
    if (response.successful == false) {
      uuidLog.insertUUID(
        payload.get('recordId'),
        'BOH - Credit Referral - Referral Outcome'
      );
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
   * @description EnquiryBody returns body of enquiry
   */
  public class EnquiryBody {
    public String creditEnquiryId;
    public EnquiryAssessmentReferralOutcome creditEnquiryAssessmentReferralOutcome;
  }

  /**
   * @description EnquiryAssessmentReferralOutcome returns body of enquiry referral outcome
   */
  public class EnquiryAssessmentReferralOutcome {
    public String creditEnquiryAssessmentId;
    public String reasonCode;
    public String referralOutcomeCode;
    public String applicantId;
  }
}
