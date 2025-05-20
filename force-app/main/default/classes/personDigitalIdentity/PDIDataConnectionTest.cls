@IsTest
private class PDIDataConnectionTest {
  static final String MOCK_TABLE = 'Passkey';
  static final String EXTERNAL_ID_1 = 'person/4b5c3dcf-c60b-442c-b614-cc8993dd2787/publicKeyCredentials/TYPE_WEB_AUTHN/ab1f23f9-681b-4ba8-a315-9dd8a1c39d4c';
  static final String EXTERNAL_ID_2 = 'person/4b5c3dcf-c60b-442c-b614-cc8993dd2787/publicKeyCredentials/TYPE_WEB_AUTHN/94283f70-a561-4f23-b9be-2f2f4e9ed827';

  static Lib_MockProvider mockRepo;
  static PDIDataConnection connection = new PDIDataConnection();
  static List<CalloutModel> mockApiRecords = new List<CalloutModel>{
    new MockCalloutModel(EXTERNAL_ID_1, 'Test1'),
    new MockCalloutModel(EXTERNAL_ID_2, 'Test2')
  };
  static List<Map<String, Object>> mockRows = new List<Map<String, Object>>{
    new Map<String, Object>{ 'ExternalId' => EXTERNAL_ID_1, 'Name' => 'Test1' },
    new Map<String, Object>{ 'ExternalId' => EXTERNAL_ID_2, 'Name' => 'Test2' }
  };
  static void registerMocks() {
    mockRepo = Lib_MockProvider.forType(PDIPasskeyDataRepository.class);
  }

  static DataSource.QueryContext queryContext {
    get {
      DataSource.QueryContext context = new DataSource.QueryContext();
      context.tableSelection = new DataSource.TableSelection();
      context.tableSelection.tableSelected = MOCK_TABLE;
      DataSource.Filter filter = new DataSource.Filter();
      filter.columnName = 'ExternalId';
      filter.type = DataSource.FilterType.EQUALS;
      filter.columnValue = '1';
      context.tableSelection.filter = filter;
      return context;
    }
  }

  static final DataSource.DeleteContext deleteContext {
    get {
      DataSource.DeleteContext context = new DataSource.DeleteContext();
      context.tableSelected = MOCK_TABLE;
      context.externalIds = new List<String>{ EXTERNAL_ID_1, EXTERNAL_ID_2 };
      return context;
    }
  }

  static List<DataSource.DeleteResult> deleteSuccessResults = new List<DataSource.DeleteResult>{
    DataSource.DeleteResult.success(EXTERNAL_ID_1),
    DataSource.DeleteResult.success(EXTERNAL_ID_2)
  };

  static List<DataSource.DeleteResult> deleteFailedResults = new List<DataSource.DeleteResult>{
    DataSource.DeleteResult.failure(EXTERNAL_ID_1, 'Error1'),
    DataSource.DeleteResult.failure(EXTERNAL_ID_2, 'Error2')
  };

  @IsTest
  static void testSync() {
    Test.startTest();
    List<DataSource.Table> tables = connection.sync();
    Test.stopTest();

    Assert.areEqual(
      0,
      tables.size(),
      'Sync should return empty list of tables'
    );
  }

  @IsTest
  static void testQuery() {
    registerMocks();
    mockRepo.mock(
      'query',
      DataSource.TableResult.get(queryContext.tableSelection, mockRows)
    );

    Test.startTest();
    DataSource.TableResult result = connection.query(queryContext);
    Test.stopTest();

    Assert.areEqual(2, result.rows.size(), 'Should return 2 records');
  }

  @IsTest
  static void testQueryWithException() {
    registerMocks();
    mockRepo.mockException('query');

    Test.startTest();
    DataSource.TableResult result = connection.query(queryContext);
    Test.stopTest();

    Assert.areEqual(0, result.rows.size(), 'Should be empty');
  }

  @IsTest
  static void testRepoTransform() {
    Test.startTest();
    List<Map<String, Object>> transformedRecords = new MockRepository()
      .transform(mockApiRecords);
    Test.stopTest();
    Assert.areEqual(
      mockRows,
      transformedRecords,
      'Transformed records should match'
    );
  }

  @IsTest
  static void testRepoQuery() {
    Test.startTest();
    DataSource.TableResult result = new MockRepository().query(queryContext);
    Test.stopTest();
    Assert.areEqual(mockRows, result.rows, 'Query records should match');
  }

  @IsTest
  static void testDeleteRows() {
    registerMocks();
    mockRepo.mock('deleteRows', deleteSuccessResults);

    Test.startTest();
    List<DataSource.DeleteResult> results = connection.deleteRows(
      deleteContext
    );
    Test.stopTest();

    Assert.isTrue(
      results.size() == 2,
      'Delete results should contain 2 records '
    );
    for (DataSource.DeleteResult result : results) {
      Assert.isTrue(
        result.success,
        String.format(
          'Delete result should be successful for {0}',
          new List<String>{ result.externalId }
        )
      );
    }
  }

  @IsTest
  static void testRepoDeleteRows() {
    registerMocks();
    mockRepo.mock('deleteRows', deleteFailedResults);
    mockRepo.mock('doDelete', null);

    Test.startTest();
    List<DataSource.DeleteResult> results = new MockRepository()
      .deleteRows(deleteContext);
    Test.stopTest();

    for (DataSource.DeleteResult result : results) {
      Assert.isTrue(
        result.success,
        String.format(
          'Delete result should be successful for {0}',
          new List<String>{ result.externalId }
        )
      );
    }
  }

  @IsTest
  static void testDeleteRowsWithException() {
    registerMocks();
    mockRepo.mock('deleteRows', deleteFailedResults);
    mockRepo.mockException('doDelete');

    Test.startTest();
    List<DataSource.DeleteResult> results = connection.deleteRows(
      deleteContext
    );
    Test.stopTest();

    Assert.isFalse(
      results[0].success,
      'Delete result should not be successful'
    );
  }

  class MockCalloutModel extends CalloutModel {
    String id;
    String name;

    MockCalloutModel(String id, String name) {
      this.id = id;
      this.name = name;
    }
  }

  // Mock repository for testing
  class MockRepository extends PDIDataConnection.DataRepositoryBase {
    override protected List<Map<String, Object>> process(
      DataSource.QueryContext context,
      List<Map<String, Object>> records
    ) {
      return records;
    }

    override protected List<CalloutModel> doQuery(
      DataSource.QueryContext context
    ) {
      return mockApiRecords;
    }

    override protected Map<String, Object> transform(CalloutModel record) {
      MockCalloutModel mockRecord = (MockCalloutModel) record;
      return new Map<String, Object>{
        'ExternalId' => mockRecord.id,
        'Name' => mockRecord.name
      };
    }
  }
}
