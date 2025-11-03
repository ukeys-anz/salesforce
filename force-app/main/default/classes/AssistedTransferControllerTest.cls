/**
 * @author Sanskriti Routray
 * @since 10/2025
 * @description Test class for AssistedTransferControllerTest
 */
@isTest
public with sharing class AssistedTransferControllerTest {
  static Lib_MockProvider assistedTransferRepoMock;
  static Lib_MockProvider dmlRepoMock;

  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_FIN_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  static void registerMocks() {
    assistedTransferRepoMock = Lib_MockProvider.forType(
      AssistedTransferRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  private static List<FinServ__FinancialAccount__c> mockFetchFinancialAccountsByOCVId() {
    Account testAccount = TestDataFactory.createPersonAccount('1111', false);
    testAccount.Id = FAKER_ACCOUNT_ID;
    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      RTFinancialAccount.savingAccount,
      FAKER_ACCOUNT_ID,
      false
    );
    finAccount1.Id = FAKER_FIN_ACCOUNT_ID;
    finAccount1.FinServ__FinancialAccountNumber__c = '111111111';
    finAccount1.BSB__c = '04311';
    financialAccountsList.add(finAccount1);
    return financialAccountsList;
  }

  @isTest
  private static void testGetRecordsPostive() {
    registerMocks();
    Map<String, Object> params = new Map<String, Object>{ 'ocvId' => '1111' };
    assistedTransferRepoMock.mock(
      'getFinancialAccountByOcvId',
      mockFetchFinancialAccountsByOCVId()
    );
    Test.startTest();
    AssistedTransferController assistedTransferController = new AssistedTransferController();
    Map<String, Object> result = assistedTransferController.getRecords(params);
    Test.stopTest();
    List<FinServ__FinancialAccount__c> finAccounts = (List<FinServ__FinancialAccount__c>) result.get(
      'data'
    );
    Assert.areEqual(
      finAccounts.size(),
      1,
      'Financial account data fetched successfully'
    );
  }

  @isTest
  private static void testGetRecordsNegative() {
    registerMocks();
    Map<String, Object> params = new Map<String, Object>{ 'ocvId' => '1111' };
    assistedTransferRepoMock.mock(
      'getFinancialAccountByOcvId',
      new List<FinServ__FinancialAccount__c>()
    );
    Test.startTest();
    AssistedTransferController assistedTransferController = new AssistedTransferController();
    Map<String, Object> result = assistedTransferController.getRecords(params);
    Test.stopTest();
    List<FinServ__FinancialAccount__c> finAccounts = (List<FinServ__FinancialAccount__c>) result.get(
      'data'
    );
    Assert.areEqual(
      finAccounts.size(),
      0,
      'No Financial account data should be returned'
    );
  }

  @isTest
  private static void testUpdateRecord() {
    registerMocks();
    Map<String, Object> params = new Map<String, Object>{
      'caseRecordId' => FAKER_CASE_ID,
      'financialAccount' => FAKER_FIN_ACCOUNT_ID,
      'toAccountAmount' => '1000',
      'toAccount' => '1000',
      'toAccountNumber' => '111111111',
      'toAccountBSB' => '04311',
      'transferReason' => 'Power of Attorney transfer requests.'
    };
    Test.startTest();
    AssistedTransferController assistedTransferController = new AssistedTransferController();
    assistedTransferController.updateRecords(params);
    Test.stopTest();
    Case caseRecord = (Case) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.isTrue(
      caseRecord.FinServ__FinancialAccount__c == FAKER_FIN_ACCOUNT_ID,
      'Linked Financial Account is not correct'
    );
  }
}
