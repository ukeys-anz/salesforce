/**
 * @author Poorva Shukla
 * @since  11/2025
 * @description  Test Class of ImtCaseTriggerActionsTest
 */
@isTest
public class ImtCaseTriggerActionsTest {
  static Account acc = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    Name = 'Sample Name',
    FinServ__KYCStatus__c = null,
    KYC_Verification_Level__c = null,
    OCV_ID__c = '123456'
  );
  static FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
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

  /**
   * @description populate checking if correct financial account is right cutomer on which case is being created*/
  @IsTest
  static void testUpdateDescription() {
    Case newDispute = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = acc.Id,
      RecordTypeId = RTCase.imtDispute,
      Status = 'Open',
      Transaction_Id__c = 'Txn123',
      CaseNumber__c = 'Testcase1',
      FinServ__FinancialAccount__c = finAcc.Id,
      Dispute_Reason__c = 'Cancel Payment'
    );
    Case newDirectDebitDispute = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = acc.Id,
      RecordTypeId = RTCase.directDebitDispute,
      Status = 'Open',
      Transaction_Id__c = 'Txn123',
      CaseNumber__c = 'Testcase4'
    );
    Test.startTest();
    ImtCaseTriggerActions.updateDescription(new List<Case>{ newDispute });
    newDispute.Dispute_Reason__c = 'Suspected fraud';
    newDispute.Description = 'repayment required';
    ImtCaseTriggerActions.updateDescription(new List<Case>{ newDispute });
    ImtCaseTriggerActions.updateDescription(
      new List<Case>{ newDirectDebitDispute }
    );
    Test.stopTest();

    Assert.areEqual(
      'Payment Recall repayment required',
      newDispute.Description,
      'Correct prefix should be added'
    );
    Assert.areEqual(null, newDirectDebitDispute.Description, 'Not a IMT Case');
  }
  /**
   * @description test to verify if the remove prefix method is working as expected
   */
  @isTest
  public static void testRemovePrefix() {
    String inputDescription = 'Payment Recall IMT Dispute Case Description Test_Text_32k';
    String expectedDescription = 'IMT Dispute Case Description Test_Text_32k';
    Test.startTest();
    String result = ImtCaseTriggerActions.removePrefix(inputDescription);
    Test.stopTest();
    Assert.areEqual(expectedDescription, result, 'Prefix removed successfully');
  }
}
