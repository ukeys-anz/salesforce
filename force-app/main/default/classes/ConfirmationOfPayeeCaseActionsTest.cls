/**
 * @author Kopal Goswami
 * @since 12/2024
 * @description ConfirmationOfPayeeCaseActionsTest is the test class to cover tests for {@link ConfirmationOfPayeeCaseActions.cls}
 */

@isTest
public with sharing class ConfirmationOfPayeeCaseActionsTest {
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_FINANCIAL_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  static Lib_MockProvider accountClosureRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    accountClosureRepoMock = Lib_MockProvider.forType(
      AccountClosureRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  private static void testHandleModifyCopActionPostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryEligibleChildCasesForCop',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    ConfirmationOfPayeeCaseActions.handleModifyCopAction(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Account_Closure__c == true,
      'Show Account Closure flag should be true as their are no child cases with Closed status'
    );
  }

  @isTest
  private static void testHandleModifyCopActionNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryEligibleChildCasesForCop',
      new List<Case>()
    );

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    ConfirmationOfPayeeCaseActions.handleModifyCopAction(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Account_Closure__c == false,
      'Show Account Closure flag should be false as their is no eligible child case is found'
    );
  }

  @isTest
  private static void testPopulateChildCaseSubjectPositive() {
    registerMocks();
    List<Case> childCaseRecord = mockQueryChildCaseRecords(
      FAKER_PARENT_CASE_ID
    );

    Test.startTest();
    ConfirmationOfPayeeCaseActions.populateChildCaseSubject(childCaseRecord);
    Test.stopTest();

    Assert.isTrue(
      childCaseRecord[0].Subject == 'Confirmation of Payee Opt-In - 111111111',
      'Subject of the case is updated to Confirmation of Payee Opt-In - 111111111'
    );
  }

  @isTest
  private static void testModifyCopStatusButtonVisibilityPostive() {
    registerMocks();

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    ConfirmationOfPayeeCaseActions.modifyCopStatusButtonVisibility(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Account_Closure__c == true,
      'Show Account Closure flag should be true during insert option'
    );
  }

  private static List<Case> mockQueryChildCaseRecords(Id parentId) {
    List<Case> childcases = new List<Case>();

    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = 'Open';
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = parentId;
    caseRecord.RecordTypeId = RTCase.confirmationOfPayee;
    caseRecord.Type = GetHelpConstants.COP_OPT_IN;
    caseRecord.FinServ__FinancialAccount__c = FAKER_FINANCIAL_ACCOUNT_ID;
    Case caseRecordWithAccountNumber = (Case) TestUtil.setFields(
      caseRecord,
      new Map<String, Object>{ 'Customer_Account_Number__c' => '111111111' }
    );
    childcases.add(caseRecordWithAccountNumber);
    return childcases;
  }

  private static List<Case> mockParentCaseRecord(
    String statusValue,
    String circumstanceValue
  ) {
    List<Case> parentCases = new List<Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_PARENT_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = statusValue;
    caseRecord.RecordTypeId = RTCase.caseGroup;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.Type = GetHelpConstants.COP_OPT_IN;

    parentCases.add(caseRecord);
    return parentCases;
  }

  private static List<FinServ__FinancialAccount__c> mockFinancialAccounts() {
    List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>();
    finAccounts.add(
      new FinServ__FinancialAccount__c(
        Id = FAKER_FINANCIAL_ACCOUNT_ID,
        FinServ__FinancialAccountNumber__c = '111111111',
        FinServ__Balance__c = 1.99,
        FinServ__CurrentPostedBalance__c = 1.99,
        BSB__c = '014111',
        FinServ__ProductName__c = '01t2P000000GKT7QAO',
        FinServ__OpenDate__c = Date.newInstance(2016, 9, 21),
        FinServ__CloseDate__c = null,
        FinServ__Status__c = 'Active',
        Marketing_Code__c = 'SAVING01',
        FinServ__Ownership__c = 'Single'
      )
    );
    return finAccounts;
  }
}
