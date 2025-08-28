/**
 * @description Test class for AccountQueryController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@isTest
public class AccountQueryControllerTest {
  static Lib_MockProvider accountRepoMock;

  static void registerMocks() {
    accountRepoMock = Lib_MockProvider.forType(AccountRepository.class);
  }

  @isTest
  static void testGetAccountByOcvIdSuccess() {
    registerMocks();
    // Prepare mock Account
    Account mockAccount = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Name = 'Test Account'
    );
    // Mock repository method
    accountRepoMock.mock('getAccountByOcvId', mockAccount);

    Map<String, Object> args = new Map<String, Object>{ 'ocvId' => 'OCV-123' };

    Test.startTest();
    AccountQueryController controller = new AccountQueryController();
    Object result = controller.call('getAccountByOcvId', args);
    Test.stopTest();

    Assert.areNotEqual(null, result, 'Returned Account should not be null');
    Assert.areEqual(
      mockAccount.Id,
      ((Account) result).Id,
      'Returned Account Id should match mock'
    );
    Assert.areEqual(
      'Test Account',
      ((Account) result).Name,
      'Returned Account Name should match mock'
    );
  }

  @isTest
  static void testAuraHandledException() {
    registerMocks();
    // Make the repository throw an exception
    accountRepoMock.mockException(
      'getAccountByOcvId',
      new QueryException('Mocked failure')
    );

    Map<String, Object> args = new Map<String, Object>{ 'ocvId' => 'OCV-FAIL' };

    AccountQueryController controller = new AccountQueryController();
    Boolean thrown = false;
    try {
      controller.call('getAccountByOcvId', args);
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.isTrue(
        e.getMessage().contains('Failed to retrieve Account details'),
        'Should throw custom error message'
      );
    }
    Assert.isTrue(thrown, 'Exception should be thrown on repository failure');
  }
}
