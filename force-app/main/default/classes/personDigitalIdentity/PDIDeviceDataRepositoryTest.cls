/**
 * @description Test class for {@link PDIDeviceDataRepository}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@IsTest
private class PDIDeviceDataRepositoryTest {
  static PDIDeviceDataRepository repo = new PDIDeviceDataRepository();

  @IsTest
  static void testDoQuery() {
    DataSource.Filter filter = new DataSource.Filter();
    DataSource.Filter subFilter = new DataSource.Filter();
    subFilter.columnName = 'PersonId';
    subFilter.columnValue = '12345-abcde-67890';
    filter.subfilters = new List<DataSource.Filter>{ subFilter };
    DataSource.TableSelection tableSelection = new DataSource.TableSelection();
    tableSelection.filter = filter;
    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = tableSelection;

    Lib_MockProvider mockRepo = Lib_MockProvider.forType(PDIApiRepository.class)
      .mock(
        'getPublicKeyCredentials',
        new List<PDIApiModel.PublicKeyCredential>{ device }
      );

    Test.startTest();
    repo.doQuery(context);
    Test.stopTest();

    String inputUuid = (String) mockRepo.getHistory('getPublicKeyCredentials')
      ?.getParam('customerUuid');
    Assert.areEqual(
      filter.columnValue,
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  @IsTest
  static void testTransformValidPublicKeyCredential() {
    Test.startTest();
    Map<String, Object> result = repo.transform(device);
    Test.stopTest();

    Assert.isNotNull(result, 'Should return a non-null result');
    Assert.areEqual(
      'Apple iPhone',
      result.get('Name'),
      'Should concatenate make and model'
    );
  }

  @IsTest
  static void testTransformDeviceWithBiometrics() {
    Test.startTest();
    List<Map<String, Object>> result = repo.transform(
      new List<CalloutModel>{ device, biometric }
    );
    Test.stopTest();

    Assert.isTrue(result.size() == 1, 'Should 1 merged result');
    Assert.areEqual(
      device.name,
      result[0].get('ExternalId'),
      'Should return the correct external ID'
    );
    Assert.areEqual(
      biometric.credentialId,
      result[0].get('BiometricId'),
      'Should return the correct biometric ID'
    );
  }

  @IsTest
  static void testTransformInvalidCalloutModel() {
    InvalidModel invalidModel = new InvalidModel();

    Test.startTest();
    Map<String, Object> result = repo.transform(invalidModel);
    Test.stopTest();

    Assert.isNull(result, 'Should return null for invalid CalloutModel type');
  }

  static PDIApiModel.PublicKeyCredential device {
    get {
      if (device != null) {
        return device;
      }
      device = new PDIApiModel.PublicKeyCredential();
      device.name = 'test-mockDevice-name';
      device.personId = 'test-person-id';
      device.state = 'STATE_ACTIVE';
      device.type = 'TYPE_SILENT';
      device.createTime = device.lastAuthenticationTime = device.updateTime = Datetime.now();

      device.authenticatorMetadata = new PDIApiModel.AuthenticatorMetadata();
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata = new PDIApiModel.SilentDeviceAuthenticatorMetadata();
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata.deviceCorrelationId = 'test-device-id';
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata.appCorrelationId = 'test-app-id';
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata.make = 'Apple';
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata.model = 'iPhone';
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata.osVersion = 'iOS 15.0';
      device.authenticatorMetadata.silentDeviceAuthenticatorMetadata.appVersion = '1.0.0';
      return device;
    }
    set;
  }

  static PDIApiModel.PublicKeyCredential biometric {
    get {
      if (biometric != null) {
        return biometric;
      }
      PDIApiModel.PublicKeyCredential biometric = new PDIApiModel.PublicKeyCredential();
      biometric.type = 'TYPE_BIOMETRIC';
      biometric.credentialId = 'biometric-id';
      biometric.createTime = Datetime.now().addDays(-10);
      biometric.lastAuthenticationTime = Datetime.now().addDays(-1);
      biometric.authenticatorMetadata = new PDIApiModel.AuthenticatorMetadata();
      biometric.authenticatorMetadata.biometricAuthenticatorMetadata = new PDIApiModel.BiometricAuthenticatorMetadata();
      biometric.authenticatorMetadata.biometricAuthenticatorMetadata.status = 'STATE_ACTIVE';
      biometric.authenticatorMetadata.biometricAuthenticatorMetadata.appCorrelationId = 'test-app-id';
      biometric.authenticatorMetadata.biometricAuthenticatorMetadata.deviceCorrelationId = 'test-device-id';
      return biometric;
    }
    set;
  }

  class InvalidModel extends CalloutModel {
  }
}
