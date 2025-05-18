/**
 * @description This class is responsible for querying and mapping passkey data
 *              from the PDIApiRepository to the required format.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIDeviceDataRepository extends PDIDataConnection.DataRepositoryBase {
  private static final PDIApiRepository REPO = (PDIApiRepository) Lib_InstanceProvider.forType(
    PDIApiRepository.class
  );

  @TestVisible
  protected override List<CalloutModel> doQuery(
    DataSource.QueryContext context
  ) {
    return REPO.getPublicKeyCredentials(
      PDIHelper.getCustomerUuid(context.tableSelection.filter),
      'type=TYPE_BIOMETRIC OR type=TYPE_SILENT'
    );
  }

  @TestVisible
  protected override void doDelete(String externalId) {
    String customerUuid = PDIHelper.parseResourcePath(externalId, 'person');
    REPO.deletePublicKeyCredential(customerUuid, externalId);
  }

  @TestVisible
  protected override List<Map<String, Object>> transform(
    List<CalloutModel> records
  ) {
    if (records == null) {
      return new List<Map<String, Object>>();
    }
    Map<String, Map<String, Object>> recordByDeviceId = new Map<String, Map<String, Object>>();
    for (CalloutModel apiRecord : records) {
      Map<String, Object> record = this.transform(apiRecord);
      if (record == null) {
        continue;
      }
      String deviceId = (String) record.get('DeviceCorrelationId');
      if (recordByDeviceId.containsKey(deviceId)) {
        recordByDeviceId.get(deviceId).putAll(record);
      } else {
        recordByDeviceId.put(deviceId, record);
      }
    }
    return recordByDeviceId.values();
  }

  @TestVisible
  protected override Map<String, Object> transform(CalloutModel apiRecord) {
    if ((apiRecord instanceof PDIApiModel.PublicKeyCredential) == false) {
      return null;
    }
    PDIApiModel.PublicKeyCredential record = (PDIApiModel.PublicKeyCredential) apiRecord;
    switch on record.type {
      when 'TYPE_BIOMETRIC' {
        return mapBiometric(record);
      }
      when 'TYPE_SILENT' {
        return mapDevice(record);
      }
      when else {
        return null;
      }
    }
  }

  Map<String, Object> mapDevice(PDIApiModel.PublicKeyCredential record) {
    PDIApiModel.SilentDeviceAuthenticatorMetadata device = record.authenticatorMetadata.silentDeviceAuthenticatorMetadata;
    return new Map<String, Object>{
      'Name' => TextUtils.concat(new List<String>{ device.make, device.model }),
      'ExternalId' => record.name,
      'PersonId' => record.personId,
      'Status' => record.state,
      'CreatedTime' => record.createTime,
      'LastAuthenticationTime' => record.lastAuthenticationTime,
      'UpdatedTime' => record.updateTime,
      'DeviceCorrelationId' => device.deviceCorrelationId,
      'AppCorrelationId' => device.appCorrelationId,
      'Make' => device.make,
      'Model' => device.model,
      'OSVersion' => device.osVersion,
      'AppVersion' => device.appVersion
    };
  }

  Map<String, Object> mapBiometric(PDIApiModel.PublicKeyCredential record) {
    PDIApiModel.BiometricAuthenticatorMetadata biometric = record.authenticatorMetadata.biometricAuthenticatorMetadata;
    return new Map<String, Object>{
      'BiometricStatus' => biometric.status,
      'BiometricRegisteredTime' => record.createTime,
      'BiometricLastAuthenticationTime' => record.lastAuthenticationTime,
      'BiometricId' => record.credentialId,
      'DeviceCorrelationId' => biometric.deviceCorrelationId
    };
  }
}
