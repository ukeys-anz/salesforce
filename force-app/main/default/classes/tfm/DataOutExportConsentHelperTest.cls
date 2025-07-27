/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class DataOutExportConsentHelperTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider dataOutQueryMock;

  static void registerMocks() {
    dataOutQueryMock = Lib_MockProvider.forType(IDOpsQueryRepository.class);
  }

  static TFM_Data_Scopes__mdt dataScope = new TFM_Data_Scopes__mdt(
    MasterLabel = 'bank:accounts.basic:read',
    Scope_ID__c = 'bank:accounts.basic:read',
    Data_Cluster_Title__c = 'Account name, type and balance',
    Data_Cluster_Details__c = 'Name of account, Type of account, Account balance',
    Open_Accounts_Disclaimer__c = 'Only up to the last 13 months of direct debits will be shared.',
    Closed_Accounts_Disclaimer__c = 'For a closed account, direct debits and scheduled payments will not be shared.',
    Open_and_Closed_Accounts_Disclaimer__c = 'Only up to the last 13 months of direct debits will be shared.For a closed account, direct debits and scheduled payments will not be shared.'
  );

  static TFM_Data_Scopes__mdt dataScope1 = new TFM_Data_Scopes__mdt(
    MasterLabel = 'bank:accounts.basic:write',
    Scope_ID__c = 'bank:accounts.basic:write',
    Data_Cluster_Title__c = 'TobeWorkedSchemeDisputes',
    Data_Cluster_Details__c = 'Name of account',
    Open_Accounts_Disclaimer__c = faker.randomString(10),
    Closed_Accounts_Disclaimer__c = 'test',
    Open_and_Closed_Accounts_Disclaimer__c = 'CardDisputesAwaitingContact'
  );

  static List<TFM_Data_Scopes__mdt> queryMappingsMock = new List<TFM_Data_Scopes__mdt>{
    dataScope,
    dataScope1
  };

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
    obj.createTimeValue = String.valueOf(System.now());
    obj.expireTimeValue = String.valueOf(System.now() + 5);
    obj.stoppedValue = 'Stopped';
    obj.amendedValue = 'Amended';
    obj.originalCreateTimeValue = String.valueOf(System.now());
    obj.originalExpireTimeValue = String.valueOf(System.now() + 5);
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

  @IsTest
  static void testBuildCSVContent() {
    DataOutExportModel dataExportObj = getDataExportModelData();
    TFMExportConsentModel exportConsentModelObj = getTFMExportConsentModelData();
    Test.startTest();
    List<List<String>> response = DataOutExportConsentHelper.buildCSVContent(
      dataExportObj,
      exportConsentModelObj
    );
    Test.stopTest();
    Assert.areEqual(
      'Consent Data Sharing History for:',
      response[2][0],
      'csv content not generated'
    );
    Assert.isNotNull(response[0][0], 'csv content not generated');
  }

  @IsTest
  static void testBuildCSVTitle() {
    Test.startTest();
    String response = DataOutExportConsentHelper.buildCSVTitle('test');
    Test.stopTest();
    Assert.isNotNull(response, 'csv title is not generated');
  }

  @IsTest
  static void testGetReportHeader() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getReportHeader();
    Test.stopTest();
    Assert.isNotNull(response[0], 'Report header is not generated');
  }

  @IsTest
  static void testGetDataSharing() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharing();
    Test.stopTest();
    Assert.areEqual(
      'Consent Data Sharing History for:',
      response[0],
      'consent data sharing row is not correct'
    );
  }

  @IsTest
  static void testGetEmptyRow() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getEmptyRow();
    Test.stopTest();
    Assert.areEqual('', response[0], 'row is not empty');
  }

  @IsTest
  static void testGetConsentDataSharingHistory() {
    DataOutExportModel dataExportObj = getDataExportModelData();
    Test.startTest();
    TFMExportConsentModel response = DataOutExportConsentHelper.getConsentDataSharingHistory(
      dataExportObj
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      response.aggregatedEvents != null,
      'Consent history data not generated'
    );
    Assert.areEqual(
      'bank:accounts.basic:read',
      response.aggregatedEvents[0].scopes[0],
      'Consent history data not generated'
    );
  }

  @IsTest
  static void testGetAccounts() {
    DataOutExportModel dataExportObj = getDataExportModelData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getAccounts(
      dataExportObj
    );
    Test.stopTest();
    Assert.areEqual(
      'Accounts (Account Name - Account Number), Account1 (closed) - 390988244',
      response[0] + ', ' + response[1],
      'accounts row format is incorrect'
    );
  }

  @IsTest
  static void testGetBrandName() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getBrandName('test');
    Test.stopTest();
    Assert.areEqual(
      'Brand Name, test',
      response[0] + ', ' + response[1],
      'brand name is incorrect'
    );
  }

  @IsTest
  static void testGetSoftwareProduct() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getSoftwareProduct(
      'test'
    );
    Test.stopTest();
    Assert.areEqual(
      'Software Product, test',
      response[0] + ', ' + response[1],
      'software product row is incorrect'
    );
  }

  @IsTest
  static void testGetConsentStatus() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getConsentStatus(
      'STOPPED'
    );
    Test.stopTest();
    Assert.areEqual(
      'Consent Status, STOPPED',
      response[0] + ', ' + response[1],
      'status row is incorrect'
    );
  }

  @IsTest
  static void testGetCreated() {
    String createdDate = String.valueOf(System.now());
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getCreated(createdDate);
    Test.stopTest();
    Assert.isNotNull(response[1], 'Created Date not populated');
  }

  @IsTest
  static void testGetExpiration() {
    String expirationDate = String.valueOf(System.now() + 10);
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getExpiration(
      expirationDate
    );
    Test.stopTest();
    Assert.isNotNull(response[1], 'Expiry Date not populated');
  }

  @IsTest
  static void testGetStopped() {
    DataOutExportModel dataExportObj = getDataExportModelData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getStopped(
      dataExportObj
    );
    Test.stopTest();
    Assert.areEqual(
      'Stopped, Stopped',
      response[0] + ', ' + response[1],
      'status row is incorrect'
    );
  }

  @IsTest
  static void testGetAmended() {
    DataOutExportModel dataExportObj = getDataExportModelData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getAmended(
      dataExportObj
    );
    Test.stopTest();
    Assert.areEqual(
      'Amended, N/A',
      response[0] + ', ' + response[1],
      'amended status row not generated'
    );
  }

  @IsTest
  static void testGetHasJointAccount() {
    List<TFMExportConsentModel.AccountInfo> accountListData = getAccountListData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getHasJointAccount(
      accountListData
    );
    Test.stopTest();
    Assert.areEqual(
      'Consent Has Joint Accounts?, No',
      response[0] + ', ' + response[1],
      'consent has joint accounts'
    );
  }

  @IsTest
  static void testGetDataClusterTitle() {
    List<String> dataScopesValue = new List<String>();
    dataScopesValue.add('bank:accounts.basic:read');
    dataScopesValue.add('bank:accounts.basic:write');
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataClusterTitle(
      dataScopesValue
    );
    Test.stopTest();
    Assert.areEqual(
      'Data Requested - Cluster Title, "Account name, type and balance"',
      response[0] + ', ' + response[1],
      'cluster title row is incorrect'
    );
  }

  @IsTest
  static void testGetDataClusterDetails() {
    List<String> dataScopesValue = new List<String>();
    dataScopesValue.add('bank:accounts.basic:read');
    dataScopesValue.add('bank:accounts.basic:write');
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataClusterDetails(
      dataScopesValue
    );
    Test.stopTest();
    Assert.areEqual(
      'Data Requested - Details, "Name of account, Type of account, Account balance"',
      response[0] + ', ' + response[1],
      'cluster details row is incorrect'
    );
  }

  @IsTest
  static void testAllAccountsAreClosed() {
    List<TFMExportConsentModel.AccountInfo> accountListData = getAccountListData();
    Test.startTest();
    Boolean response = DataOutExportConsentHelper.allAccountsAreClosed(
      accountListData
    );
    Test.stopTest();
    Assert.areEqual(true, response, 'all accounts are not closed');
  }

  @IsTest
  static void testAllAccountsAreOpen() {
    List<TFMExportConsentModel.AccountInfo> accountListData = getAccountListData();
    Test.startTest();
    Boolean response = DataOutExportConsentHelper.allAccountsAreOpen(
      accountListData
    );
    Test.stopTest();
    Assert.areEqual(false, response, 'all or some accounts are opened');
  }

  @IsTest
  static void testGetDisclaimer() {
    DataOutExportModel dataOutExportModelObj = getDataExportModelData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDisclaimer(
      dataOutExportModelObj
    );
    Test.stopTest();
    Assert.areEqual(
      'Disclaimers, ""',
      response[0] + ', ' + response[1],
      'disclaimer details row not generated'
    );
  }

  @IsTest
  static void testGetDataSharingHistoryTitle() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharingHistoryTitle();
    Test.stopTest();
    Assert.areEqual(
      'Data Sharing History',
      response[0],
      'data sharing history is incorrect'
    );
  }

  @IsTest
  static void testGetDataSharingHistoryHeaders() {
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharingHistoryHeaders();
    Test.stopTest();
    Assert.areEqual('Account', response[0], 'data sharing header is incorrect');
    Assert.areEqual(
      'Sharing Date',
      response[1],
      'data sharing header is incorrect'
    );
  }

  @IsTest
  static void testGetDataSharingHistory() {
    TFMExportConsentModel exportConsentModelObj = getTFMExportConsentModelData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharingHistory(
      exportConsentModelObj
    );
    Test.stopTest();
    Assert.areEqual(
      '11111-1111111 | 11121-19876111 | 09871-234534',
      response[0],
      'data sharing history row header value is incorrect'
    );
  }

  @IsTest
  static void testGetDataSharingHistoryDisclaimers() {
    TFMExportConsentModel exportConsentModelObj = getTFMExportConsentModelData();
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharingHistoryDisclaimers(
      exportConsentModelObj
    );
    Test.stopTest();
    Assert.areEqual(
      'Disclaimers, ~All data sharing history information is based on GMT',
      response[0] + ', ' + response[1],
      'data sharing history details row not generated'
    );
  }

  @IsTest
  static void testGetDataSharingTitles() {
    List<String> dataScopesValue = new List<String>();
    dataScopesValue.add('bank:accounts.basic:read');
    dataScopesValue.add('bank:accounts.basic:write');
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharingTitles(
      dataScopesValue
    );
    Test.stopTest();
    Assert.areEqual(
      'Account name, type and balance',
      response[0],
      'data sharing titles details row not generated'
    );
  }

  @IsTest
  static void testGetDataSharingDetails() {
    List<String> dataScopesValue = new List<String>();
    dataScopesValue.add('bank:accounts.basic:read');
    dataScopesValue.add('bank:accounts.basic:write');
    Test.startTest();
    List<String> response = DataOutExportConsentHelper.getDataSharingDetails(
      dataScopesValue
    );
    Test.stopTest();
    Assert.areEqual(
      'Name of account, Type of account, Account balance',
      response[0],
      'data sharing details row not generated'
    );
  }
}
