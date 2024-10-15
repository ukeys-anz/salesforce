/**
 * @description       : class contains method that is used in IP/OS to invoke Assisted User functionality
 * @author            : Hinduja Upadhyay
 * @group             : TFM
 * @last modified on  : 01-05-2024
 **/
global with sharing class TFMAUFController implements omnistudio.VlocityOpenInterface, Callable {
  // Remote methods
  private static final String UPDATEPINSTATUS = 'updatePinAndStatus';
  private static final String UPDATEMOBILENUMBER = 'updateMobileNumberAndOcvid';
  private static final String DEREGISTERDEVICE = 'deregisterDevice';
  private static final String ARCHIVEUSER = 'archiveUser';
  private static final String RESETPIN = 'resetPin';
  /**
   * @param action String value of local method to invoke
   * @param args arg Map that will contain input, output and options Map
   * @return `Object`
   * @description flex card invokeable method overridden by callable interface
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }

  /**
   * @param methodName String value of local method to invoke
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description flex card invokeable method
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if (methodName.equals(UPDATEPINSTATUS)) {
      return updatePinAndStatus(input, output, options);
    } else if (methodName.equals(UPDATEMOBILENUMBER)) {
      return updateMobileNumberAndOcvid(input, output, options);
    } else if (methodName.equals(DEREGISTERDEVICE)) {
      return deregisterDevice(input, output, options);
    } else if (methodName.equals(ARCHIVEUSER)) {
      return archiveUser(input, output, options);
    } else if (methodName.equals(RESETPIN)) {
      return resetPin(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description update Pin or customer status or Rest PIN based on user's selection
   */
  private Boolean updatePinAndStatus(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String action = (String) input.get(TFMConstants.PINACTION);
    String pinRefId = (String) input.get(TFMConstants.PIN_REF_ID);
    String status = (String) input.get(TFMConstants.STATUS_WITH_SMALL_S);
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMAUFAPIRepository api = new TFMAUFAPIRepository();
    try {
      HttpCalloutResponse response = new HttpCalloutResponse();
      if (String.isBlank(action) && String.isBlank(status)) {
        return false;
      } else if (!String.isBlank(action)) {
        response = api.updatePinStatus(staffModel, pinRefId, action);
      } else {
        String apiStatus = (status == TFMConstants.UNSUSPEND
          ? TFMConstants.ACTIVE
          : status);
        response = api.updateStatus(staffModel, apiStatus);
      }
      output.put(TFMConstants.ISVALID, true);
      output.put(TFMConstants.SHOWSUCCESSTOAST, true);
    } catch (TFMAUFAPIRepository.InsufficientAccessException e) {
      output.put(TFMConstants.ISVALID, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      output.put(TFMConstants.SHOWSUCCESSTOAST, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description update Mobile number or OCV ID based on user's input
   */
  private Boolean updateMobileNumberAndOcvid(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    TFMAUFAPIRepository api = new TFMAUFAPIRepository();
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    String action = (String) input.get(TFMConstants.ACTION_NAME);
    String mobileNumber = (String) input.get(TFMConstants.AUF_MOBILE_NUMBER);
    String ocvid = (String) input.get(TFMConstants.AUF_OCV_ID);
    try {
      HttpCalloutResponse response = new HttpCalloutResponse();
      if (
        action != TFMConstants.UPDATE_MOBILE_NUMBER &&
        action != TFMConstants.UPDATE_OCV_NUMBER
      ) {
        return false;
      } else if (action == TFMConstants.UPDATE_MOBILE_NUMBER) {
        response = api.updateMobileNumber(staffModel, mobileNumber);
      } else if (action == TFMConstants.UPDATE_OCV_NUMBER) {
        response = api.updateOcvid(staffModel, ocvid);
      }
      output.put(TFMConstants.ISVALID, true);
      output.put(TFMConstants.SHOWSUCCESSTOAST, true);
    } catch (TFMAUFAPIRepository.InsufficientAccessException e) {
      output.put(TFMConstants.ISVALID, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (TFMAUFAPIRepository.DuplicateMobileNumberException e) {
      output.put(TFMConstants.DUPLICATE_MOBILE_NUMBER, true);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      output.put(TFMConstants.SHOWSUCCESSTOAST, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description update Mobile number or OCV ID based on user's input
   */
  private Boolean resetPin(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    TFMAUFAPIRepository api = new TFMAUFAPIRepository();
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    String action = (String) input.get(TFMConstants.ACTION_NAME);
    String mobileNumber = (String) input.get(TFMConstants.AUF_MOBILE_NUMBER);
    String ocvid = (String) input.get(TFMConstants.AUF_OCV_ID);
    String pin = (String) input.get(TFMConstants.RESET_PIN_KEY);
    try {
      HttpCalloutResponse response = new HttpCalloutResponse();
      if (pin == null) {
        return false;
      } else {
        response = api.resetPin(staffModel, pin);
        output.put(
          TFMConstants.OUTPUT,
          TFMConstants.RESET_PIN_HISTORY_CHECK_PASSED
        );
      }
      output.put(TFMConstants.ISVALID, true);
      output.put(TFMConstants.SHOWSUCCESSTOAST, true);
    } catch (TFMAUFAPIRepository.InsufficientAccessException e) {
      output.put(TFMConstants.ISVALID, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (TFMAUFAPIRepository.ResetPinBadException e) {
      output.put(TFMConstants.OUTPUT, TFMConstants.RESET_PIN_HISTORY_CHECK);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      output.put(TFMConstants.SHOWSUCCESSTOAST, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description makes an API callout to deregister device
   */
  private Boolean deregisterDevice(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    TFMAUFAPIRepository api = new TFMAUFAPIRepository();
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    String deviceResourceId = (String) input.get(TFMConstants.DEVICERESOURCEID);
    try {
      HttpCalloutResponse response = new HttpCalloutResponse();
      response = api.deregisterDevice(staffModel, deviceResourceId);
      output.put(TFMConstants.ISVALID, true);
      output.put(TFMConstants.SHOWSUCCESSTOAST, true);
    } catch (TFMAUFAPIRepository.InsufficientAccessException e) {
      output.put(TFMConstants.ISVALID, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      output.put(TFMConstants.SHOWSUCCESSTOAST, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description archive user API call and handle response
   */
  private Boolean archiveUser(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    String action = (String) input.get(TFMConstants.ACTION_NAME);
    TFMAUFAPIRepository api = new TFMAUFAPIRepository();
    try {
      HttpCalloutResponse archiveUserModel = api.archiveUser(
        staffModel,
        action
      );
      output.put(TFMConstants.ISVALID, true);
      output.put(TFMConstants.SHOWSUCCESSTOAST, true);
    } catch (TFMAUFAPIRepository.InsufficientAccessException e) {
      output.put(TFMConstants.ISVALID, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (TFMAUFAPIRepository.ArchiveFailException e) {
      output.put(TFMConstants.ARCHIVED, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      output.put(TFMConstants.SHOWSUCCESSTOAST, false);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return true;
  }
}