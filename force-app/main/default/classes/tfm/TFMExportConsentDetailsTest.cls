/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
private class TFMExportConsentDetailsTest {
  static List<TFMExportConsentModel.AccountInfo> getAccountListData() {
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
    return accountInfoList;
  }

  static DataOutExportModel getDataExportModelData() {
    List<String> dataScopesValue = new List<String>();
    dataScopesValue.add('bank:accounts.basic:read');
    dataScopesValue.add('bank:accounts.basic:write');

    DataOutExportModel obj = new DataOutExportModel();
    obj.consentIdValue = '123-456';
    obj.IDValue = '987-123';
    obj.accountsValue = getAccountListData();
    obj.brandNameValue = 'test';
    obj.statusValue = 'STOPPED';
    obj.clientNameValue = 'testClient';
    obj.createTimeValue = String.valueOf(system.now());
    obj.expireTimeValue = String.valueOf(system.now() + 5);
    obj.stoppedValue = 'Stopped';
    obj.amendedValue = 'Amended';
    obj.originalCreateTimeValue = String.valueOf(system.now());
    obj.originalExpireTimeValue = String.valueOf(system.now() + 5);
    obj.dataScopesValue = dataScopesValue;
    return obj;
  }
  
   static List<TFMExportConsentModel.AggregatedEvent> getAggregatedEventListData() {
    List<TFMExportConsentModel.AggregatedEvent> aggregatedEventList = new List<TFMExportConsentModel.AggregatedEvent>();
    List<String> accounts = new List<String>{
      '11111-1111111',
      '11121-19876111',
      '09871-234534'
    };
    List<String> scopes = new List<String>{ 'bank:accounts.basic:read' };
    List<String> requestTypes = new List<String>{
      'getAccountData',
      'getTest1',
      'getTest2'
    };
    List<String> userInfoDisclosed = new List<String>{
      'disclosedTest1',
      'getDisTest1',
      'getDisTest2'
    };

    TFMExportConsentModel.ValueWrapper dayObj = new TFMExportConsentModel.ValueWrapper();
    dayObj.value = 4;

    TFMExportConsentModel.ValueWrapper monthObj = new TFMExportConsentModel.ValueWrapper();
    dayObj.value = 5;

    TFMExportConsentModel.ValueWrapper yearObj = new TFMExportConsentModel.ValueWrapper();
    dayObj.value = 1998;

    TFMExportConsentModel.DateInfo dateInfoObj = new TFMExportConsentModel.DateInfo();
    dateInfoObj.day = dayObj;
    dateInfoObj.month = monthObj;
    dateInfoObj.year = yearObj;

    TFMExportConsentModel.AggregatedEvent aggregatedEvent = new TFMExportConsentModel.AggregatedEvent();
    aggregatedEvent.transactionDate = dateInfoObj;
    aggregatedEvent.accounts = accounts;
    aggregatedEvent.scopes = scopes;
    aggregatedEvent.requestTypes = requestTypes;
    aggregatedEvent.userInfoDisclosed = userInfoDisclosed;
    aggregatedEventList.add(aggregatedEvent);
    return aggregatedEventList;
  }

  static TFMExportConsentModel getTFMExportConsentModelData() {
    TFMExportConsentModel obj = new TFMExportConsentModel();
    obj.queryTime = '5';
    obj.aggregatedEvents = getAggregatedEventListData();
    obj.nextPageToken = 'test';
    return obj;
  }

  @isTest
  static void testExportToCSV1() {
    List<TFMExportConsentModel.AccountInfo> accountInfoList = getAccountListData();
    List<String> dataScopesValue = new List<String>();
    dataScopesValue.add('bank:accounts.basic:read');
    dataScopesValue.add('bank:accounts.basic:write');
    Map<String, Object> input = new Map<String, Object>{
      'dataScopesValue' => dataScopesValue,
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
    Map<String, Object> args = new Map<String, Object>();
    args.put('input', input);
    args.put('output', output);
    args.put('options', options);
    TFMExportConsentDetails exp = new TFMExportConsentDetails();
    exp.call('exportToCSV', args);

    Test.stopTest();
    Assert.areEqual(
      'yes',
      output.get('showToast'),
      'csv generated successfully'
    );
    Assert.areEqual(true, output.get('isValid'), 'csv generated successfully');
  }

  @isTest
  static void testExportToCSV2() {
    DataOutExportModel dataOutExportModelObj = getDataExportModelData();
    Test.startTest();
    Map<String, Object> response = TFMExportConsentDetails.exportToCSV(
      dataOutExportModelObj
    );
    Test.stopTest();
    Assert.areEqual(
      'yes',
      response.get('showToast'),
      'csv generated successfully'
    );
    Assert.areEqual(
      true,
      response.get('isValid'),
      'csv generated successfully'
    );
  }
  
   @isTest
  static void testbuildCSV() {
    DataOutExportModel dataOutExportModelObj = getDataExportModelData();
    TFMExportConsentModel exportConsentModelObj = getTFMExportConsentModelData();
    Test.startTest();
    String response = TFMExportConsentDetails.buildCSV(
      dataOutExportModelObj,
      exportConsentModelObj
    );
    Test.stopTest();
    Assert.areEqual(
          true,
          String.isNotBlank(response),
          'csv generated successfully'
        );  
  }

  @isTest
  static void testExportToCSVException() {
    DataOutExportModel dataOutExportModelObj = getDataExportModelData();
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Map<String, Object> response = TFMExportConsentDetails.exportToCSV(
      dataOutExportModelObj
    );
    Test.stopTest();
    Assert.areEqual('yes', response.get('showToast'), 'Server error expexted');
    Assert.areEqual(true, response.get('isValid'), 'Server error expexted');
  }

  @isTest
  static void testExportToCSVInsufficentAccessException() {
    DataOutExportModel dataOutExportModelObj = getDataExportModelData();
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponseForInsufficentAccess();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Map<String, Object> response = TFMExportConsentDetails.exportToCSV(
      dataOutExportModelObj
    );
    Test.stopTest();
    Assert.areEqual(
      false,
      response.get('isValid'),
      'Insufficent access error expected'
    );
  }
}