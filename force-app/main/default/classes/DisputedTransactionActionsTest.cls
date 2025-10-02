/**
 * @author Karen Valeriano
 * @since August 2025
 * @description tests for {@link DisputedTransactionActions}
 */
@isTest
private with sharing class DisputedTransactionActionsTest {
  static Lib_MockProvider repoMock;
  static Lib_MockProvider dmlRepoMock;
  static final Faker FAKER = new Faker('en-AU');
  static Case theCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)
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
    TransactionAmount = FAKER.randomDecimal(3, 2),
    TransactionDate = FAKER.randomPastDate(),
    TransactionIdentifier = FAKER.randomString(10),
    RecoveryAmount__c = FAKER.randomDecimal(2, 2),
    DisputeId = disputeRec.Id,
    Case__c = theCase.Id
  );
  static DisputeItem disputeItemRec2 = new DisputeItem(
    Id = Lib_FakeIdGenerator.getMockId(DisputeItem.SObjectType),
    RecordTypeId = RTDisputeItem.disputedTransaction,
    TransactionAmount = FAKER.randomDecimal(3, 2),
    TransactionDate = FAKER.randomPastDate(),
    TransactionIdentifier = FAKER.randomString(10),
    RecoveryAmount__c = FAKER.randomDecimal(2, 2),
    DisputeId = disputeRec.Id,
    Case__c = theCase.Id
  );

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(DisputedTransactionRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static Map<String, Object> generateMockResult(Id caseRecordTypeId) {
    return new Map<String, Object>{
      'CaseId' => theCase.Id,
      'RecordTypeId' => caseRecordTypeId,
      'TotalRecoveryAmount__c' => disputeItemRec.RecoveryAmount__c,
      'TotalTransactionAmount__c' => disputeItemRec.TransactionAmount
    };
  }

  static void mockRepos(Map<String, Object> mockResult) {
    repoMock.mock(
      'getRelatedAggregatedDisputes',
      new List<Map<String, Object>>{ mockResult }
    );
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
  }

  static void assertCommonFields(Case caseRec, Map<String, Object> mockResult) {
    Assert.areEqual(
      mockResult.get('TotalRecoveryAmount__c'),
      caseRec.Fraud_Total_Recovered__c,
      'The total recovery amount should be rolled up to the Case'
    );
    Assert.areEqual(
      disputeRec.CaseId,
      caseRec.Id,
      'The Case record associated with the Dispute should be updated'
    );
  }

  @isTest
  static void testCalculateDisputeTotalAmountsRecipientMule() {
    registerMocks();
    Map<String, Object> mockResult = generateMockResult(RTCase.recipientMule);
    mockRepos(mockResult);

    Test.startTest();
    DisputedTransactionActions.calculateDisputeTotalAmounts(
      new List<Dispute>{ disputeRec }
    );
    Test.stopTest();

    List<Case> caseRec = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(
      mockResult.get('TotalTransactionAmount__c'),
      caseRec[0].Fraud_Total_Fraud_Received__c,
      'The total transaction amount should be rolled up to the Case'
    );
    assertCommonFields(caseRec[0], mockResult);
  }

  @isTest
  static void testCalculateDisputeTotalAmountsScam() {
    registerMocks();
    Map<String, Object> mockResult = generateMockResult(RTCase.scam);
    mockRepos(mockResult);

    Test.startTest();
    DisputedTransactionActions.calculateDisputeTotalAmounts(
      new List<Dispute>{ disputeRec }
    );
    Test.stopTest();

    List<Case> caseRec = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(
      mockResult.get('TotalTransactionAmount__c'),
      caseRec[0].Fraud_Total_Scam_Value__c,
      'The total transaction amount should be rolled up to the Case'
    );
    assertCommonFields(caseRec[0], mockResult);
  }

  @isTest
  static void testCalculateDisputeTotalAmountsFraud() {
    registerMocks();
    Map<String, Object> mockResult = generateMockResult(RTCase.fraud);
    mockRepos(mockResult);

    Test.startTest();
    DisputedTransactionActions.calculateDisputeTotalAmounts(
      new List<Dispute>{ disputeRec }
    );
    Test.stopTest();

    List<Case> caseRec = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(
      mockResult.get('TotalTransactionAmount__c'),
      caseRec[0].Fraud_Total_Fraud_Value__c,
      'The total transaction amount should be rolled up to the Case'
    );
    assertCommonFields(caseRec[0], mockResult);
  }

  @isTest
  static void testGetCasesForRollupUpdates() {
    Map<String, Object> mockResult = generateMockResult(RTCase.fraud);

    Test.startTest();
    List<Case> cases = DisputedTransactionActions.getCasesForRollupUpdates(
      new List<Map<String, Object>>{ mockResult }
    );
    Test.stopTest();

    Assert.areEqual(
      mockResult.get('TotalRecoveryAmount__c'),
      cases[0].Fraud_Total_Recovered__c,
      'The total recovery amount should be reflected to the Case'
    );
    Assert.areEqual(
      mockResult.get('TotalTransactionAmount__c'),
      cases[0].Fraud_Total_Fraud_Value__c,
      'The total transaction amount should be reflected to the Case'
    );
  }

  @isTest
  static void testProcessCaseComments() {
    registerMocks();
    repoMock.mock(
      'getDisputedTransactionItems',
      new List<DisputeItem>{ disputeItemRec, disputeItemRec2 }
    );

    Test.startTest();
    DisputedTransactionActions.processCaseComments(
      new List<Dispute>{ disputeRec }
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

    List<String> transactionIds = new List<String>{
      disputeItemRec.TransactionIdentifier,
      disputeItemRec2.TransactionIdentifier
    };
    String expectedComment = String.format(
      DisputedTransactionItemActions.CASE_COMMENT,
      new List<String>{ String.join(transactionIds, ', ') }
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
}
