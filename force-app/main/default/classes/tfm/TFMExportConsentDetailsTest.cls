@isTest
private class TFMExportConsentDetailsTest {
  @isTest
  static void testExportToCSV1() {
    List<TFMExportConsentModel.AccountInfo> accountInfoList = new List<TFMExportConsentModel.AccountInfo>();
    TFMExportConsentModel.AccountInfo accountInfo = new TFMExportConsentModel.AccountInfo(
      '390988244',
      '390988244',
      'Closed',
      'Joint',
      '390988244'
    );
    accountInfo.accountNumber = '390988244';
    accountInfo.sharingStatus = '014111';
    accountInfo.accountType = 'Joint';
    accountInfo.accountName = 'Account1';
    accountInfo.accountStatus = 'Closed';
    accountInfoList.add(accountInfo);

    Map<String, Object> input = new Map<String, Object>{
      'dataScopesValue' => '(bank:accounts.detail:read, bank:payees:read)',
      'accountsValue' => accountInfoList,
      'brandNameValue' => 'BrandName',
      'registeredSoftwareProductValue' => 'SoftwareProduct',
      'clientNameValue' => 'ClientName',
      'statusValue' => 'Active',
      'createTimeValue' => '2024-01-10T12:00:00Z',
      'expireTimeValue' => '2025-01-10T12:00:00Z',
      'stoppedValue' => '2024-05-10T12:00:00Z',
      'amendedValue' => '2024-02-10T12:00:00Z'
    };

    Map<String, Object> output = new Map<String, Object>();

    Map<String, Object> options = new Map<String, Object>();

    
    Test.startTest();

    TFMExportConsentDetails.exportToCSV(input, output, options);

    Map<String, Object> args = new Map<String, Object>();
    args.put('input', input);
    args.put('output', output);
    args.put('options', options);
    TFMExportConsentDetails exp = new TFMExportConsentDetails();
    exp.call('exportToCSV', args);

    Test.stopTest();
    Assert.areNotEqual(null, output.get('blobContent'));
    Assert.areEqual('yes', output.get('showToast'));
  }

  @isTest
  static void testExportToCSV2() {
    Map<String, Object> input = new Map<String, Object>{
      'dataScopesValue' => '(bank:accounts.detail:read, bank:payees:read)',
      'accountsValue' => '',
      'brandNameValue' => 'BrandName',
      'registeredSoftwareProductValue' => 'SoftwareProduct',
      'clientNameValue' => 'ClientName',
      'statusValue' => 'Active',
      'createTimeValue' => '2024-01-10T12:00:00Z',
      'expireTimeValue' => '2025-01-10T12:00:00Z',
      'stoppedValue' => '2024-05-10T12:00:00Z',
      'amendedValue' => '2024-02-10T12:00:00Z'
    };

    Map<String, Object> output = new Map<String, Object>();

    Map<String, Object> options = new Map<String, Object>();

    
    // Start the test
    Test.startTest();

    TFMExportConsentDetails.exportToCSV(input, output, options);

    Map<String, Object> args = new Map<String, Object>();
    args.put('input', input);
    args.put('output', output);
    args.put('options', options);
    TFMExportConsentDetails exp = new TFMExportConsentDetails();
    exp.call('exportToCSV', args);
    // Stop the test
    Test.stopTest();

    Assert.areEqual('error', output.get('showToast'));
  }

  @isTest
  static void testExportToCSV3() {
    List<TFMExportConsentModel.AccountInfo> accountInfoList = new List<TFMExportConsentModel.AccountInfo>();
    TFMExportConsentModel.AccountInfo accountInfo = new TFMExportConsentModel.AccountInfo(
      '390988244',
      '390988244',
      'Open',
      'Single',
      '390988244'
    );
    accountInfo.accountNumber = '390988244';
    accountInfo.sharingStatus = '014111';
    accountInfo.accountType = 'Single';
    accountInfo.accountName = 'Account1';
    accountInfo.accountStatus = 'Open';
    accountInfoList.add(accountInfo);

    Map<String, Object> input = new Map<String, Object>{
      'dataScopesValue' => '(bank:accounts.detail:read, bank:payees:read)',
      'accountsValue' => accountInfoList,
      'brandNameValue' => 'BrandName',
      'registeredSoftwareProductValue' => 'SoftwareProduct',
      'clientNameValue' => 'ClientName',
      'statusValue' => 'Active',
      'createTimeValue' => '2024-01-10T12:00:00Z',
      'expireTimeValue' => '2025-01-10T12:00:00Z',
      'stoppedValue' => '2024-05-10T12:00:00Z',
      'amendedValue' => '2024-02-10T12:00:00Z'
    };

    Map<String, Object> output = new Map<String, Object>();

    Map<String, Object> options = new Map<String, Object>();

  
    Test.startTest();

    TFMExportConsentDetails.exportToCSV(input, output, options);

    Map<String, Object> args = new Map<String, Object>();
    args.put('input', input);
    args.put('output', output);
    args.put('options', options);
    TFMExportConsentDetails exp = new TFMExportConsentDetails();
    exp.call('exportToCSV', args);

    Test.stopTest();
    Assert.areNotEqual(null, output.get('blobContent'));
    Assert.areEqual('yes', output.get('showToast'));
  }
}
