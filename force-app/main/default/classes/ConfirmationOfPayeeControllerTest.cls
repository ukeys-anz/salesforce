/**
 * @author Kopal Goswami
 * @since 12/2024
 * @description ConfirmationOfPayeeControllerTest is the test class to cover tests for {@link ConfirmationOfPayeeController.cls}
 */

@isTest
public with sharing class ConfirmationOfPayeeControllerTest {
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  private static final Id FAKER_FIN_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  static Lib_MockProvider copRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    copRepoMock = Lib_MockProvider.forType(ConfirmationOfPayeeRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  public static void testGetDataPositive() {
    registerMocks();
    copRepoMock.mock(
      'fetchFinancialAccountsByOCVId',
      mockFetchFinancialAccountsByOCVId()
    );
    copRepoMock.mock('getCasesByFinancialAccountIds', new List<Case>());
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());

    Test.startTest();
    ConfirmationOfPayeeController copController = new ConfirmationOfPayeeController();
    List<CaseGroupFinancialAccountModel> getfinancialAccounts = copController.getData(
      mockParams()
    );
    Test.stopTest();
    Assert.areEqual(
      getfinancialAccounts.size(),
      1,
      'Financial account data fetched successfully'
    );
  }

  @isTest
  public static void testGetDataNegative() {
    registerMocks();
    copRepoMock.mock(
      'fetchFinancialAccountsByOCVId',
      new List<FinServ__FinancialAccount__c>()
    );
    copRepoMock.mock(
      'getCasesByFinancialAccountIds',
      mockListOfCases('000000000')
    );
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());

    Test.startTest();
    ConfirmationOfPayeeController copController = new ConfirmationOfPayeeController();
    List<CaseGroupFinancialAccountModel> getfinancialAccounts = copController.getData(
      mockParams()
    );
    Test.stopTest();

    Assert.areEqual(
      getfinancialAccounts.size(),
      0,
      'No Financial Account Data'
    );
  }

  @isTest
  public static void testInitiateModifyConfirmationOfPayeePositive() {
    registerMocks();

    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());
    copRepoMock.mock(
      'getFinAccountRolesByAccountNum',
      mockFinancialAccountRoles()
    );

    Test.startTest();
    CaseDetailsContainer initiateCop = ConfirmationOfPayeeController.initiateModifyConfirmationOfPayee(
      '1111',
      mockListOfCases('000000000')
    );
    Test.stopTest();

    Assert.areEqual(
      initiateCop.successList.size(),
      1,
      'Initiated Modify COP request'
    );
  }

  @isTest
  public static void testInitiateModifyConfirmationOfPayeeNegative() {
    registerMocks();

    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());
    copRepoMock.mock(
      'getFinAccountRolesByAccountNum',
      mockFinancialAccountRoles()
    );

    Test.startTest();
    CaseDetailsContainer initiateCop = ConfirmationOfPayeeController.initiateModifyConfirmationOfPayee(
      '1111',
      mockListOfCases('11111111')
    );
    Test.stopTest();

    Assert.areEqual(
      initiateCop.successList.size(),
      0,
      'Modify COP request is not initiated successfully'
    );
  }

  @isTest
  public static void testfetchCOPInformationPositive() {
    registerMocks();

    copRepoMock.mock(
      'getFinancialAccountById',
      mockFetchFinancialAccountsByOCVId()[0]
    );
    copRepoMock.mock('getCasesByFinancialAccountIds', new List<Case>());
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());

    Test.startTest();
    List<CaseGroupFinancialAccountModel> copInformation = ConfirmationOfPayeeController.fetchCOPInformation(
      FAKER_FIN_ACCOUNT_ID
    );
    Test.stopTest();

    Assert.areEqual(
      copInformation.size(),
      1,
      'COP Information Fetched Successfully'
    );
  }

  private static Map<String, String> mockParams() {
    Map<String, String> params = new Map<String, String>();
    params.put('ocvId', '1111');
    params.put('parentCaseId', String.valueOf(FAKER_PARENT_CASE_ID));
    params.put('issueType', 'Confirmation of Payee Opt-Out');
    return params;
  }

  private static List<FinServ__FinancialAccount__c> mockFetchFinancialAccountsByOCVId() {
    Account testAccount = TestDataFactory.createPersonAccount('1111', false);
    testAccount.Id = FAKER_ACCOUNT_ID;
    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
      FAKER_ACCOUNT_ID,
      false
    );
    finAccount1.Id = FAKER_FIN_ACCOUNT_ID;
    finAccount1.FinServ__FinancialAccountNumber__c = '111111111';
    finAccount1.BSB__c = '04311';
    financialAccountsList.add(finAccount1);
    return financialAccountsList;
  }

  private static List<Account> mockGetAccountsByOcvIds() {
    List<Account> accountRecords = new List<Account>();
    Account acc = new Account();
    acc.Id = FAKER_ACCOUNT_ID;
    acc.Name = 'Sample Name';
    acc.OCV_Id__c = '1111';
    accountRecords.add(acc);
    return accountRecords;
  }

  private static List<User> mockGetUsersByLANId() {
    List<User> userRecords = new List<User>();
    User usr = TestUtil.createTestUser();
    usr.Lan_Id__c = 'Sname';
    userRecords.add(usr);
    return userRecords;
  }

  private static List<Case> mockListOfCases(String accnumber) {
    List<Case> listOfExistingCases = new List<Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.parentId = FAKER_PARENT_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = 'Open';
    caseRecord.RecordTypeId = RTCase.confirmationOfPayee;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.FinServ__FinancialAccount__c = FAKER_FIN_ACCOUNT_ID;
    Case caseRecord1 = (Case) TestUtil.setFields(
      caseRecord,
      new Map<String, Object>{ 'Customer_Account_Number__c' => accnumber }
    );

    listOfExistingCases.add(caseRecord1);
    return listOfExistingCases;
  }

  private static List<FinServ__FinancialAccountRole__c> mockFinancialAccountRoles() {
    List<FinServ__FinancialAccountRole__c> finAccountRoleList = new List<FinServ__FinancialAccountRole__c>();

    FinServ__FinancialAccountRole__c finAccountRole = new FinServ__FinancialAccountRole__c();
    finAccountRole.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SObjectType
    );
    finAccountRole.FinServ__RelatedAccount__c = FAKER_ACCOUNT_ID;
    finAccountRole.FinServ__Active__c = true;
    FinServ__FinancialAccountRole__c finAccountRole1 = (FinServ__FinancialAccountRole__c) TestUtil.setFields(
      finAccountRole,
      new Map<String, Object>{ 'Account_Number__c' => '000000000' }
    );

    finAccountRoleList.add(finAccountRole1);

    return finAccountRoleList;
  }
}
