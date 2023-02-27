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
    Service.idType.PERSONAID => '&personaId='
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
      'callout:SF_MS_Fabric' + Label.MS_Forge_Token,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );
    return response;
  }
}
