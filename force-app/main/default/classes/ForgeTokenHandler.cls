/**
 * @author Peter Charalambous
 * @since 2020
 * @description Forge Token Handler. Suppressing warning for ApexSuggestUsingNamedCred as we need token from cache
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred, PMD.CyclomaticComplexity')
public with sharing class ForgeTokenHandler {
  /**
   * @description Retrieve the Forge JWT token from cache or make request for new token
   * @param ocvId ocvID
   * @return String
   * @exception CalloutException
   */
  public static String getForgeJWTToken(String ocvId) {
    String idToken = '';
    try {
      idToken = AuthTokenCacheUtil.getSessionIdToken();
    } catch (Exception e) {
      Lib_SystemLog.logAPIError(
        ForgeTokenHandler.class.getName(),
        'getForgeJWTToken',
        e.getMessage(),
        e.getTypeName(),
        ForgeTokenHandler.class.getName(),
        null,
        'No active token found, please log out, and back into Salesforce'
      );

      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }

    Forgerock_Auth__mdt forgeAuth;
    if (Forgerock_Auth__mdt.sObjectType.getDescribe().isQueryable()) {
      forgeAuth = [
        SELECT
          Id,
          Encrypted_Forge_Client_Id__c,
          Encrypted_Forge_Client_Secret__c
        FROM Forgerock_Auth__mdt
        WHERE DeveloperName = 'Forgerock'
        LIMIT 1
      ];
    }

    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:SF_MS_Fabric' + Label.MS_Forge_Token);
    request.setHeader('client_id', '{!$Credential.Username}');
    request.setHeader('client_secret', '{!$Credential.Password}');
    request.setHeader('Authorization', 'Bearer ' + idToken);

    request.setMethod('POST');
    //This needs to be replaced with uniquely generated id from Salesforce
    request.setHeader(
      'x-correlation-id',
      'cfbd178b-4997-44c4-afdc-f9158d7fb955'
    );

    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    String payload =
      'identity_system_client_id=' +
      EncodingUtil.urlEncode(forgeAuth.Encrypted_forge_client_id__c, 'UTF-8') +
      '&identity_system_client_secret=' +
      EncodingUtil.urlEncode(
        forgeAuth.Encrypted_forge_client_secret__c,
        'UTF-8'
      ) +
      '&ocvId=' +
      EncodingUtil.urlEncode(ocvId, 'UTF-8') +
      '&scope=aegis-introspect' +
      '&requested_token_type=StaffJWT' +
      '&personaType=retail';

    request.setBody(payload);

    HTTPResponse response = null;
    String responseBody = '';
    try {
      Http http = new Http();
      response = http.send(request);
      if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
        responseBody = response.getBody();
      } else {
        throw new CalloutException(response.getBody());
      }
    } catch (Exception e) {
      Lib_SystemLog.logAPIError(
        ForgeTokenHandler.class.getName(),
        'getForgeJWTToken',
        e.getMessage(),
        e.getTypeName(),
        ForgeTokenHandler.class.getName(),
        null,
        response != null ? response.getBody() : null
      );
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }

    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      responseBody
    );

    return (String) responseMap.get('access_token');
  }
}
