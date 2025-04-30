/**
 * @author Pragya Awasthi
 * @since  02/2025
 * @description FinAccountController test class
 */
@isTest
private class FinAccountControllerTest {
  static Lib_MockProvider finAccountRepoMock;
  static void registerMocks() {
    finAccountRepoMock = Lib_MockProvider.forType(FinAccountRepository.class);
  }

  @isTest
  static void testgetExternalRecordId() {
    registerMocks();
    Id depositAccntId = Lib_FakeIdGenerator.getMockId(
      Deposit_Account__x.SObjectType
    );

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
      Name = 'Test',
      Account_Key__c = '00000000000000210679031_DDA_10'
    );

    String externalId =
      finAccount.Account_Key__c +
      '|' +
      finAccount.Product_Code_Display__c +
      finAccount.FinServ__FinancialAccountNumber__c;

    SObject depositAccnt = new Deposit_Account__x(
      Id = depositAccntId,
      ExternalId = externalId
    );

    Test.startTest();
    finAccountRepoMock.mock('getFinAccountDetails', finAccount);
    finAccountRepoMock.mock('getExternalAccountDetails', depositAccnt);
    String recordId = FinAccountController.getExternalRecordId(finAccount.Id);
    Test.stopTest();

    Assert.areNotEqual(null, recordId, 'External Record Id should not be null');
  }
}
