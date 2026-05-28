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
  static void testGetJointAccountPermissionsException() {
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
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
    Assert.areEqual(false, isInvoked, 'Method invoked.');
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
  static void testupdatedisclosureStatusException() {
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
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
    Assert.areEqual(false, isInvoked, 'Method not invoked.');
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
  static void testgetORModifyJointAccountNotificationAPIException() {
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
    Test.startTest();
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
    Boolean payload = (Boolean) output.get('showSuccessToast');
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(false, payload, 'Should return atleast 1 record');
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
    Assert.isFalse(
      ((List<Object>) payload.get('consentAccounts')).isEmpty(),
      'Should return records'
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
  static void testrevokeConsentsException() {
    TFMRemoteActionUtility controller = new TFMRemoteActionUtility();
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
    Test.startTest();
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

    Boolean payload = (Boolean) output.get('showSuccessToast');
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(false, payload, 'Consent is revoked successfully');
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
    Assert.isFalse(
      ((List<Object>) payload.get('consents')).isEmpty(),
      'Should return records'
    );
  }

  @isTest
  static void testgetConsentsListException() {
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
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
    Assert.areEqual(false, isInvoked, 'Should return 4 records');
  }

  @isTest
  public static void testInvokeMethodException() {
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
    Object isInvoked = controller.call('test', args);
    Test.stopTest();
    Assert.areEqual(false, isInvoked, 'Method invoked.');
  }

  @isTest
  static void testGetTransactionDisclaimerRout() {
    Test.startTest();
    Boolean isInvoked = (Boolean) new TFMRemoteActionUtility()
      .call(
        'getTransactionDisclaimer',
        new Map<String, Object>{
          'input' => new Map<String, Object>(),
          'output' => new Map<String, Object>(),
          'options' => new Map<String, Object>()
        }
      );
    Test.stopTest();

    Assert.isTrue(isInvoked, 'Method not invoked.');
  }

  @isTest
  static void testGetTransactionDisclaimer2yActive() {
    TFMRemoteActionUtility util = new TFMRemoteActionUtility();
    Map<String, Object> output = new Map<String, Object>();

    Test.startTest();
    util.getTransactionDisclaimer(
      new Map<String, Object>{
        'transactionSharingDurationYears' => '2',
        'allAccStatus' => 'Open',
        'state' => 'ACTIVE'
      },
      output,
      null
    );
    Assert.areEqual(
      'This may have included transaction data that dates back up to 2 years.',
      output.get('transactionDisclaimer'),
      'Disclaimer did not match expected value for 2 year active arrangement.'
    );

    util.getTransactionDisclaimer(
      new Map<String, Object>{
        'transactionSharingDurationYears' => '2',
        'allAccStatus' => 'Hybrid',
        'state' => 'ACTIVE'
      },
      output,
      null
    );
    Assert.areEqual(
      'For open accounts, this may have included transaction data that dates back up to 2 years.',
      output.get('transactionDisclaimer'),
      'Disclaimer did not match expected value for 2 year active arrangement with mix open/closed accounts.'
    );
    Test.stopTest();
  }

  @isTest
  static void testGetTransactionDisclaimer2yArchived() {
    TFMRemoteActionUtility util = new TFMRemoteActionUtility();
    Map<String, Object> output = new Map<String, Object>();

    Test.startTest();
    util.getTransactionDisclaimer(
      new Map<String, Object>{
        'transactionSharingDurationYears' => '2',
        'allAccStatus' => 'Open',
        'state' => 'STOPPED'
      },
      output,
      null
    );
    Assert.areEqual(
      'This may have included transaction data that dates back up to 2 years prior to the ending of the arrangement.',
      output.get('transactionDisclaimer'),
      'Disclaimer did not match expected value for 2 year stopped arrangement.'
    );

    util.getTransactionDisclaimer(
      new Map<String, Object>{
        'transactionSharingDurationYears' => '2',
        'allAccStatus' => 'Hybrid',
        'state' => 'STOPPED'
      },
      output,
      null
    );
    Assert.areEqual(
      'For open accounts, this may have included transaction data that dates back up to 2 years prior to the ending of the arrangement.',
      output.get('transactionDisclaimer'),
      'Disclaimer did not match expected value for 2 year stopped arrangement with mix open/closed accounts.'
    );
    Test.stopTest();
  }

  @isTest
  static void testGetTransactionDisclaimer7y() {
    TFMRemoteActionUtility util = new TFMRemoteActionUtility();
    Map<String, Object> output = new Map<String, Object>();

    Test.startTest();
    util.getTransactionDisclaimer(
      new Map<String, Object>{
        'transactionSharingDurationYears' => '7',
        'allAccStatus' => 'Open',
        'state' => 'ACTIVE'
      },
      output,
      null
    );
    Assert.areEqual(
      'For an open account, this may include historical transaction data that dates back up to 7 years.',
      output.get('transactionDisclaimer'),
      'Disclaimer did not match expected value for 7 year active arrangement with open accounts.'
    );

    util.getTransactionDisclaimer(
      new Map<String, Object>{
        'transactionSharingDurationYears' => '7',
        'allAccStatus' => 'Hybrid',
        'state' => 'ACTIVE'
      },
      output,
      null
    );
    Assert.isTrue(
      String.valueOf(output.get('transactionDisclaimer'))
        .endsWith(
          'For a closed account, this may include historical transaction data that dates back up to 12 months prior to closure.'
        ),
      'Disclaimer did not match expected value for 7 year active arrangement with mix open/closed accounts.'
    );
    Test.stopTest();
  }

  @isTest
  static void testGetTransactionDisclaimerEdgeCases() {
    Map<String, Object> output = new Map<String, Object>();
    new TFMRemoteActionUtility()
      .getTransactionDisclaimer(
        new Map<String, Object>{
          'transactionSharingDurationYears' => '7',
          'allAccStatus' => 'Closed',
          'state' => 'ACTIVE'
        },
        output,
        null
      );
    Assert.isFalse(
      output.containsKey('transactionDisclaimer'),
      'Disclaimer should not be present for closed accounts.'
    );
  }

  @isTest
  public static void testgetTransformedDataScopes() {
    Test.startTest();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('dataScope', '["bank:accounts.basic:read"]');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    TFMRemoteActionUtility util = new TFMRemoteActionUtility();
    Object isInvoked = util.call('getTransformedDataScopes', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get('dataScope');
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areNotEqual(0, payload.size(), 'Datascope value is null');
  }
}
