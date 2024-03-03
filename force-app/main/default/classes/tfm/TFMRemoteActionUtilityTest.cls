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
    Assert.areEqual(isInvoked, true, 'Method not invoked.');
    Assert.areNotEqual(payload, null, 'Empty JSON');
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
    Assert.areEqual(isInvoked, true, 'Method not invoked.');
    Assert.areNotEqual(payload, null, 'Empty JSON');
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
    Assert.areEqual(isInvoked, true, 'Method not invoked.');
    Assert.areNotEqual(payload, null, 'Empty JSON');
  }
}
