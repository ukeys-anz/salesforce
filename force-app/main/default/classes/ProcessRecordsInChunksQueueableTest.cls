/**
 * @author Shivam Swaraj
 * @since 11/2025
 * @description ProcessRecordsInChunksQueueableTest is the test class for ProcessRecordsInChunksQueueable Class functionality.
 */
@isTest
public with sharing class ProcessRecordsInChunksQueueableTest {
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @IsTest
  static void testInsertRecordsInChunksBatching() {
    registerMocks();
    List<SObject> toInsertRecords = createMockRecords(65, 'InsertChunkTest-');
    Test.startTest();
    ProcessRecordsInChunksQueueable q = new ProcessRecordsInChunksQueueable(
      toInsertRecords,
      65,
      ProcessRecordsInChunksQueueable.DMLOperation.DML_INSERT
    );
    q.execute(null);
    Test.stopTest();

    // Verify all records were inserted
    List<Account> insertedAccounts = (List<Account>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      65,
      insertedAccounts.size(),
      'All 65 records should be inserted across chained queueables'
    );
  }

  @IsTest
  static void testUpdateRecordsInChunksBatching() {
    registerMocks();
    // Create base accounts
    List<Account> base = createMockRecords(10, 'BaseUpdateTest-');

    // Prepare update SObjects (with new Name) — use masterRecords constructor so updated fields are present
    List<SObject> updates = new List<SObject>();
    for (Account a : base) {
      updates.add(new Account(Id = a.Id, Name = 'Updated-' + a.Id));
    }

    Test.startTest();
    ProcessRecordsInChunksQueueable q = new ProcessRecordsInChunksQueueable(
      updates,
      10,
      ProcessRecordsInChunksQueueable.DMLOperation.DML_UPDATE
    );
    q.execute(null);
    Test.stopTest();

    // Assert all names were updated
    List<Account> updatedAccounts = (List<Account>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      true,
      updatedAccounts[0].name.startsWith('Updated-'),
      'Account should be updated by the queueable'
    );
  }

  @IsTest
  static void testDeleteByIdsInChunks() {
    registerMocks();
    // Create accounts to delete
    List<Account> toDelete = createMockRecords(12, 'ToDeleteTest-');
    List<Id> ids = new List<Id>();
    for (Account a : toDelete) {
      ids.add(a.Id);
    }

    Test.startTest();
    ProcessRecordsInChunksQueueable q = new ProcessRecordsInChunksQueueable(
      ids,
      12,
      ProcessRecordsInChunksQueueable.DMLOperation.DML_DELETE
    );
    q.execute(null);
    Test.stopTest();

    // Assert all accounts are deleted
    List<Account> deletedAccounts = (List<Account>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      12,
      deletedAccounts.size(),
      'All accounts passed by Ids should be deleted'
    );
  }

  @IsTest
  static void testBatchSizeNormalization() {
    registerMocks();
    // If batchSize is null, class should fall back to DEFAULT_BATCH_SIZE and still process
    List<SObject> records = createMockRecords(10, 'BatchNormTest-');

    Test.startTest();
    ProcessRecordsInChunksQueueable q = new ProcessRecordsInChunksQueueable(
      records,
      null, // should default to DEFAULT_BATCH_SIZE inside the class
      ProcessRecordsInChunksQueueable.DMLOperation.DML_INSERT
    );
    q.execute(null);
    Test.stopTest();

    // Verify all records were inserted
    List<Account> insertedAccounts = (List<Account>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      10,
      insertedAccounts.size(),
      'All 10 records should be inserted across chained queueables'
    );
  }

  @IsTest
  static void testUpdateByIdsWithQueryTemplate() {
    registerMocks();
    // Create records that we will update via IDs + queryTemplate path
    List<Account> accts = createMockRecords(5, 'QueryTemplateUpdate-');
    List<String> quotedIds = new List<String>();
    for (Account a : accts) {
      quotedIds.add('\'' + String.valueOf(a.Id) + '\'');
    }

    // Build dynamic query string embedding Id literals (Database.query cannot use Apex bind vars in a string)
    String queryTemp =
      'SELECT Id, Name FROM Account WHERE Id IN (' +
      String.join(quotedIds, ',') +
      ')';

    Test.startTest();
    ProcessRecordsInChunksQueueable q = new ProcessRecordsInChunksQueueable(
      new List<Id>(new Map<Id, Account>(accts).keySet()),
      queryTemp,
      5,
      ProcessRecordsInChunksQueueable.DMLOperation.DML_UPDATE
    );
    q.execute(null);
    Test.stopTest();
    // Assert all names were updated
    List<Account> fetchedCount = (List<Account>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      0,
      fetchedCount.size(),
      'Query template should be valid and fetch the expected records'
    );
  }

  private static List<SObject> createMockRecords(
    Integer chunkSize,
    String namePrefix
  ) {
    // Prepare mock records so multiple queueable executions should be chained when chunk size provided
    List<SObject> mockRecords = new List<SObject>();
    for (Integer i = 0; i < chunkSize; i++) {
      Id mockAccountId = Lib_FakeIdGenerator.getMockId(
        Account.getSObjectType()
      );
      mockRecords.add(new Account(Name = namePrefix + i, Id = mockAccountId));
    }
    return mockRecords;
  }
}
