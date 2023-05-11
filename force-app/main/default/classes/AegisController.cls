/**
 * @author Sneha Malik
 * @since 2022
 * @description AegisController. Helper class that gives customer's or Customer's Onboarding Aplication mobile number, current user's session token ID and Aegis URL to redirect the user to Aegis portal.
 */

@SuppressWarnings('PMD.ApexSuggestUsingNamedCred, PMD.CyclomaticComplexity')
public with sharing class AegisController {
  @TestVisible
  private static final String ACCOUNT_TYPE = 'Account';
  @TestVisible
  private static final String COB_TYPE = 'CustomerOnboardingApplication__c';
  @TestVisible
  private static final String DATA_SET_NAME = 'AegisURL';
  @TestVisible
  private static final String NO_MOBILE_ERROR = 'This record does not have Mobile phone.';
  @TestVisible
  private static final String MISSING_CONFIGURATION_ERROR = 'Aegis Portal URL is not configured. Contact your Salesforce Administrator for help.';

  /**
   * @description The AegisPortalRedirect component uses this to fetch the Aegis Portal URL.
   * @param recordId Record Id of the Account or Customer Onboarding Application
   * @param objectType Object type
   * @return String aegisURL
   */
  @AuraEnabled
  public static string getAegisUrl(Id recordId, String objectType) {
    String mobile = getMobile(recordId, objectType);

    String azureToken = getAzureToken();

    String identifier = getIdentifier(mobile);

    String aegisURL = buildAegisURL(identifier, azureToken);
    return aegisURL;
  }

  /**
   * @description Retrieves current user's id token from session cache
   * @return String id token
   * @exception AuraHandledException throws when no token is found
   */
  private static string getAzureToken() {
    String idToken = null;
    try {
      idToken = AuthTokenCacheUtil.getSessionIdToken();
    } catch (Exception e) {
      throwException(e.getMessage());
    }
    return idToken;
  }

  /**
   * @description Get mobile phone.
   * @param recordId Record Id of the Account
   * @param objectType Object type
   * @return String Mobile phone number
   */
  private static String getMobile(Id recordId, String objectType) {
    String mobile = null;

    if (objectType == ACCOUNT_TYPE) {
      mobile = getAccountMobile(recordId);
    } else if (objectType == COB_TYPE) {
      mobile = getCobMobile(recordId);
    }

    if (mobile == null) {
      throwException(NO_MOBILE_ERROR);
    }

    return mobile;
  }

  /**
   * @description Get encoded mobile phone.
   * @param mobile Mobile phone to encode
   * @return String Encoded mobile phone
   */
  @TestVisible
  private static String getIdentifier(String mobile) {
    String identifier = EncodingUtil.base64Encode(blob.valueof(mobile));

    return identifier;
  }

  /**
   * @description Get aegis url for redirection.
   * @param identifier mobile number of Individual Account or Customer Onboarding Application
   * @param tokenId user's id token from session cache
   * @return String Aegis Url
   */
  @TestVisible
  private static String buildAegisURL(String identifier, String tokenId) {
    String aegisURL = Aegis_Env_Setting__c.getValues(DATA_SET_NAME)
      ?.Aegis_URL__c;

    if (aegisURL == null) {
      throwException(MISSING_CONFIGURATION_ERROR);
    }

    aegisURL +=
      '/search-users?identifier=' +
      identifier +
      '&azure_token=' +
      tokenId;
    return aegisURL;
  }

  /**
   * @description Get Account mobile phone.
   * @param accountId Record Id of the Account
   * @return String Mobile phone number
   */
  private static String getAccountMobile(Id accountId) {
    if (PermissionUtils.canQuery('Account') == true) {
      Account accRecord = [
        SELECT Id, PersonMobilePhone
        FROM Account
        WHERE Id = :accountId
      ];

      return accRecord.PersonMobilePhone;
    }

    return null;
  }

  /**
   * @description Get Customer Onboarding Application mobile phone.
   * @param cobId Record Id of the Customer Onboarding Application
   * @return String Mobile phone number
   */
  private static String getCobMobile(Id cobId) {
    if (PermissionUtils.canQuery('CustomerOnboardingApplication__c') == true) {
      CustomerOnboardingApplication__c cobRecord = [
        SELECT Id, SecurityMobile__c
        FROM CustomerOnboardingApplication__c
        WHERE Id = :cobId
      ];

      return cobRecord.SecurityMobile__c;
    }

    return null;
  }

  /**
   * @description throws AuraHandledException with error message
   * @param errorMsg error message to use in the exception
   */
  private static void throwException(String errorMsg) {
    // AuraHandleException is quirky, setMessage() and constructor must be invoked otherwise "Script-thrown exception" is thrown instead of actual exception message
    AuraHandledException e = new AuraHandledException(errorMsg);
    e.setMessage(errorMsg);

    Logger.error('Failed to redirect to Aegis Portal', e);
    Logger.saveLog();
    throw e;
  }
}
