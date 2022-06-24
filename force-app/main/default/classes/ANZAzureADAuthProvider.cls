/**
 *
 * @author Lance Shi
 * @since 2020
 * @description ANZAzureADAuthProvider is the plugin for Azure AD SSO
 */
global class ANZAzureADAuthProvider extends Auth.AuthProviderPluginClass {
  public static final String FIELD_REDIRECT_URL = 'redirectURL__c';
  public static final String FIELD_AUTH_URL = 'Auth_URL__c';
  public static final String FIELD_CID = 'clientID__c';
  public static final String FIELD_USER_ENDPOINT = 'UserEndpoint__c';
  public static final String PROMPT = 'select_account'; /* Indicates the type of user interaction that is required.
   More details here: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow*/
  public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
  private String key;
  private String authUrl; // application redirection to the Microsoft website for authentication and authorization

  private String expiresOn;
  @testVisible
  private String idToken;

  /**
   * @description this method is a must implement for AuthProvider Plugin which returns the identity metadata type
   *
   * @return `String`
   */
  global String getCustomMetadataType() {
    return 'AzureAD_Identity__mdt';
  }

  /**
   * @description this method is to initiate base configurations
   * @param authProviderConfiguration Map<String,String>
   * @param stateToPropagate String
   * @return `PageReference`
   */
  global PageReference initiate(
    Map<String, String> authProviderConfiguration,
    String stateToPropagate
  ) {
    authUrl = authProviderConfiguration.get(FIELD_AUTH_URL);
    key = authProviderConfiguration.get(FIELD_CID);
    redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);
    String url =
      authUrl +
      '?client_id=' +
      key +
      '&response_type=code&redirect_uri=' +
      redirectUrl +
      '&state=' +
      stateToPropagate +
      '&scope=openid+offline_access+profile' +
      '&prompt=' +
      PROMPT;
    return new PageReference(url);
  }

  /**
   * @description this method is to handle callback functionalities after user verifies
   * @param authProviderConfiguration Map<String,String>
   * @param state Auth.AuthProviderCallbackState
   * @return `Auth.AuthProviderTokenResponse`
   */
  global Auth.AuthProviderTokenResponse handleCallback(
    Map<String, String> authProviderConfiguration,
    Auth.AuthProviderCallbackState state
  ) {
    redirectURL = authProviderConfiguration.get(FIELD_REDIRECT_URL);

    Map<String, String> queryParams = state.queryParameters;

    String code = queryParams.get('code');
    String sfdcState = queryParams.get('state');

    String accessToken;
    String refreshToken;
    AuthRepository authRepo = new AuthRepository();
    IdentityModel idenModel = authRepo.getIdentityTokens(redirectURL, code);

    accessToken = idenModel.accessToken;
    refreshToken = idenModel.refreshToken;
    idToken = idenModel.idToken;
    expiresOn = String.valueOf(idenModel.expiresOn);

    return new Auth.AuthProviderTokenResponse(
      'Open Id Connect',
      accessToken,
      refreshToken,
      sfdcState
    );
  }

  /**
   * @description this method is to get user information from Microsoft AD. We are not using id token because it doesnot contain all the information
   * @param authProviderConfiguration Map<String,String>
   * @param response Auth.AuthProviderTokenResponse
   * @return `Auth.UserData'
   */
  global Auth.UserData getUserInfo(
    Map<String, String> authProviderConfiguration,
    Auth.AuthProviderTokenResponse response
  ) {
    //Here the developer is responsible for constructing an Auth.UserData object

    // A more efficient method to populate the Auth.UserData object is to inspect the claims within the Id Token using standard JWT libraries
    // This is the recommended approach from Azure

    String token = response.oauthToken;
    String refresh = response.oauthSecretOrRefreshToken;

    Map<String, String> provMap = new Map<String, String>();
    String id = '';

    List<String> idTokenList = idToken.split('\\.');
    if (idTokenList.size() < 2) {
      return null;
    }
    String userJson = (EncodingUtil.base64Decode(
        CommonUtil.base64URLToBase64(idTokenList[1])
      ))
      .toString();
    Map<String, Object> userJsonMap = (Map<String, Object>) (JSON.deserializeUntyped(
      userJson
    ));
    String upn = (String) userJsonMap.get('upn');
    id = upn;
    String username = (String) userJsonMap.get('upn');

    // Add these to the data passed to the reg. handler in the data.attributeMap
    // required so they can be used during the Staff Token JWT exchange for callouts
    provMap.put('accessToken', token);
    provMap.put('refreshToken', refresh);
    provMap.put('idToken', idToken);
    provMap.put('expiresOn', expiresOn);

    provMap.put('upn', upn);

    // As not creating user in Reg. handler, and performing only limited user updates most attributes are null
    // In reality would need to add First Name, Last Name etc if these are to be updated if different in Azure
    return new Auth.UserData(
      id,
      null,
      null,
      null,
      null,
      null,
      username,
      null,
      'ANZAzureADAuthProvider',
      null,
      provMap
    );
  }
}
