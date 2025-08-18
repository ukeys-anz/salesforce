/**
 * @description Test class for {@link PDIAccessControlDataRepository}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@IsTest
private class PDIAccessControlDataRepositoryTest {
  static PDIAccessControlDataRepository repo = new PDIAccessControlDataRepository();

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
        'getAccessControls',
        new List<PDIApiModel.AccessControl>{ apiRecord }
      );

    Test.startTest();
    repo.doQuery(context);
    Test.stopTest();

    String inputUuid = (String) mockRepo.getHistory('getAccessControls')
      ?.getParam('customerUuid');
    Assert.areEqual(
      filter.columnValue,
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  static void testDoDelete() {
    Lib_MockProvider mockRepo = Lib_MockProvider.forType(
      PDIApiRepository.class
    );

    Test.startTest();
    repo.doDelete(apiRecord.name);
    Test.stopTest();

    String inputUuid = (String) mockRepo.getHistory('deleteAccessControl')
      ?.getParam('customerUuid');
    Assert.areEqual(
      '4b5c3dcf-c60b-442c-b614-cc8993dd2787',
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  static void testDoUpsert() {
    Lib_MockProvider mockRepo = Lib_MockProvider.forType(PDIApiRepository.class)
      .mock('createAccessControl', apiRecord);
    Map<String, Object> row = (Map<String, Object>) JSON.deserializeUnTyped(
      JSON.serialize(apiRecord)
    );

    Test.startTest();
    repo.doUpsert(row);
    Test.stopTest();

    String inputUuid = (String) mockRepo.getHistory('createAccessControl')
      ?.getParam('customerUuid');
    Assert.areEqual(
      '4b5c3dcf-c60b-442c-b614-cc8993dd2787',
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  @IsTest
  static void testTransformAccessControl() {
    Test.startTest();
    Map<String, Object> result = repo.transform(apiRecord);
    Test.stopTest();

    Assert.isNotNull(result, 'Should return a non-null result');
    Assert.areEqual(
      'EDGE_AUTH_CHANNEL_COMPANION',
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
      apiRecord.policy = 'POLICY_CONDITIONAL';
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
