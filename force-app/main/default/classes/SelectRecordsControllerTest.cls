/**
 * @author Hrushikesh
 * @since 10/2025
 * @description Test class for SelectRecordsController
 */
@isTest
public with sharing class SelectRecordsControllerTest {
  static Lib_MockProvider signAuthRepoMock;
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
    signAuthRepoMock = Lib_MockProvider.forType(
      SigningAuthorityUpdateRepository.class
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
    finAccount1.Number_Of_Signatures__c = '2';
    financialAccountsList.add(finAccount1);
    return financialAccountsList;
  }

  @IsTest
  private static void testGetRecords() {
    registerMocks();
    Map<String, Object> params = new Map<String, Object>{
      'recordType' => 'Signing_Authority_Update',
      'issueType' => 'Change to Any to Sign',
      'ocvId' => '1111'
    };
    signAuthRepoMock.mock(
      'getFinancialAccountByOcvId',
      mockFetchFinancialAccountsByOCVId()
    );
    Test.startTest();
    Map<String, Object> result = SelectRecordsController.getRecords(params);
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

  @IsTest
  private static void testUpdateRecords() {
    registerMocks();
    Map<String, Object> params = new Map<String, Object>{
      'recordType' => 'Signing_Authority_Update',
      'issueType' => 'Change to Any to Sign',
      'ocvId' => '1111',
      'caseRecordId' => FAKER_CASE_ID,
      'financialAccount' => FAKER_FIN_ACCOUNT_ID
    };
    Test.startTest();
    SelectRecordsController.updateRecords(params);
    Test.stopTest();
    Case caseRecord = (Case) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.isTrue(
      caseRecord.FinServ__FinancialAccount__c == FAKER_FIN_ACCOUNT_ID,
      'Linked Financial Account is not correct'
    );
  }
}
