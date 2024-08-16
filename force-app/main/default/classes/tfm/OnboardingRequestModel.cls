/**
 * @author Anuj Jain
 * @since May 2024
 * @description Model class to create request Onboarding API
 * @group TFM
 */
@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions')
public with sharing class OnboardingRequestModel extends CalloutModel {
  /**
   * @description requester_sf_id
   */
  public String requester_sf_id { get; set; }
  public DAONFile daon_file;
  /**
   * @description This is wrapper class for DAONFile Request
   * @name DAONFile
   * @author Shivraj Kadam
   */
  public class DAONFile {
    public String content_version_id;
    public String salesforce_id;
    public String file_type;
    public String idx_user_id;
    public String idx_id_check_id;
    public String idx_document_id;
    public String idx_extracted_face_id;
    public String workflowId;
    public SelfieRecoveryChallenge selfie_recovery;
    public PinRecoveryChallenge pin_recovery;
  }

  /**
   * @description This is wrapper class for PinRecoveryChallenge Request
   * @name PinRecoveryChallenge
   * @author Hinduja Upadhyay
   */
  public class PinRecoveryChallenge {
    public String idx_challenge_id;
  }

  /**
   * @description This is wrapper class for PinRecoveryChallenge Request
   * @name PinRecoveryChallenge
   * @author Hinduja Upadhyay
   */
  public class SelfieRecoveryChallenge {
    public String idx_challenge_id;
    public String idx_challenge_type;
  }
  /**
   * @description Represents Response body for onboarding API
   * @param json json response from onboarding API
   * @return `Onboarding` api response is serialised into OnboardingModel
   */
  public static OnboardingRequestModel parse(String json) {
    return (OnboardingRequestModel) deserialize(
      json,
      OnboardingRequestModel.class
    );
  }
}