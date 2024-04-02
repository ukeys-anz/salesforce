/**
 * @author shawg2
 * @since January 2024
 * @description Construct JWT header & payload
 * @group Utils
 * @runTests JoinCIBAServiceTest
 */

public with sharing class JWTUtil {
  /**
   * @description Singleton Member variable for the JSONWebTokenAttributes__mdt record
   */
  private JSONWebTokenAttributes__mdt jwtAttributes;

  /**
   * @description Constructor
   * @param strName Name of JSONWebTokenAttributes__mdt record to use
   */
  public JWTUtil(String strName) {
    List<JSONWebTokenAttributes__mdt> lstJWTAttributes = [
      SELECT
        Algorithm__c,
        Audience__c,
        AuthContext__c,
        BindingMessage__c,
        DeveloperName,
        Issuer__c,
        KeyIdentification__c,
        LoginHint__c,
        Scope__c,
        SigningCertificateDeveloperName__c,
        Type__c,
        ValidFor__c
      FROM JSONWebTokenAttributes__mdt
      WHERE DeveloperName = :strName
    ];
    if (!lstJWTAttributes.isEmpty()) {
      jwtAttributes = lstJWTAttributes[0];
    }
  }

  /**
   * @description Combine JWTHeader, JWTPayload and signature
   * @param ocvId OCV Id of Customer seeking authentication of Coach/Banker
   * @param acrValue authentication mechanism for which authentication request is initiated
   * @param uuid unique jwt request id
   * @return Signed JWT
   */
  public String getSignedJWT(String ocvId, String acrValue, string uuid) {
    if (jwtAttributes == null) {
      return null;
    }
    try {
      String jwtRequest =
        getJWTHeader() +
        '.' +
        getJWTPayload(ocvId, acrValue, uuid);
      return jwtRequest + '.' + getJWTSignature(jwtRequest);
    } catch (Exception ex) {
      Logger.error('JWTUtil: Error: ' + jwtAttributes.DeveloperName, ex);
      Logger.saveLog();
    }
    return null;
  }

  /**
   * @description Build standard JWT header
   * @return JWT Header
   */
  private String getJWTHeader() {
    JSONGenerator header = JSON.createGenerator(false);
    header.writeStartObject();
    header.writeStringField('alg', jwtAttributes.Algorithm__c);
    header.writeStringField('typ', jwtAttributes.Type__c);
    header.writeStringField('kid', jwtAttributes.KeyIdentification__c);
    header.writeEndObject();
    return CommonUtil.base64URLencode(header.getAsString());
  }

  /**
   * @description Build standard JWT payload
   * @param ocvId OCV Id of Customer seeking authentication of Coach/Banker
   * @param acrValue authentication mechanism for which authentication request is initiated
   * @param uuid unique jwt request id
   * @return JWT Payload
   */
  private String getJWTPayload(String ocvId, String acrValue, string uuid) {
    Long rightNow = (Datetime.now().getTime() / 1000) + 1;
    JSONGenerator body = JSON.createGenerator(false);
    body.writeStartObject();
    body.writeStringField('iss', jwtAttributes.Issuer__c);
    if (jwtAttributes.LoginHint__c != null) {
      String strLoginHint = String.format(
        jwtAttributes.LoginHint__c,
        new List<String>{ ocvId }
      );
      body.writeStringField('login_hint', strLoginHint);
    }
    body.writeStringField('aud', jwtAttributes.Audience__c);
    body.writeStringField('acr_values', acrValue);
    body.writeStringField('auth_context', jwtAttributes.AuthContext__c);
    body.writeStringField('scope', jwtAttributes.Scope__c);
    body.writeStringField('binding_message', jwtAttributes.BindingMessage__c);
    body.writeNumberField('exp', (rightNow + jwtAttributes.ValidFor__c));
    body.writeNumberField('iat', rightNow);
    body.writeStringField('jti', uuid);
    body.writeEndObject();
    return CommonUtil.base64URLencode(body.getAsString());
  }
  /**
   * @description Signing the jwt request with the certificate
   * @param jwtRequest to be signed
   * @return JWT Header
   */
  private String getJWTSignature(String jwtRequest) {
    if (Test.isRunningTest()) {
      return CommonUtil.base64URLencode('testSignature');
    }
    Blob bSignature = Crypto.signWithCertificate(
      CommonUtil.getAlgorithmNamefromHash(jwtAttributes.Algorithm__c),
      Blob.valueOf(jwtRequest),
      jwtAttributes.SigningCertificateDeveloperName__c
    );
    return CommonUtil.base64URLencode(bSignature);
  }
}
