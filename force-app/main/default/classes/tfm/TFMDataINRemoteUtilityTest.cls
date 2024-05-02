/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public with sharing class TFMDataINRemoteUtilityTest {
  @isTest
  static void testGetDataINConsentsListAPI() {
    Test.startTest();
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('recordId', Lib_FakeIdGenerator.getMockId(PersonDigitalIdentity__x.getSObjectType()));
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getDataINConsentsListAPI', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'dataINConsentList'
    );

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      1,
      ((List<Object>) payload.get('consents')).size(),
      'Should return 1 record'
    );
  }

  @isTest
  static void testGetDataINConsentsListAPIError() {
    Test.startTest();
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getDataINConsentsListAPI', args);
    Test.stopTest();
    Boolean payload = (Boolean) output.get(TFMConstants.SHOWTOAST);
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(false, payload, 'Error occurred during API call');
  }

  @isTest
  static void testGetDataINAccountListAPI() {
    Test.startTest();
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('consentIdValue', Lib_FakeIdGenerator.getMockId(PersonDigitalIdentity__x.getSObjectType()));
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getDataINAccountListAPI', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'dataINAccountList'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      3,
      ((List<Object>) payload.get('accounts')).size(),
      'Should return 3 record'
    );
  }

  @isTest
  static void testGetDataINAccountListAPIError() {
    Test.startTest();
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getDataINAccountListAPI', args);
    Test.stopTest();
    Boolean payload = (Boolean) output.get(TFMConstants.SHOWTOAST);
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(false, payload, 'Error occurred during API call');
  }

  @isTest
  static void testExportConsent() {
    Test.startTest();
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('consentId', Lib_FakeIdGenerator.getMockId(PersonDigitalIdentity__x.getSObjectType()));
    input.put('methodName', 'ExportConsentReport');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('exportConsent', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'exportResponse'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      1,
      ((List<Object>) payload.get('exportResponse')).size(),
      'Should return 1 record'
    );
  }

  @isTest
  static void testExportConsentError() {
    Test.startTest();
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('exportConsent', args);
    Test.stopTest();
    Boolean payload = (Boolean) output.get(TFMConstants.SHOWTOAST);
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(false, payload, 'Error occurred during API call');
  }

  @isTest
  static void testRevokeConsent() {
    Test.startTest();
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('consentId', 'test-48e2-4a55-8ecd-fake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('revokeConsent', args);
    Test.stopTest();
    String payload = (String) output.get('revokeResponse');
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual('STATE_REVOKED', payload, 'Consent is stopped.');
  }

  @isTest
  static void testRevokeConsentError() {
    Test.startTest();
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('revokeConsent', args);
    Test.stopTest();
    Boolean payload = (Boolean) output.get(TFMConstants.SHOWTOAST);
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(false, payload, 'Error occurred during API call');
  }

  @isTest
  static void testTransformDataScopes() {
    Test.startTest();
    TFMDataINRemoteUtility controller = new TFMDataINRemoteUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('dataScopesValue', '["bank:accounts.basic:read"]');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('transformDataScopes', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'dataScopeMap'
    );

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(1, (payload.size()), 'Should return 1 record');
  }
}
