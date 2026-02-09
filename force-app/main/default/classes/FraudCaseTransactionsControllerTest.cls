/**
 * @author Batya Aisman Sufrin
 * @since 09/2025
 * @description tests for {@link FraudCaseTransactionsController}
 */
@isTest
private class FraudCaseTransactionsControllerTest {
  private static final Faker FAKER = new Faker('AU');

  static Lib_MockProvider repoMock;
  static Lib_MockProvider dmlRepoMock;

  static final String ACCOUNT_DETAILS = 'ANZ Plus - Everyday (ANZ Plus Account) 210490765';
  static Dispute disputeAccount = new Dispute(
    CaseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    AccountDetails__c = ACCOUNT_DETAILS,
    ReceivedDate = Date.today()
  );

  static DisputeItem dItem = new DisputeItem(
    Case__c = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    TransactionIdentifier = FAKER.randomString(10),
    AccountDetails__c = ACCOUNT_DETAILS,
    TransactionDate = Date.today()
  );

  static List<DisputeItem> itemsToAdd = new List<DisputeItem>{ dItem };

  static List<DisputeItem> itemsToRemove = new List<DisputeItem>{
    new DisputeItem(Id = Lib_FakeIdGenerator.getMockId(DisputeItem.SObjectType))
  };

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(FraudCaseTransactionsRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testGetDisputeItemsByCaseId() {
    registerMocks();

    repoMock.mock('getDisputeItemsByCaseId', new List<DisputeItem>{ dItem });

    Test.startTest();
    FraudCaseTransactionsController.getDisputeItemsByCaseId(
      Lib_FakeIdGenerator.getMockId(Case.SObjectType)
    );
    Test.stopTest();

    Assert.isFalse(
      repoMock.getHistories('getDisputeItemsByCaseId').isEmpty(),
      'getDisputeItemsByCaseId should have been called.'
    );
  }

  @isTest
  static void testGetDisputeItemsByCaseIdException() {
    registerMocks();

    repoMock.mockException('getDisputeItemsByCaseId');

    try {
      Test.startTest();
      FraudCaseTransactionsController.getDisputeItemsByCaseId(
        Lib_FakeIdGenerator.getMockId(Case.SObjectType)
      );
      Test.stopTest();
      Assert.fail('Exception should have been thrown.');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  @isTest
  static void testSaveDisputeWithItemsNewDisputeItemsToAddAndRemove() {
    registerMocks();

    Test.startTest();
    FraudCaseTransactionsController.saveDisputeWithItems(
      disputeAccount,
      itemsToAdd,
      itemsToRemove
    );
    Test.stopTest();

    Object obj = dmlRepoMock.getHistories('doInsert')[0].getParam('record');
    Assert.isInstanceOfType(
      obj,
      Dispute.class,
      'Inserted record should be a Dispute.'
    );

    obj = dmlRepoMock.getHistories('doInsert')[1].getParam('records');
    Assert.isInstanceOfType(
      obj,
      List<DisputeItem>.class,
      'Inserted record should be a List of DisputeItem.'
    );

    obj = dmlRepoMock.getHistories('doInsert')[2].getParam('record');
    Assert.isInstanceOfType(
      obj,
      CaseComment.class,
      'Inserted record should be a CaseComment.'
    );

    Assert.isFalse(
      dmlRepoMock.getHistories('doDelete').isEmpty(),
      'doDelete should have been invoked'
    );

    List<DisputeItem> disputeItems = (List<DisputeItem>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.isNotNull(disputeItems, 'Dispute items should have been deleted.');
  }

  @isTest
  static void testSaveDisputeWithItemsExistingDisputeItemsToAddAndRemove() {
    registerMocks();

    disputeAccount.Id = Lib_FakeIdGenerator.getMockId(Dispute.SObjectType);

    Test.startTest();
    FraudCaseTransactionsController.saveDisputeWithItems(
      disputeAccount,
      itemsToAdd,
      itemsToRemove
    );
    Test.stopTest();

    Object obj = dmlRepoMock.getHistories('doInsert')[0].getParam('records');
    Assert.isInstanceOfType(
      obj,
      List<DisputeItem>.class,
      'Inserted record should be a List of DisputeItem.'
    );

    obj = dmlRepoMock.getHistories('doInsert')[1].getParam('record');
    Assert.isInstanceOfType(
      obj,
      CaseComment.class,
      'Inserted record should be a CaseComment.'
    );

    Assert.isFalse(
      dmlRepoMock.getHistories('doDelete').isEmpty(),
      'doDelete should have been invoked'
    );

    List<DisputeItem> disputeItems = (List<DisputeItem>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.isNotNull(disputeItems, 'Dispute items should have been deleted.');
  }

  //no itemsToAdd
  @isTest
  static void testSaveDisputeWithItemsExistingDisputeItemsToRemoveAndNoItemsToAdd() {
    registerMocks();

    disputeAccount.Id = Lib_FakeIdGenerator.getMockId(Dispute.SObjectType);

    Test.startTest();
    FraudCaseTransactionsController.saveDisputeWithItems(
      disputeAccount,
      new List<DisputeItem>(),
      itemsToRemove
    );
    Test.stopTest();

    Object obj = dmlRepoMock.getHistories('doInsert')[0].getParam('records');
    Assert.isInstanceOfType(
      obj,
      List<DisputeItem>.class,
      'Inserted record should be a List of DisputeItem.'
    );

    Assert.areEqual(
      1,
      dmlRepoMock.getHistories('doInsert').size(),
      'doInsert should have been invoked once.'
    );

    Assert.isFalse(
      dmlRepoMock.getHistories('doDelete').isEmpty(),
      'doDelete should have been invoked'
    );

    List<DisputeItem> disputeItems = (List<DisputeItem>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.isNotNull(disputeItems, 'Dispute items should have been deleted.');
  }

  @isTest
  static void testSaveDisputeWithItemsException() {
    registerMocks();

    dmlRepoMock.mockException('doDelete');

    try {
      Test.startTest();
      FraudCaseTransactionsController.saveDisputeWithItems(
        disputeAccount,
        itemsToAdd,
        itemsToRemove
      );
      Test.stopTest();
      Assert.fail('Exception should have been thrown.');
    } catch (AuraHandledException e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }
}
