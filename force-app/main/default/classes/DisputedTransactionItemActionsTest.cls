/**
 * @author Karen Valeriano
 * @since August 2025
 * @description tests for {@link DisputedTransactionItemActions}
 */
@isTest
private class DisputedTransactionItemActionsTest {
  static Lib_MockProvider repoMock;
  static Lib_MockProvider dmlRepoMock;
  static final Faker FAKER = new Faker('en-AU');
  static Case theCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.recipientMule
  );
  static Dispute disputeRec = new Dispute(
    Id = Lib_FakeIdGenerator.getMockId(Dispute.SObjectType),
    RecordTypeId = RTDispute.disputedTransaction,
    ReceivedDate = Date.today(),
    CaseId = theCase.Id
  );
  static DisputeItem disputeItemRec = new DisputeItem(
    Id = Lib_FakeIdGenerator.getMockId(DisputeItem.SObjectType),
    RecordTypeId = RTDisputeItem.disputedTransaction,
    TransactionIdentifier = FAKER.randomString(10),
    DisputeId = disputeRec.Id,
    Case__c = theCase.Id
  );
  static DisputeItem disputeItemRec2 = new DisputeItem(
    Id = Lib_FakeIdGenerator.getMockId(DisputeItem.SObjectType),
    RecordTypeId = RTDisputeItem.disputedTransaction,
    TransactionIdentifier = FAKER.randomString(10),
    DisputeId = disputeRec.Id,
    Case__c = theCase.Id
  );

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(
      DisputedTransactionItemRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static String getExpectedComment() {
    List<String> transactionIds = new List<String>{
      disputeItemRec.TransactionIdentifier,
      disputeItemRec2.TransactionIdentifier
    };
    return String.format(
      DisputedTransactionItemActions.CASE_COMMENT,
      new List<String>{ String.join(transactionIds, ', ') }
    );
  }

  static Map<String, Object> generateMockResult(Id caseRecordTypeId) {
    return new Map<String, Object>{
      'DisputeId' => theCase.Id,
      'DisputeItems' => caseRecordTypeId
    };
  }

  @isTest
  static void testProcessCaseComments() {
    registerMocks();

    Test.startTest();
    DisputedTransactionItemActions.processCaseComments(
      new List<DisputeItem>{ disputeItemRec, disputeItemRec2 }
    );
    Test.stopTest();

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );

    List<CaseComment> insertedComments = (List<CaseComment>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    String expectedComment = getExpectedComment();

    Assert.areEqual(
      1,
      insertedComments.size(),
      'There should be one CaseComment generated for the Case.'
    );

    Assert.areEqual(
      expectedComment,
      insertedComments[0].CommentBody,
      'The CaseComment should match and contain all the TransactionIdentifiers'
    );

    Assert.areEqual(
      theCase.Id,
      insertedComments[0].ParentId,
      'The CaseComment should be posted to the correct Case record.'
    );
  }

  @isTest
  static void testGenerateCaseComments() {
    List<DisputeItem> records = new List<DisputeItem>{
      disputeItemRec,
      disputeItemRec2
    };
    Map<Id, List<DisputeItem>> disputeItemsByCase = (Map<Id, List<DisputeItem>>) ListUtil.groupBy(
      records,
      DisputeItem.Case__c
    );

    Test.startTest();
    List<CaseComment> caseComments = DisputedTransactionItemActions.generateCaseComments(
      disputeItemsByCase
    );
    Test.stopTest();

    String expectedComment = getExpectedComment();

    Assert.areEqual(
      expectedComment,
      caseComments[0].CommentBody,
      'The CaseComment should match and contain all the TransactionIdentifiers'
    );

    Assert.areEqual(
      theCase.Id,
      caseComments[0].ParentId,
      'The CaseComment should be linked to the correct Case record.'
    );
  }

  @isTest
  static void testProcessParentDisputeDeletionNoLinkedItems() {
    registerMocks();
    Database.DeleteResult deleteResult = TestUtil.getMockDeleteResult(
      '{"success":true}'
    );

    // Mock the repository call to return no related DisputeItems
    repoMock.mock(
      'getRelatedDisputeItemsCount',
      new List<Map<String, Object>>()
    );
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{ deleteResult }
    );

    Test.startTest();
    DisputedTransactionItemActions.processParentDisputeDeletion(
      new List<DisputeItem>{ disputeItemRec }
    );
    Test.stopTest();

    List<Dispute> disputeRecords = (List<Dispute>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');

    Assert.areEqual(
      disputeRecords[0].Id,
      disputeRec.Id,
      'The deleted Dispute record should match the one linked to the DisputeItem.'
    );
  }

  @isTest
  static void testProcessParentDisputeDeletionHasLinkedItems() {
    registerMocks();
    Database.DeleteResult deleteResult = TestUtil.getMockDeleteResult(
      '{"success":true}'
    );

    // Mock the repository call to return related DisputeItems
    repoMock.mock(
      'getRelatedDisputeItemsCount',
      new List<Map<String, Object>>{
        new Map<String, Object>{ 'DisputeId' => disputeRec.Id, 'Count' => 1 }
      }
    );
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{ deleteResult }
    );

    Test.startTest();
    DisputedTransactionItemActions.processParentDisputeDeletion(
      new List<DisputeItem>{ disputeItemRec }
    );
    Test.stopTest();

    List<Dispute> disputeRecords = (List<Dispute>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');

    Assert.isFalse(
      disputeRecords.size() > 0,
      'No Dispute records should be deleted since there are linked DisputeItems.'
    );
  }
}
