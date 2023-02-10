/**
 * @author Lance Shi
 * @since March 2021
 * @description banking API repository for all auth callouts
 * @group Repository
 */
public with sharing class AuthRepository extends RepositoryBase {
  public Service azureSvc;
  public Service authSvc;
  /**
   * @description initiate the service provider class;
   */
  public AuthRepository() {
    super();
    azureSvc = ServiceProvider.getService(AzureService.class);
    authSvc = ServiceProvider.getService(AuthService.class);
  }

  /**
   * @param redirectURL redirect url in the http request
   * @param code code in the http request
   * @return `IdentityModel` model class constructed from api response
   * @description fetches identity from azure, deserialized to a model
   */
  public IdentityModel getIdentityTokens(String redirectURL, String code) {
    HttpCalloutResponse response = azureSvc.getIdentityTokens(
      redirectURL,
      code
    );
    return getIdentityResult(response);
  }

  /**
   * @param existingRefreshToken existing refresh token id
   * @return `IdentityModel` model class constructed from api response
   * @description fetches identity from azure, deserialized to a model
   */
  public IdentityModel getRefreshIdToken(String existingRefreshToken) {
    HttpCalloutResponse response = azureSvc.getRefreshIdToken(
      existingRefreshToken
    );
    return getIdentityResult(response);
  }

  /**
   * @param idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   * @param idValue ocv id or persona Id
   * @return `IdentityModel` model class constructed from api response
   * @description fetches identity from fabric and deserialized to a model
   */
  public IdentityModel getForgeStaffToken(
    Service.IdType idType,
    String idValue
  ) {
    String idToken = '';
    try {
      idToken = AuthTokenCacheUtil.getSessionIdToken();
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();

      throw new AuraHandledException(e.getMessage());
    }

    if (!Forgerock_Auth__mdt.sObjectType.getDescribe().isQueryable()) {
      throw new AuraHandledException(
        'Unable to query Foregerock - permission denied'
      );
    }

    Forgerock_Auth__mdt forgeAuth = [
      SELECT Id, Encrypted_Forge_Client_Id__c, Encrypted_Forge_Client_Secret__c
      FROM Forgerock_Auth__mdt
      WHERE DeveloperName = 'Forgerock'
      LIMIT 1
    ];

    HttpCalloutResponse response = authSvc.getForgeJWTToken(
      idType,
      idValue,
      idToken,
      forgeAuth
    );
    return getIdentityResult(response);
  }

  /**
   * @param response http response from the api
   * @return `IdentityModel` model class constructed from api response
   * @description fetches identity from fabric, deserialized to a model
   */
  private IdentityModel getIdentityResult(HttpCalloutResponse response) {
    IdentityModel result;
    if (response.successful) {
      try {
        result = IdentityModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, AuthRepository.class);
      }
    } else {
      handleErrors(response, null, AuthRepository.class);
    }
    return result;
  }
}
