/**
 * @author Batya Aisman Sufrin
 * @since Dec 2022
 * @description extended service class for JWT token callout
 * @group Services
 */
public with sharing class AuthService extends Service {
  /**
   *
   * Map Enum Id Type to camel case values required by Forge endpoint
   */
  private static final Map<Service.IdType, String> IDTYPEMAP = new Map<Service.IdType, String>{
    Service.idType.OCVID => '&ocvId=',
    Service.idType.PERSONAID => '&personaId=',
    Service.idType.IDENTIFIER => '&securityMobile=',
    Service.idType.UUID => '&personId='
  };
  /**
   * @param idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   * @param idValue ocv id or persona Id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description fetches response from forge api
   */
  public override HttpCalloutResponse getForgeJWTToken(
    Service.IdType idType,
    String idValue,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();

    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Authorization', 'Bearer ' + idToken);
    headers.put('Content-Type', 'application/x-www-form-urlencoded');

    String payload =
      'identity_system_client_id=' +
      EncodingUtil.urlEncode(forgeAuth.Encrypted_forge_client_id__c, 'UTF-8') +
      '&identity_system_client_secret=' +
      EncodingUtil.urlEncode(
        forgeAuth.Encrypted_forge_client_secret__c,
        'UTF-8'
      ) +
      IDTYPEMAP.get(idType) +
      EncodingUtil.urlEncode(idValue, 'UTF-8') +
      '&scope=aegis-introspect' +
      '&requested_token_type=StaffJWT' +
      '&personaType=retail';

    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Forge_Token,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );
    return response;
  }

  /**
   * @param staffModelWrapper wrapper for forgeV2 api
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description fetches response from forge api
   */
  public override HttpCalloutResponse getForgeJWTToken(
    StaffTokenRequestModel staffModelWrapper,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('traceparent', CommonUtil.generateTraceParent());
    headers.put('x-anz-application-id', 'salesforce');
    String payload = getJWT2Payload(staffModelWrapper, idToken, forgeAuth);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_ForgeV2_Token + staffModelWrapper.anzTokenType,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );
    return response;
  }

  /**
   * @description method is payload data
   * @param staffModelWrapper wrapper for forgeV2 api
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return String
   */
  public static String getJWT2Payload(
    StaffTokenRequestModel staffModelWrapper,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    String idType = IDTYPEMAP.get(staffModelWrapper.idType);
    String payload =
      'aegis_client_id=' +
      EncodingUtil.urlEncode(forgeAuth.Encrypted_forge_client_id__c, 'UTF-8') +
      '&aegis_client_secret=' +
      EncodingUtil.urlEncode(
        forgeAuth.Encrypted_forge_client_secret__c,
        'UTF-8'
      ) +
      '&rqf_id_type=' +
      idType.substring(1, idType.length() - 1) +
      '&rqf_id_value=' +
      EncodingUtil.urlEncode(staffModelWrapper.idValue, 'UTF-8') +
      '&scope=' +
      forgeAuth.RequestedScopes__c +
      '&subject_token_type=' +
      EncodingUtil.urlEncode(forgeAuth.Forgev2_subject_token_type__c, 'UTF-8') +
      '&subject_token=' +
      idToken +
      '&grant_type=client_credentials';

    return payload;
  }
}
