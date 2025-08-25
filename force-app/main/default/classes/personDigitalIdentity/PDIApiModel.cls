/**
 * @description This class represents the API model for handling public key credentials
 *              and related metadata for person digital identity.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIApiModel {
  /**
   * @description Represents the response containing a list of access controls.
   */
  public class AccessControlResponse {
    public List<AccessControl> accessControls;
  }

  /**
   * @description Represents an access control entity with its associated metadata.
   */
  public class AccessControl extends CalloutModel {
    public String name;
    public AccessControlMatchCriteria match;
    public String policy;
    public AccessControlConditionalAdvice conditionalAdvice;
    public String createdBy;
    public Datetime createdAt;
  }

  /**
   * @description Represents the matching criteria for access control, including authentication channel,
   *              device ID, and persona ID.
   */
  public class AccessControlMatchCriteria {
    public String authChannel;
    public String deviceCorrelationId;
    public String personaId;
  }

  /**
   * @description Represents conditional advice for access control, including whether to delete
   *              the control when conditions are met and the minimum authentication assurance level.
   */
  public class AccessControlConditionalAdvice {
    public Boolean deleteWhenMet;
    public String minimumAal;
  }

  /**
   * @description Represents the response containing a list of public key credentials.
   */
  public class PublicKeyCredentialResponse {
    public List<PublicKeyCredential> publicKeyCredentials;
  }

  /**
   * @description Represents a single public key credential.
   */
  public class PublicKeyCredential extends CalloutModel {
    public String name;
    public String credentialId;
    public String personId;
    public DateTime createTime;
    public DateTime updateTime;
    public DateTime lastAuthenticationTime;
    public String type;
    public String trustLevel;
    public AuthenticatorMetadata authenticatorMetadata;
    public String state;
  }

  /**
   * @description Represents the authenticator metadata, which can contain either WebAuthn or Silent Device metadata.
   */
  public class AuthenticatorMetadata {
    public WebAuthnAuthenticatorMetadata webAuthnAuthenticatorMetadata;
    public SilentDeviceAuthenticatorMetadata silentDeviceAuthenticatorMetadata;
    public BiometricAuthenticatorMetadata biometricAuthenticatorMetadata;
  }

  /**
   * @description Represents the WebAuthn authenticator metadata.
   */
  public class WebAuthnAuthenticatorMetadata {
    public String aaguid;
    public Flags flags;
  }

  /**
   * @description Represents the Biometric authenticator metadata.
   */
  public class BiometricAuthenticatorMetadata {
    public String appCorrelationId;
    public String deviceCorrelationId;
    public String status;
  }

  /**
   * @description Represents the Silent Device authenticator metadata.
   */
  public class SilentDeviceAuthenticatorMetadata {
    public String appCorrelationId;
    public String deviceCorrelationId;
    public String make;
    public String model;
    public String osVersion;
    public String appVersion;
  }

  /**
   * @description Represents the flags for the authenticator.
   */
  public class Flags {
    public Boolean userPresent;
    public Boolean userVerified;
    public Boolean attestedData;
    public Boolean backupEligible;
    public Boolean backupStatus;
  }
}
