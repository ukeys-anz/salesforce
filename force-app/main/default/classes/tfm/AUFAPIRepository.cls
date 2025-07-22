/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 06-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class AUFAPIRepository extends RepositoryBase {
  private static final TFMAUFService AUF_SERVICE = (TFMAUFService) Lib_InstanceProvider.forType(
    TFMAUFService.class
  );

  /**
   * @param uuid uuid
   * @param pinRefId pinRefId
   * @param action action
   * @description send parameter to update Pin status
   */
  public void updatePinStatus(String uuid, String pinRefId, String action) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.updatePinStatus(
      staffModel,
      pinRefId,
      action
    );
    handleResponse(response);
  }

  /**
   * @param uuid uuid
   * @param action action
   * @description send parameter to update  status
   */
  public void updateStatus(String uuid, String action) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.updateStatus(staffModel, action);
    handleResponse(response);
  }

  /**
   * @param uuid uuid
   * @param pin pin
   * @description send parameter to reset pin
   */
  public void resetPin(String uuid, String pin) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.resetPin(staffModel, pin);
    if (response.statusCode == 400) {
      AUFResetPinErrorModel resetPinModel = AUFResetPinErrorModel.parse(
        response.error.getMessage()
      );
      if (resetPinModel.AdditionalInfo.errorDetails.error.code == '20004') {
        throw new ResetPinBadException(response.error);
      }
    }
    handleResponse(response);
  }

  /**
   * @param uuid uuid
   * @param deviceResourceId deviceResourceId
   * @description send parameter to deregister device
   */
  public void deregisterDevice(String uuid, String deviceResourceId) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.deregisterDevice(
      staffModel,
      deviceResourceId
    );
    handleResponse(response);
  }

  /**
   * @param uuid uuid
   * @param mobileNumber mobileNumber
   * @description send parameter to update mobile number
   */
  public void updateMobileNumber(String uuid, String mobileNumber) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.updateMobileNumber(
      staffModel,
      mobileNumber
    );
    if (response.statusCode == 409) {
      throw new DuplicateMobileNumberException(response.error);
    }
    handleResponse(response);
  }

  /**
   * @param uuid uuid
   * @param ocvId ocvId
   * @description send parameter to update ocvId
   */
  public void updateOcvid(String uuid, String ocvId) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.updateOcvid(staffModel, ocvId);
    handleResponse(response);
  }

  /**
   * @param uuid uuid
   * @param action action
   * @description send parameter to archiveUser
   */
  public void archiveUser(String uuid, String action) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      uuid
    );
    HttpCalloutResponse response = AUF_SERVICE.updateStatus(staffModel, action);
    if (response.statusCode == 500) {
      throw new ArchiveFailException(response.error);
    }
    handleResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @description handle received response and either return the response or throw exception
   */
  public void handleResponse(HttpCalloutResponse response) {
    List<Integer> insufficientAccessCodes = new List<Integer>{ 401, 403, 405 };
    if (insufficientAccessCodes.contains(response.statusCode)) {
      throw new InsufficientAccessException(response.error);
    }
    if (response.successful == false) {
      throw new ServerErrorException(response.error);
    }
  }

  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
    /**
     * @description InsufficientAccessException
     * @param response response
     */
    public InsufficientAccessException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from AUF Service',
          response.error
        )
        .save();
    }
  }
  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
    /**
     * @description ServerErrorException
     * @param response response
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from AUF Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class ResetPinBadException extends Exception {
    /**
     * @description ResetPinBadException
     * @param response response
     */
    public ResetPinBadException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from AUF Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class DuplicateMobileNumberException extends Exception {
    /**
     * @description DuplicateMobileNumberException
     * @param response response
     */
    public DuplicateMobileNumberException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from AUF Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class ArchiveFailException extends Exception {
    /**
     * @description ArchiveFailException
     * @param response response
     */
    public ArchiveFailException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from AUF Service',
          response.error
        )
        .save();
    }
  }
}