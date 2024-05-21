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
   * @param payload payload to send for reassessment
   * @description submits the credit assessment for reassessment
   */
  public void submitReassessment(Map<String, String> payload) {
    Service s = ServiceProvider.getService(BOHService.class);
    ReassessBody reassessBody = new ReassessBody();
    CreditEnquiryAssessment creditEnqAssessment = new CreditEnquiryAssessment();
    creditEnqAssessment.collateralAssessmentId = payload.get(
      'collateralAssessmentId'
    );

    if (String.isNotEmpty(payload.get('titleReferenceNumber'))) {
      List<TitleReference> titleRef = (List<TitleReference>) JSON.deserialize(
        payload.get('titleReferenceNumber'),
        List<TitleReference>.class
      );
      creditEnqAssessment.titleReferenceNumbers = titleRef;
    }
    reassessBody.creditEnquiryAssessment = creditEnqAssessment;
    reassessBody.creditEnquiryId = payload.get('creditId');
    reassessBody.type = 'ASSESSMENT_TYPE_PROVISIONAL';

    //Serialise payload so any null values are removed
    String requestPayload = json.serialize(reassessBody, true);

    UUIDLog uuidLog = new UUIDLog(requestPayload);
    HttpCalloutResponse response = s.creditReassessment(
      uuidLog.attachUUID(requestPayload),
      payload.get('ocvId')
    );
    if (response.successful == false) {
      uuidLog.insertUUID(
        payload.get('recordId'),
        'BOH - Credit Referral - Reassess'
      );
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
   * @param assessmentId id of assessment submitted for finalisation
   * @param ocvId customer ocv id
   * @param outcomeCode outcome code to delete
   * @description submits the deletes the credit assessment referral outcome to be updated
   * @return `Boolean` return boolean as the actual response isnt needed for the component
   */
  public Boolean deleteReferralOutcome(
    String creditId,
    String assessmentId,
    String ocvId,
    String outcomeCode
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.deleteReferralOutcome(
      creditId,
      assessmentId,
      ocvId,
      outcomeCode
    );
    if (response.successful == false) {
      throw response.error;
    }

    return true;
  }

  /**
   * @param payload payload containing values to send
   * @description updates referral outcome
   * @return `Boolean` return boolean as the actual response isnt needed for the component
   */
  public Boolean createCreditEnquiryAssessment(Map<String, String> payload) {
    Service s = ServiceProvider.getService(BOHService.class);

    EnquiryBody enquiry = new EnquiryBody();
    EnquiryAssessmentReferralOutcome enquiryAssessment = new EnquiryAssessmentReferralOutcome();
    enquiry.creditEnquiryId = payload.get('creditId');
    enquiryAssessment.creditEnquiryAssessmentId = payload.get('assessmentId');
    enquiryAssessment.reasonCode = payload.get('reasonCode');
    enquiryAssessment.referralOutcomeCode = payload.get('referralOutcome');
    enquiryAssessment.applicantId = payload.get('applicantId');
    enquiryAssessment.propertyId = payload.get('propertyId');
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

    return true;
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
    public String propertyId;
  }

  /**
   * @description ReassessBody body of reassess callout to send
   */
  public class ReassessBody {
    public String creditEnquiryId;
    public CreditEnquiryAssessment creditEnquiryAssessment;
    public String type;
  }

  /**
   * @description CreditEnquiryAssessment body of CreditEnquiryAssessment callout to send
   */
  public class CreditEnquiryAssessment {
    public String collateralAssessmentId;
    public List<TitleReference> titleReferenceNumbers;
  }

  /**
   * @description TitleReference body of TitleReference callout to send
   */
  public class TitleReference {
    String state;
    String titleReference;
  }
}
