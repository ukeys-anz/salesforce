/**
 * @author Tan Phan
 * @since 01/2025
 * @description Model class for sending Daon File download request
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class DAONFileRequestModel extends CalloutModel {
  public List<DAONFileRequest> files = new List<DAONFileRequest>();

  /**
   * @description Serializes the list of DAONFileRequest objects.
   * @return Serialized string of DAONFileRequest objects.
   */
  public String serialize() {
    return super.serialize(this.files);
  }

  /**
   * @description This is the DAONFileRequest class.
   */
  public class DAONFileRequest {
    public String requester_sf_id = UserInfo.getUserId();
    public DAONFile daon_file;

    /**
     * @description Constructor for DAONFileRequest.
     * @param daonFile The DAONFile object to be assigned.
     */
    public DAONFileRequest(DAONFile daonFile) {
      this.daon_file = daonFile;
    }
  }

  /**
   * @description This is the DAONFile class.
   */
  public class DAONFile {
    public String content_version_id;
    public String salesforce_id;
    public DAONFileType file_type;
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
   */
  public class PinRecoveryChallenge {
    public String idx_challenge_id;
    /**
     * @description Constructor for PinRecoveryChallenge.
     * @param challengeId The challenge ID to be assigned.
     */
    public PinRecoveryChallenge(String challengeId) {
      this.idx_challenge_id = challengeId;
    }
  }

  /**
   * @description This is wrapper class for PinRecoveryChallenge Request
   * @name PinRecoveryChallenge
   */
  public class SelfieRecoveryChallenge {
    public String idx_challenge_id;
    public DAONChallengeType idx_challenge_type;
    /**
     * @description Constructor for SelfieRecoveryChallenge.
     * @param challengeId The challenge ID to be assigned.
     * @param challengeType The challenge type to be assigned.
     */
    public SelfieRecoveryChallenge(
      String challengeId,
      DAONChallengeType challengeType
    ) {
      this.idx_challenge_type = challengeType;
      this.idx_challenge_id = challengeId;
    }
  }

  public enum DAONChallengeType {
    // Selfie Recovery Registration Challenge
    SELFIE_RECOVERY_CHALLENGE_TYPE_REG_CHALLENGE,
    // Selfie recovery Authentication Challenge
    SELFIE_RECOVERY_CHALLENGE_TYPE_AUTH_REQUEST
  }
}
