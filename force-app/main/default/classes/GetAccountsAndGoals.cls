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
   * @description  The getAccounts(ocvId) is the method to make the Http callout to Mulesoft to fetch the accounts and goals details from Fabric.
   * The Namedcredentials used in this method is also temporary and needs to be changed.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   *
   * @param ocvId Ocv id for which accounts and goals needs to be fetched
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=false)
  public static String getAccounts(String ocvId) {
    String responseBody = null;
    if (String.isNotBlank(ocvId)) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:SF_MS_Fabric' + Label.MS_Get_Accounts_Goals);

      request.setMethod('GET');
      String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvId);
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
}
