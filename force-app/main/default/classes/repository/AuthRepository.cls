/**
 * @author Lance Shi
 * @since March 2021
 * @description banking API repository for all auth callouts
 */
public with sharing class AuthRepository extends RepositoryBase {
  public Service azureSvc;
  public Service fabricSvc;
  /**
   * @description initiate the service provider class;
   */
  public AuthRepository() {
    super();
    azureSvc = ServiceProvider.getService(AzureService.class);
    fabricSvc = ServiceProvider.getService(FabricService.class);
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
   * @param ocvId ocv id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `IdentityModel` model class constructed from api response
   * @description fetches identity from fabric and deserialized to a model
   */
  public IdentityModel getForgeStaffToken(
    String ocvId,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    HttpCalloutResponse response = fabricSvc.getForgeJWTToken(
      ocvId,
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
