@isTest
public with sharing class TFMRemoteActionUtilityTest {
  @isTest
  static void testGetJointAccountPermissions() {
    Test.startTest();
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('recordId', 'x00Bm000008L9jfake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getJointAccountPermissionsList', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'getJointAccountPermissions'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      3,
      ((List<Object>) payload.get('disclosureStates')).size(),
      'Should return 3 record'
    );
  }

  @isTest
  static void testupdatedisclosureStatus() {
    Test.startTest();
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    Map<String, Object> input = new Map<String, Object>();
    input.put('accountNumber', '000011 000000011');
    Map<String, Object> output = new Map<String, Object>();
    input.put('recordId', 'x00Bm000008L9jfake');
    input.put('enabled', 'true');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('updatedisclosureStatus', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'responseMap'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      5,
      ((Map<String, Object>) payload.get('disclosureState')).size(),
      'Should return 5 record'
    );
  }

  @isTest
  static void testgetORModifyJointAccountNotificationAPI() {
    Test.startTest();
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    Map<String, Object> input = new Map<String, Object>();
    input.put('account_id', 'testst');
    input.put('email_enabled', true);
    Map<String, Object> output = new Map<String, Object>();
    input.put('recordId', 'x00Bm000008L9jfake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call(
      'getORModifyJointAccountNotificationAPI',
      args
    );
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'jointAccNotifications'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      2,
      ((List<Object>) payload.get('jointAccountNotificationSettings')).size(),
      'Should return 2 record'
    );
  }

  @isTest
  static void testgetConsentAccountList() {
    Test.startTest();
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('dataScope', '["bank:accounts.basic:read"]');
    input.put('consentId', 'x00Bm000008L9jfake');
    String jsonData =
      '[' +
      '{' +
      '"bsb": "014111",' +
      '"accountNumber": "391077004",' +
      '"displayName": "ANZ Plus",' +
      '"state": "STATE_ELIGIBLE"' +
      '},' +
      '{' +
      '"bsb": "014111",' +
      '"accountNumber": "391077012",' +
      '"displayName": "ANZ Save",' +
      '"state": "STATE_ELIGIBLE"' +
      '}' +
      ']';
    input.put('accounts', jsonData);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getConsentAccountList', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'consentAccountList'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      4,
      ((List<Object>) payload.get('consentAccDetails')).size(),
      'Should return 4 record'
    );
  }

  @isTest
  static void testrevokeConsents() {
    Test.startTest();
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('arrangementId', 'x00Bm000008L9jfake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('revokeConsent', args);
    Test.stopTest();

    String payload = (String) output.get('result');
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areNotEqual(null, payload, 'Consent is revoked successfully');
  }

  @isTest
  static void testgetConsentsList() {
    Test.startTest();
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();

    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getConsentsList', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      'consentsList'
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(
      1,
      ((List<Object>) payload.get('consents')).size(),
      'Should return 1 record'
    );
  }

  @isTest
  public static void testgetConsentDataSharingHistory() {
    Test.startTest();

    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> args = new Map<String, Object>{ 'input' => input };
    Map<String, Object> payload = TFMRemoteActionUtility.getConsentDataSharingHistory(
      input
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      ((List<Object>) payload.get('aggregatedEvents')).size(),
      'Should return 1 record'
    );
  }
}
