/**
 * @author Sneha Malik
 * @since 2022
 * @description AegisController. Helper class that gives customer's mobile number, current user's session token ID and Aegis URL to redirect the user to Aegis portal.
 */

@SuppressWarnings('PMD.ApexSuggestUsingNamedCred, PMD.CyclomaticComplexity')
public with sharing class AegisController {
  /**
   * @description The AegisPortalRedirect component uses this to fetch the Aegis Portal URL.
   * @param accountId the id of the individual account
   * @return string aegisURL
   */
  @AuraEnabled
  public static string getAccount(Id accountId) {
    Account accRecord = null;
    String errorStr = 'Something went wrong. Contact your Salesforce administrator for help.';
    if (Account.sObjectType.getDescribe().isQueryable()) {
      accRecord = [
        SELECT Id, PersonMobilePhone
        FROM Account
        WHERE Id = :accountId
      ];
    }

    if (accRecord != null) {
      String identifier = null;
      if (accRecord.PersonMobilePhone != null) {
        identifier = EncodingUtil.base64Encode(
          blob.valueof(accRecord.PersonMobilePhone)
        );
        string azureToken = getAzureToken();
        if (azureToken != null) {
          string aegisURL = getAegisURL(identifier, azureToken);
          return aegisURL;
        } else {
          errorStr = 'Error in fetching session token. Please try sign in again or Contact your Salesforce administrator for help.';
        }
      } else {
        errorStr = 'This customer does not have Mobile phone.';
      }
    } else {
      errorStr = 'Not enough permissions to query Customer Account.';
    }
    return errorStr;
  }
  /**
   * @description  retrieves current user's id token from session cache
   * @return String id token
   * @exception TokenCacheException throws when no token is found
   */
  public static string getAzureToken() {
    String idToken = null;
    try {
      idToken = AuthTokenCacheUtil.getSessionIdToken();
    } catch (Exception e) {
      lib_systemLog log = new lib_systemLog('AegisController', 'getAzureToken');
      log.addMessage(
        e.getTypeName(),
        e.getMessage(),
        Lib_SystemLog.Severity.ERROR
      );
      log.insertLogAsync();
    }
    return idToken;
  }
  /**
   * @description tells aegis url for redirection.
   * @param identifier mobile number of individual account
   * @param tokenId user's id token from session cache
   * @return String id aegis url
   */
  public static String getAegisURL(String identifier, String tokenId) {
    String aegisURL = null;
    Map<String, Aegis_Env_Setting__c> customSettingMap = Aegis_Env_Setting__c.getAll();
    for (Aegis_Env_Setting__c custSetting : customSettingMap.values()) {
      aegisURL = custSetting.Aegis_URL__c;
    }
    aegisURL +=
      '/search-users?identifier=' +
      identifier +
      '&azure_token=' +
      tokenId;
    return aegisURL;
  }
}
