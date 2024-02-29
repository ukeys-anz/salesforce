/**
 * @author Akshat Khandelwal
 * @since October 2023
 * @description Controller class for TFMDeviceDetailsCard FlexCard
 */

global with sharing class TFMSearchCustomerDeviceDetailsController implements omnistudio.VlocityOpenInterface, Callable {
  private static final String METHODNAME = 'getDeviceDetails';
  private static final String APPCORRELATIONIDPREFIX = 'CID-';
  private static final String DEVICEIDPREFIX = 'DID-';
  private static final String DRNAMEWITHBIOMETRIC = 'TFMSearchCustomerTransformDeviceDetailsWithBiometric';
  private static final String DRNAMEWITHOUTBIOMETRIC = 'TFMSearchCustomerTransformDeviceDetailsWithoutBiometric';
  private static final String FAKECREDRESID = 'CID-F7AE26D3-FAKE-FAKE-FAKE-FFBE0B599CC4(fakecCaxncctGHKuTySauJN-vA),DID-fakecCaxncctGHKuTySauJN-vA';
  private static final String ANZTOKENTYPE = 'staffRqfCustomer';
  private static final String ACTION = 'SearchCustomer';

  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
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
    if (methodName.equals(METHODNAME)) {
      return getDeviceDetails(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean getDeviceDetails(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    PersonDigtialIdentity digitalIdentity = new PersonDigtialIdentity();
    String recordId = (String) input.get('recordId');
    if (Test.isRunningTest()) {
      digitalIdentity.credentialsResId = FAKECREDRESID;
    } else {
      PersonDigitalIdentity__x digitalIdentityRecord = [
        SELECT Id, credentialsResId__c, Internal_User_ID__c, OCV_ID__c
        FROM PersonDigitalIdentity__x
        WHERE Id = :recordId
      ];
      digitalIdentity.credentialsResId = digitalIdentityRecord.credentialsResId__c;
      digitalIdentity.internalUserId = digitalIdentityRecord.Internal_User_ID__c;
      digitalIdentity.ocvId = digitalIdentityRecord.OCV_ID__c;
    }

    if (String.isBlank(digitalIdentity.credentialsResId)) {
      output.put('noDevices', true);
      return true;
    } else {
      StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
      Map<String, String> headers = new Map<String, String>();
      staffModel.headers = headers;
      staffModel.idType = Service.IdType.OCVID;
      staffModel.idValue = digitalIdentity.ocvId;
      staffModel.anzTokenType = ANZTOKENTYPE;
      staffModel.action = ACTION;
      TFMSearchCustomerAPIRepository apiRep = new TFMSearchCustomerAPIRepository();
      headers = apiRep.getValidStaffToken(staffModel);
      String isValid;
      if (Test.isRunningTest()) {
        isValid = 'true';
      } else {
        isValid = headers.get('isValidAction');
      }
      //removing valid action from header
      headers.remove('isValidAction');
      if (isValid == 'true') {
        output.put('devices', getDetails(digitalIdentity, apiRep, staffModel));
        return true;
      } else {
        output.put('noDevices', true);
        return true;
      }
    }
  }

  /**
   * @param digitalIdentity PersonDigtialIdentity record
   * @param apiRep TFMSearchCustomerAPIRepository response
   * @param staffModel StaffTokenRequestModel wrapper class details
   * @return `List<Map<String, Object>>`
   * @description called from getDeviceDetails for fetching Biometric details
   */
  private List<Map<String, Object>> getDetails(
    PersonDigtialIdentity digitalIdentity,
    TFMSearchCustomerAPIRepository apiRep,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, Object> transformedDeviceDetails = new Map<String, Object>();
    List<Map<String, Object>> transformedDeviceDetailsList = new List<Map<String, Object>>();
    List<String> deviceIdsList = new List<String>();
    String deviceResourceId;
    String dRName;
    String appCorrelationId;
    Map<String, Object> responseMap = new Map<String, Object>();
    deviceIdsList = digitalIdentity.credentialsResId.split(',');
    for (String deviceId : deviceIdsList) {
      if (deviceId.startsWith(DEVICEIDPREFIX)) {
        deviceResourceId = deviceId.removeStartIgnoreCase(DEVICEIDPREFIX);
        HttpCalloutResponse response = apiRep.getDeviceDetailsWithoutBiometric(
          staffModel,
          digitalIdentity.internalUserId,
          deviceResourceId
        );
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        dRName = DRNAMEWITHOUTBIOMETRIC;
      } else if (deviceId.startsWith(APPCORRELATIONIDPREFIX)) {
        List<Map<String, Object>> biometricAttestationIdConstantsList = getBiometricAttestationIdConstants();
        appCorrelationId = deviceId.subString(
          4,
          deviceId.indexOfIgnoreCase('(')
        );
        deviceResourceId = deviceId.substring(
          deviceId.indexOfIgnoreCase('(') + 1,
          deviceId.indexOfIgnoreCase(')')
        );
        HttpCalloutResponse response = apiRep.getDeviceDetailsWithBiometric(
          staffModel,
          digitalIdentity.internalUserId,
          appCorrelationId
        );
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        responseMap.put('deviceResourceId', deviceResourceId);
        responseMap.put(
          'biometricConstants',
          (Object) biometricAttestationIdConstantsList
        );
        dRName = DRNAMEWITHBIOMETRIC;
      }
      transformedDeviceDetails = transformAPIResponseToUIResponse(
        responseMap,
        dRName
      );
      transformedDeviceDetailsList.add(transformedDeviceDetails);
    }
    return transformedDeviceDetailsList;
  }

  /**
   * @return List<Map<String,Object>>
   * @description gets the Biometric Attestation ID constants from Custom Metadata
   */
  private List<Map<String, Object>> getBiometricAttestationIdConstants() {
    List<Map<String, Object>> biometricAttestationIdConstantsList = new List<Map<String, Object>>();
    List<String> biometricConstantsList = System.Label.TFMBiometricAttestationIdConstants.split(
      ','
    );
    for (String biometricConstant : biometricConstantsList) {
      biometricAttestationIdConstantsList.add(
        new Map<String, Object>{ 'constant' => (Object) biometricConstant }
      );
    }
    return biometricAttestationIdConstantsList;
  }

  /**
   * @param apiResponse API response to be sent as input to the Dataraptor to transform
   * @param dRName name of DataRaptor to be called
   * @return Map<String,Object>
   * @description calls DataRaptor to transform the response received from API to what FlexCard expects
   */
  private Map<String, Object> transformAPIResponseToUIResponse(
    Map<String, Object> apiResponse,
    String dRName
  ) {
    omnistudio.DRProcessResult dRresult = omnistudio.DRGlobal.process(
      apiResponse,
      dRName
    );
    return (Map<String, Object>) dRresult.toJson();
  }

  private class PersonDigtialIdentity {
    private String credentialsResId;
    private String internalUserId;
    private String ocvId;
  }
}
