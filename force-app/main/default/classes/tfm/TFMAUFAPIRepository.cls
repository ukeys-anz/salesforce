/**
 * @author Hinduja Upadhyay
 * @since April 2024
 * @description Assisted User function repository to invoke Mule to get response
 * @group Repository
 */

public with sharing class TFMAUFAPIRepository extends RepositoryBase {
  /**
   * @param staffModel model to call staffJWT api
   * @param pinRefId credentials id
   * @param action action
   * @return HttpCalloutResponse response
   * @description send parameter to update Pin Status
   */
  public HttpCalloutResponse updatePinStatus(
    StaffTokenRequestModel staffModel,
    String pinRefId,
    String action
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.updatePinStatus(
      staffModel,
      pinRefId,
      action
    );
    return handleResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param action action
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public HttpCalloutResponse updateStatus(
    StaffTokenRequestModel staffModel,
    String action
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.updateStatus(staffModel, action);
    return handleResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param value changed value of mobile number
   * @return HttpCalloutResponse response
   * @description send parameter to update mobile number
   */
  public HttpCalloutResponse updateMobileNumber(
    StaffTokenRequestModel staffModel,
    String value
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.updateMobileNumber(staffModel, value);
    if (response.statusCode == 409) {
      throw new DuplicateMobileNumberException(response.error.getMessage());
    }
    return handleResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param value change ocvid value
   * @return HttpCalloutResponse response
   * @description send parameter to update OCVID
   */
  public HttpCalloutResponse updateOcvid(
    StaffTokenRequestModel staffModel,
    String value
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.updateOcvid(staffModel, value);
    return handleResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param deviceResourceId resourceId of the device to be deregistered
   * @return HttpCalloutResponse response
   * @description make callout to deregister device
   */
  public HttpCalloutResponse deregisterDevice(
    StaffTokenRequestModel staffModel,
    String deviceResourceId
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.deregisterDevice(
      staffModel,
      deviceResourceId
    );
    return handleResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param pin String value
   * @return HttpCalloutResponse response
   * @description send parameter to get Reset PIN link
   */
  public HttpCalloutResponse resetPin(
    StaffTokenRequestModel staffModel,
    String pin
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.resetPin(staffModel, pin);

    if (response.statusCode == 400) {
      AUFResetPinErrorModel resetPinModel = AUFResetPinErrorModel.parse(
        response.error.getMessage()
      );
      if (resetPinModel.AdditionalInfo.errorDetails.error.code == '20004') {
        throw new ResetPinBadException(response.error.getMessage());
      }
    }
    return handleResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param action action
   * @return HttpCalloutResponse response
   * @description make API callout to archive user and handle response
   */
  public HttpCalloutResponse archiveUser(
    StaffTokenRequestModel staffModel,
    String action
  ) {
    TFMAUFService s = (TFMAUFService) ServiceProvider.getService(
      TFMAUFService.class
    );
    HttpCalloutResponse response = s.updateStatus(staffModel, action);
    if (response.statusCode == 500) {
      throw new ArchiveFailException(response.error.getMessage());
    }
    return handleResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  public HttpCalloutResponse handleResponse(HttpCalloutResponse response) {
    List<Integer> insufficientAccessCodes = new List<Integer>{ 401, 403, 405 };
    if (response.successful) {
      return response;
    } else if (insufficientAccessCodes.contains(response.statusCode)) {
      throw new InsufficientAccessException(response.error.getMessage());
    } else {
      throw response.error;
    }
  }

  /**
   * @description custom exception
   */
  public class ArchiveFailException extends Exception {
  }
  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
  }
  /**
   * @description custom exception
   */
  public class ResetPinBadException extends Exception {
  }
  /**
   * @description custom exception if user updates the mobile number to an already existing number
   */
  public class DuplicateMobileNumberException extends Exception {
  }
}
