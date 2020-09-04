/**
 * @author Pavan Kuamr Ananta
 * @since 2020
 * @description GetAccountsAndGoals is a class that makes the callout to mulesoft to get the accounts and goals information based on OCV ID and whitelisted Fabric ID
 * We are suppressing warning temporarily as this Named credentials is used temporarily with custom claims of Fabric ID in JWT..
 * Please note for this integration to work on scratch orgs
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class GetAccountsAndGoals {
  /**
   * @description  The getAccounts(fabricId) is the method to make the Http callout to Mulesoft to fetch the accounts and goals details from Fabric.
   * <b>Note: </b> This method is  temporarily sending fabricId to MuleSoft going forward we will only be using OCV ID and Mulesoft hits ForgeRock to get JWT token with fabricid based on the ocvid passed.
   * The Namedcredentials used in this method is also temporary and needs to be changed.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   *
   * @param ocvId Ocv id for which accounts and goals needs to be fetched
   * @param fabricId Temporary solution to pass Fabric Id till the time ForgeRock is ready according to the document https://confluence.service.anz/display/ABT/Fabric+ID+as+an+interim+solution+till+ForgeRock+is+available
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=false)
  public static String getAccounts(String ocvId, String fabricId) {
    String responseBody = null;
    if (String.isNotBlank(fabricId)) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'callout:SF_MS_Fabric_interim' +
        Label.MS_Get_Accounts_Goals +
        ocvId
      );
      request.setMethod('GET');
      String serializedToken = createSerializedJWT(fabricId);
      request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          responseBody = response.getBody();
        } else {
          throw new CalloutException(response.getBody());
        }
      } catch (Exception e) {
        Lib_SystemLog.logAPIError(
          GetAccountsAndGoals.class.getName(),
          'getAccounts',
          e.getMessage(),
          e.getTypeName(),
          GetAccountsAndGoals.class.getName(),
          null,
          response != null ? response.getBody() : null
        );
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }

  private static String createSerializedJWT(String fabricId) {
    Map<String, String> claims = new Map<String, String>();
    // Add fabric id to the custom claims
    claims.put('fabricid', fabricId);
    Auth.JWT jwt = new Auth.JWT();
    jwt.setIss('salesforce');
    jwt.setAud('mulesoft');
    // Add custom claims to JWT
    jwt.setAdditionalClaims(claims);

    //certificates cannot be mocked in a test scenario, return empty string
    if (Test.isRunningTest()) {
      return '';
    }

    Auth.JWS signedToken;
    if (SFConstants.IS_SCRATCH_ORG) {
      signedToken = new Auth.JWS(jwt, 'sfglobaltestks');
    } else {
      signedToken = new Auth.JWS(jwt, 'sf_signature');
    }

    return signedToken.getCompactSerialization();
  }
}
