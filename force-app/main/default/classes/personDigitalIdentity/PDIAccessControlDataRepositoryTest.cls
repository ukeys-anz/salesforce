/**
 * @description Test class for {@link PDIAccessControlDataRepository}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@IsTest
private class PDIAccessControlDataRepositoryTest {
  static PDIAccessControlDataRepository repo {
    get {
      return new PDIAccessControlDataRepository();
    }
  }

  static Lib_MockProvider mockQuery;
  static Lib_MockProvider mockApi;
  static Lib_MockProvider mockUser;

  static void registerMock() {
    mockQuery = Lib_MockProvider.forType(PDIRepository.class);
    mockApi = Lib_MockProvider.forType(PDIApiRepository.class);
    mockUser = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  @IsTest
  static void testDoQuery() {
    registerMock();

    DataSource.Filter filter = new DataSource.Filter();
    DataSource.Filter subFilter = new DataSource.Filter();
    subFilter.columnName = 'PersonId';
    subFilter.columnValue = '12345-abcde-67890';
    filter.subfilters = new List<DataSource.Filter>{ subFilter };
    DataSource.TableSelection tableSelection = new DataSource.TableSelection();
    tableSelection.filter = filter;
    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = tableSelection;

    mockApi.mock(
      'getAccessControls',
      new List<PDIApiModel.AccessControl>{ apiRecord }
    );

    Test.startTest();
    repo.doQuery(context);
    Test.stopTest();

    String inputUuid = (String) mockApi.getHistory('getAccessControls')
      ?.getParam('customerUuid');
    Assert.areEqual(
      subFilter.columnValue,
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  @IsTest
  static void testDoDelete() {
    registerMock();
    mockQuery.mock('getAccessControlByExternalId', new AccessControl__x());

    Test.startTest();
    repo.doDelete(apiRecord.name);
    Test.stopTest();

    String inputUuid = (String) mockApi.getHistory('deleteAccessControl')
      ?.getParam('customerUuid');
    Assert.areEqual(
      '4b5c3dcf-c60b-442c-b614-cc8993dd2787',
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  @IsTest
  static void testDoDeleteRecordNotFound() {
    registerMock();

    Test.startTest();
    repo.doDelete(apiRecord.name);
    Test.stopTest();

    Assert.isTrue(
      mockApi.getHistories('deleteAccessControl').isEmpty(),
      'Should not invoke deleteAccessControl'
    );
  }

  @IsTest
  static void testDoUpsert() {
    registerMock();
    mockApi.mock('createAccessControl', apiRecord);

    Map<String, Object> row = new Map<String, Object>{
      'PersonId' => '4b5c3dcf-c60b-442c-b614-cc8993dd2787',
      'Policy' => apiRecord.policy
    };

    Test.startTest();
    repo.doUpsert(row);
    Test.stopTest();

    String inputUuid = (String) mockApi.getHistory('createAccessControl')
      ?.getParam('customerUuid');
    Assert.areEqual(
      '4b5c3dcf-c60b-442c-b614-cc8993dd2787',
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  @IsTest
  static void testTransformList() {
    registerMock();
    mockQuery.mock(
      'getDevicesByPersonId',
      new List<Device__x>{
        new Device__x(
          ExternalId = 'd12345',
          DeviceCorrelationId__c = 'device-12345'
        )
      }
    );
    Test.startTest();
    List<Map<String, Object>> result = repo.transform(
      new List<CalloutModel>{ apiRecord }
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Should yield 1 result');
    Assert.areEqual(
      'd12345',
      result[0].get('Device'),
      'Should map to the correct Device'
    );
  }

  @IsTest
  static void testTransformEmptyList() {
    List<Map<String, Object>> result = repo.transform(
      new List<CalloutModel>{ null }
    );
    Assert.areEqual(0, result.size(), 'Should yield no results');
  }

  @IsTest
  static void testTransformAccessControl() {
    Test.startTest();
    Map<String, Object> result = repo.transform(apiRecord);
    Test.stopTest();

    Assert.isNotNull(result, 'Should return a non-null result');
    Assert.areEqual(
      'Web Banking',
      result.get('Channel'),
      'Should return the correct Channel'
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

  @IsTest
  static void testLinkDevices() {
    List<Map<String, Object>> mappedRecords = new List<Map<String, Object>>{
      new Map<String, Object>(),
      new Map<String, Object>{ 'DeviceCorrelationId' => 'dcid-1' },
      new Map<String, Object>{ 'DeviceCorrelationId' => 'dcid-2' }
    };
    List<Device__x> devices = new List<Device__x>{
      new Device__x(ExternalId = 'd1', DeviceCorrelationId__c = 'dcid-1')
    };

    PDIAccessControlDataRepository.linkDevices(mappedRecords, devices);

    Assert.isNull(
      mappedRecords[0].get('Device'),
      'Should not link device for record without DeviceCorrelationId'
    );
    Assert.areEqual(
      'd1',
      mappedRecords[1].get('Device'),
      'Should link the device correctly'
    );
    Assert.isNull(
      mappedRecords[2].get('Device'),
      'Should not link device for record with no matching DeviceCorrelationId'
    );
  }

  @IsTest
  static void testIsDeviceLinkingRequired() {
    List<Map<String, Object>> recordsWithDevice = new List<Map<String, Object>>{
      new Map<String, Object>{ 'DeviceCorrelationId' => 'dcid-1' }
    };
    List<Map<String, Object>> recordsNoDevice = new List<Map<String, Object>>{
      new Map<String, Object>()
    };

    Assert.isTrue(
      PDIAccessControlDataRepository.isDeviceLinkingRequired(recordsWithDevice),
      'Should require device linking for records with DeviceCorrelationId'
    );
    Assert.isFalse(
      PDIAccessControlDataRepository.isDeviceLinkingRequired(recordsNoDevice),
      'Should not require device linking for records without DeviceCorrelationId'
    );
  }

  @IsTest
  static void testCanDelete() {
    registerMock();

    Assert.isFalse(
      PDIAccessControlDataRepository.canDelete(null),
      'Should return false when record is null'
    );

    AccessControl__x recordWithoutDevice = new AccessControl__x();
    Assert.isTrue(
      PDIAccessControlDataRepository.canDelete(recordWithoutDevice),
      'Should return true when record has no DeviceCorrelationId'
    );

    AccessControl__x recordWithDevice = new AccessControl__x(
      DeviceCorrelationId__c = 'device-12345'
    );

    mockUser.mock('checkRole', true);
    Assert.isTrue(
      PDIAccessControlDataRepository.canDelete(recordWithDevice),
      'Should return true when record has DeviceCorrelationId and user has permission'
    );

    mockUser.mock('checkRole', false);
    Exception ex;
    try {
      PDIAccessControlDataRepository.canDelete(recordWithDevice);
    } catch (RepositoryBase.InsufficientAccessException e) {
      ex = e;
    }
    Assert.isNotNull(
      ex,
      'Should throw an exception when user lacks permissions'
    );
  }

  static PDIApiModel.AccessControl apiRecord {
    get {
      if (apiRecord != null) {
        return apiRecord;
      }
      PDIApiModel.AccessControl apiRecord = new PDIApiModel.AccessControl();
      apiRecord.name = 'person/4b5c3dcf-c60b-442c-b614-cc8993dd2787/AccessControl/QTAzX0q_OhJqi5BAebp0L3A3Tg';
      apiRecord.match = new PDIApiModel.AccessControlMatchCriteria();
      apiRecord.match.authChannel = 'EDGE_AUTH_CHANNEL_COMPANION';
      apiRecord.match.deviceCorrelationId = 'device-12345';
      apiRecord.match.personaId = 'b39ea11b-d5f7-43cf-978b-cb0525477aca';
      apiRecord.policy = 'Conditional';
      apiRecord.conditionalAdvice = new PDIApiModel.AccessControlConditionalAdvice();
      apiRecord.conditionalAdvice.deleteWhenMet = false;
      apiRecord.conditionalAdvice.minimumAal = 'AUTHENTICATION_ASSURANCE_LEVEL_4';
      apiRecord.createdBy = 'Fraudx Agent';
      apiRecord.createdAt = Datetime.valueOf('2023-10-01 00:00:00');
      return apiRecord;
    }
    set;
  }

  class InvalidModel extends CalloutModel {
  }
}
