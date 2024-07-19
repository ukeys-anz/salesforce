/**
 * @author Akshat Khandelwal
 * @since October 2023
 * @description Controller class for TFMDeviceDetailsCard FlexCard
 */

global with sharing class TFMSearchCustomerDeviceDetailsController implements omnistudio.VlocityOpenInterface, Callable {
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
    if (methodName.equals(TFMConstants.GET_DEVICE_DETAILS_METHODNAME)) {
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
    String recordId = (String) input.get(TFMConstants.RECORDID);
    PersonDigitalIdentity__x digitalIdentityRecord = input.keySet()
        .contains(TFMConstants.USE_MOCK)
      ? returnMockPersonDigitalIdentity()
      : [
          SELECT
            Id,
            credentialsResId__c,
            Internal_User_ID__c,
            OCV_ID__c,
            Status__c
          FROM PersonDigitalIdentity__x
          WHERE Id = :recordId
        ];

    if (String.isBlank(digitalIdentityRecord.credentialsResId__c)) {
      output.put('noDevices', true);
      return true;
    } else {
      StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
      staffModel.idType = Service.IdType.OCVID;
      staffModel.idValue = digitalIdentityRecord.OCV_ID__c;
      staffModel.anzTokenType = TFMConstants.ANZTOKENTYPE;
      List<Map<String, Object>> transformedDeviceDetailsList = getDetails(
        digitalIdentityRecord,
        staffModel
      );
      if (transformedDeviceDetailsList.isEmpty()) {
        output.put('noDevices', true);
      } else {
        output.put('devices', transformedDeviceDetailsList);
      }
      return true;
    }
  }

  /**
   * @param digitalIdentityRecord PersonDigitalIdentity__x record
   * @param staffModel StaffTokenRequestModel wrapper class details
   * @return `List<Map<String, Object>>`
   * @description called from getDeviceDetails for fetching Biometric details
   */
  private List<Map<String, Object>> getDetails(
    PersonDigitalIdentity__x digitalIdentityRecord,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    Map<String, Object> transformedDeviceDetails = new Map<String, Object>();
    List<Map<String, Object>> transformedDeviceDetailsList = new List<Map<String, Object>>();
    String dRName;
    List<String> deviceIdsList = digitalIdentityRecord.credentialsResId__c.split(
      ','
    );
    for (String deviceId : deviceIdsList) {
      if (
        !deviceId.startsWith(TFMConstants.DEVICEIDPREFIX) &&
        !deviceId.startsWith(TFMConstants.APPCORRELATIONIDPREFIX)
      ) {
        continue;
      } else if (deviceId.startsWith(TFMConstants.DEVICEIDPREFIX)) {
        responseMap = processDevicesWithoutBiometric(
          deviceId,
          staffModel,
          digitalIdentityRecord.Internal_User_ID__c
        );
        dRName = TFMConstants.DRNAMEWITHOUTBIOMETRIC;
      } else {
        responseMap = processDevicesWithBiometric(
          deviceId,
          staffModel,
          digitalIdentityRecord.Internal_User_ID__c
        );
        dRName = TFMConstants.DRNAMEWITHBIOMETRIC;
      }
      transformedDeviceDetails = transformAPIResponseToUIResponse(
        responseMap,
        dRName
      );
      Boolean hasAccessToAegisFeatures = FeatureManagement.checkPermission(
          'AccessAegisFeatures'
        ) &&
        digitalIdentityRecord.Status__c.toLowerCase() != TFMConstants.ARCHIVED
        ? true
        : false;
      transformedDeviceDetails.put(
        TFMConstants.RECORDID,
        digitalIdentityRecord.Id
      );
      transformedDeviceDetails.put(
        TFMConstants.ACCESS_AEGIS_FEATURES,
        String.valueOf(hasAccessToAegisFeatures)
      );
      transformedDeviceDetailsList.add(transformedDeviceDetails);
    }
    return transformedDeviceDetailsList;
  }

  /**
   * @param deviceId deviceId of PersonDigitalIdentity__x record
   * @param staffModel StaffTokenRequestModel wrapper class details
   * @param internalUserId internal user id of the PersonDigitalIdentity__x record
   * @return Map<String, Object> response
   * @description process and call DevicesWithoutBiometric api
   */
  private Map<String, Object> processDevicesWithoutBiometric(
    String deviceId,
    StaffTokenRequestModel staffModel,
    String internalUserId
  ) {
    TFMSearchCustomerAPIRepository apiRep = new TFMSearchCustomerAPIRepository();
    String deviceResourceId = deviceId.removeStartIgnoreCase(
      TFMConstants.DEVICEIDPREFIX
    );
    HttpCalloutResponse response = apiRep.getDeviceDetailsWithoutBiometric(
      staffModel,
      internalUserId,
      deviceResourceId
    );
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    responseMap.put(TFMConstants.DEVICERESOURCEID, deviceResourceId);
    return responseMap;
  }

  /**
   * @param deviceId deviceId of PersonDigitalIdentity__x record
   * @param staffModel StaffTokenRequestModel wrapper class details
   * @param internalUserId internal user id of the PersonDigitalIdentity__x record
   * @return Map<String, Object> response
   * @description process and call DevicesWithBiometric api
   */
  private Map<String, Object> processDevicesWithBiometric(
    String deviceId,
    StaffTokenRequestModel staffModel,
    String internalUserId
  ) {
    TFMSearchCustomerAPIRepository apiRep = new TFMSearchCustomerAPIRepository();
    List<Map<String, Object>> biometricAttestationIdConstantsList = getBiometricAttestationIdConstants();
    String appCorrelationId = deviceId.subString(
      4,
      deviceId.indexOfIgnoreCase('(')
    );
    String deviceResourceId = deviceId.substring(
      deviceId.indexOfIgnoreCase('(') + 1,
      deviceId.indexOfIgnoreCase(')')
    );
    HttpCalloutResponse response = apiRep.getDeviceDetailsWithBiometric(
      staffModel,
      internalUserId,
      appCorrelationId
    );
    if (!response.successful) {
      return null;
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    responseMap.put(TFMConstants.DEVICERESOURCEID, deviceResourceId);
    responseMap.put(
      'biometricConstants',
      (Object) biometricAttestationIdConstantsList
    );
    return responseMap;
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

  /**
   * @return PersonDigitalIdentity__x
   * @description returns mock PersonDigitalIdentity__x record
   */
  private PersonDigitalIdentity__x returnMockPersonDigitalIdentity() {
    PersonDigitalIdentity__x digitalIdentityRecord = new PersonDigitalIdentity__x(
      credentialsResId__c = TFMConstants.CREDENTIALSRESID,
      Internal_User_ID__c = TFMConstants.INTERNAL_USER_ID,
      OCV_ID__c = TFMConstants.OCV_ID_VALUE,
      Id = Lib_FakeIdGenerator.getMockId(
        PersonDigitalIdentity__x.getSObjectType()
      ),
      Status__c = TFMConstants.ACTIVE
    );
    return digitalIdentityRecord;
  }
}
