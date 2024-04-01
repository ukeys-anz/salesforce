/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Deposit Account external query test class
 */
@isTest
private class CCRMDepositAccountQueryTest {
  @TestSetup
  static void createTestData() {
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Business_Account')
      .getRecordTypeId();
    Account acct = TestDataFactory.createBusinessRecordTypeAccount(
      'CAP-CIS_4011643101',
      customerRecordTypeId,
      '4011643101'
    );

    Id bankingRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
      .get('BankingAccount')
      .getRecordTypeId();
    FinServ__FinancialAccount__c finAccount = TestDataFactory.createC360FinancialAccount(
      bankingRecordTypeId,
      'CAP-CIS:DDA',
      acct.Id,
      '4011643101-3424909811',
      '3424909811'
    );
    if (finAccount.Id != null) {
      FinServ__FinancialAccountRole__c finRole = [
        SELECT Id, FinServ__FinancialAccount__c, Role_Type__c
        FROM FinServ__FinancialAccountRole__c
        WHERE FinServ__FinancialAccount__c = :finAccount.Id
        LIMIT 1
      ];
      finRole.Role_Type__c = 'PRI';
      update finRole;
    }
  }

  @isTest
  static void createDepositAccountsTest() {
    Test.startTest();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.queryResult[0];
    System.assertEquals(
      'Denis Lai',
      firstRecord.get('AccountName'),
      'Name mismatch'
    );
    System.assertEquals(
      '3424909811',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }
  @isTest
  static void getProductCodeTest() {
    Test.startTest();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );

    CCRMDepositAccountQuery.CCRMDepositAccountModel accountModel = new CCRMDepositAccountQuery.CCRMDepositAccountModel();
    accountModel.accountNumber = '3424909811';
    accountModel.accountName = 'Denis Lai';
    accountModel.productCode = 'DDA';
    accountModel.status = 'Active';
    String productCode = depositAcct.getProductCode(accountModel);
    Test.stopTest();
    System.assertEquals('DDA', productCode, 'Product code mismatch');
  }
  @isTest
  static void getExternalIdTest() {
    Test.startTest();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );

    CCRMDepositAccountQuery.CCRMDepositAccountModel accountModel = new CCRMDepositAccountQuery.CCRMDepositAccountModel();
    accountModel.accountNumber = '3424909811';
    accountModel.accountName = 'Denis Lai';
    accountModel.productCode = 'DDA';
    accountModel.status = 'Active';
    String externalId = depositAcct.getExternalId(accountModel);
    Test.stopTest();
    System.assert(
      externalId.contains('DDA-3424909811'),
      'external id mismatch'
    );
  }
  @isTest
  static void getAccountKeyTest() {
    Test.startTest();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );
    String accountKey = depositAcct.getAccountKey('3424909811', 'DDA');
    Test.stopTest();
    System.assertEquals(
      '4011643101-3424909811|DDA-3424909811',
      accountKey,
      'account Key mismatch'
    );
  }
}
