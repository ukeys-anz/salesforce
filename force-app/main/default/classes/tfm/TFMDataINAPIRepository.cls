/**
 * @author Anuj Jain
 * @since March 2024
 * @description Data In API repository for to invoke Mule to get response
 * @group Repository
 */
public with sharing class TFMDataINAPIRepository extends RepositoryBase {
  /**
   * @param staffModel staffmodel
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public HttpCalloutResponse getDataINConsentsListAPI(
    StaffTokenRequestModel staffModel
  ) {
    TFMDataINService s = (TFMDataINService) ServiceProvider.getService(
      TFMDataINService.class
    );
    HttpCalloutResponse res = s.getDataINConsentsListAPI(staffModel);
    return getResponse(res);
  }

  /**
   * @param staffModel staffmodel
   *  @param consentIdValue consentId Value
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public HttpCalloutResponse getDataINAccountListAPI(
    StaffTokenRequestModel staffModel,
    String consentIdValue
  ) {
    TFMDataINService s = (TFMDataINService) ServiceProvider.getService(
      TFMDataINService.class
    );
    HttpCalloutResponse res = s.getDataINAccountListAPI(
      staffModel,
      consentIdValue
    );
    return getResponse(res);
  }

  /**
   * @param methodName passing method name for resuing same method for Data IN export
   * @param consentId consentId of the record
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public HttpCalloutResponse exportConsent(
    String methodName,
    String consentId,
    StaffTokenRequestModel staffModel
  ) {
    TFMDataINService s = (TFMDataINService) ServiceProvider.getService(
      TFMDataINService.class
    );
    HttpCalloutResponse res = s.exportConsent(
      methodName,
      consentId,
      staffModel
    );
    return getResponse(res);
  }
  /**
   * @param consentId consentId of the record
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public HttpCalloutResponse revokeConsent(
    String consentId,
    StaffTokenRequestModel staffModel
  ) {
    TFMDataINService s = (TFMDataINService) ServiceProvider.getService(
      TFMDataINService.class
    );
    HttpCalloutResponse res = s.revokeConsent(consentId, staffModel);
    return getResponse(res);
  }

  /**
   * @param response api response
   * @return HttpCalloutResponse response
   * @description common method for response
   */
  public HttpCalloutResponse getResponse(HttpCalloutResponse response) {
    if (
      !response.successful &&
      (response.statusCode != 401 ||
      response.statusCode != 403)
    ) {
      throw response.error;
    }
    return response;
  }
}
