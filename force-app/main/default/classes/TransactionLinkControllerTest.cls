/**
 * @author Batya Aisman Sufrin
 * @since 09/2025
 * @description tests for {@link TransactionLinkController}
 */
@isTest
private class TransactionLinkControllerTest {
  static Lib_MockProvider repoMock;

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(TransactionLinkRepository.class);
  }

  @isTest
  static void testGetFinancialAccounts() {
    registerMocks();

    repoMock.mock(
      'queryANZxAccountRoles',
      new List<FinServ__FinancialAccountRole__c>()
    );

    Test.startTest();
    TransactionLinkController.getFinancialAccounts(
      Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    Test.stopTest();

    Assert.isFalse(
      repoMock.getHistories('queryANZxAccountRoles').isEmpty(),
      'queryANZxAccountRoles should have been called.'
    );
  }

  @isTest
  static void testGetFinancialAccountsException() {
    registerMocks();

    repoMock.mockException(
      'queryANZxAccountRoles',
      new QueryException('Query Exception')
    );

    try {
      Test.startTest();
      TransactionLinkController.getFinancialAccounts(
        Lib_FakeIdGenerator.getMockId(Account.SObjectType)
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
}
