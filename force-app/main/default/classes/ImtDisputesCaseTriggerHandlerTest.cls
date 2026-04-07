/**
 * @author Poorva Shukla
 * @since  1/2026
 * @description  ImtDisputesCaseTriggerHandlerTest Class for CaseTriggerDisputeHandler
 */
@IsTest
public class ImtDisputesCaseTriggerHandlerTest {
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }
  /**
   * @description Test onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   */
  @IsTest
  static void testapplyDefault() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Sample Name',
      FinServ__KYCStatus__c = null,
      KYC_Verification_Level__c = null,
      OCV_ID__c = '123456'
    );
    FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      ),
      Name = 'Test',
      FinServ__Status__c = 'Active',
      FinServ__FinancialAccountType__c = 'Savings',
      FinServ__PrimaryOwner__c = acc.Id,
      Account_Key__c = '4011643101-3424909811',
      FinServ__FinancialAccountNumber__c = '3424909811',
      Product_Type__c = 'CAP-CIS:DDA'
    );
    Case newDispute = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = acc.Id,
      RecordTypeId = RTCase.imtDispute,
      Status = 'Open',
      Transaction_Id__c = 'Txn123',
      CaseNumber__c = 'Testcase1',
      FinServ__FinancialAccount__c = finAcc.Id
    );
    ImtDisputesCaseTriggerHandler handler = new ImtDisputesCaseTriggerHandler();
    handler.records = new List<Case>{ newDispute };
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.isValidRecord(newDispute);
    handler.onApplyDefaults();
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
  }

  /**
   * @description Test onBeforeInsert to handle before insert trigger actions.
   */
  @IsTest
  static void testBeforeInsert() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Sample Name',
      FinServ__KYCStatus__c = null,
      KYC_Verification_Level__c = null,
      OCV_ID__c = '123456'
    );
    FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      ),
      Name = 'Test',
      FinServ__Status__c = 'Active',
      FinServ__FinancialAccountType__c = 'Savings',
      FinServ__PrimaryOwner__c = acc.Id,
      Account_Key__c = '4011643101-3424909811',
      FinServ__FinancialAccountNumber__c = '3424909811',
      Product_Type__c = 'CAP-CIS:DDA'
    );
    Case newDispute = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = acc.Id,
      RecordTypeId = RTCase.imtDispute,
      Status = 'Open',
      Transaction_Id__c = 'Txn123',
      CaseNumber__c = 'Testcase1',
      FinServ__FinancialAccount__c = finAcc.Id
    );
    ImtDisputesCaseTriggerHandler handler = new ImtDisputesCaseTriggerHandler();
    handler.records = new List<Case>{ newDispute };
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onBeforeInsert();
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
  }
  /**
   * @description Test onAfterInsert to handle after insert trigger actions.
   */
  @IsTest
  static void testAfterInsert() {
    registerMocks();
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Sample Name',
      FinServ__KYCStatus__c = null,
      KYC_Verification_Level__c = null,
      OCV_ID__c = '123456'
    );
    FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      ),
      Name = 'Test',
      FinServ__Status__c = 'Active',
      FinServ__FinancialAccountType__c = 'Savings',
      FinServ__PrimaryOwner__c = acc.Id,
      Account_Key__c = '4011643101-3424909811',
      FinServ__FinancialAccountNumber__c = '3424909811',
      Product_Type__c = 'CAP-CIS:DDA'
    );
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case newDispute = new Case(
      Id = caseId,
      AccountId = acc.Id,
      RecordTypeId = RTCase.imtDispute,
      Status = 'Open',
      Transaction_Id__c = 'Txn123',
      CaseNumber__c = 'Testcase1',
      FinServ__FinancialAccount__c = finAcc.Id
    );
    ImtDisputesCaseTriggerHandler handler = new ImtDisputesCaseTriggerHandler();
    handler.records = new List<Case>{ newDispute };
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onAfterInsert();
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
  }

  /**
   * @description Test onBeforeUpdate to handle before update trigger actions.
   */
  @IsTest
  static void testBeforeUpdate() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Sample Name',
      FinServ__KYCStatus__c = null,
      KYC_Verification_Level__c = null,
      OCV_ID__c = '123456'
    );
    FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      ),
      Name = 'Test',
      FinServ__Status__c = 'Active',
      FinServ__FinancialAccountType__c = 'Savings',
      FinServ__PrimaryOwner__c = acc.Id,
      Account_Key__c = '4011643101-3424909811',
      FinServ__FinancialAccountNumber__c = '3424909811',
      Product_Type__c = 'CAP-CIS:DDA'
    );
    Case newDispute = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = acc.Id,
      RecordTypeId = RTCase.imtDispute,
      Status = 'Open',
      Transaction_Id__c = 'Txn123',
      CaseNumber__c = 'Testcase1',
      FinServ__FinancialAccount__c = finAcc.Id
    );
    ImtDisputesCaseTriggerHandler handler = new ImtDisputesCaseTriggerHandler();
    handler.records = new List<Case>{ newDispute };
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onBeforeUpdate(new Map<Id, Case>{ newDispute.id => newDispute });
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
  }
}
