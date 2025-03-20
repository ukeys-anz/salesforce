/**
 * @author Shivam Swaraj
 * @since 2025
 * @description ConfirmationOfPayeeHelperTest is the test class to cover tests for {@link ConfirmationOfPayeeHelper}
 */
@isTest
public with sharing class ConfirmationOfPayeeHelperTest {
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
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
  private static void testGetCOPStatusRequest() {
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    AccountCoPStatusRequestModel result = copHelper.getCOPStatusRequest(
      mockFetchFinancialAccountsByOCVId()
    );
    Test.stopTest();
    Assert.isFalse(result == null, 'Expected result to be non-null');
  }

  @isTest
  private static void testPopulateRequestedByMapForGetCop() {
    registerMocks();
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, Account> requestedByMap = copHelper.populateRequestedByMap(
      mockGetAccountCoPdetails
    );

    Test.stopTest();
    Assert.isFalse(
      requestedByMap == null,
      'Map of OCV Id and Account details will be present for get COP'
    );
  }

  @isTest
  private static void testPopulateRequestedByMapForUpdateCop() {
    registerMocks();
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, Account> requestedByMap = copHelper.populateRequestedByMap(
      mockUpdateAccountCoPdetails
    );

    Test.stopTest();
    Assert.isFalse(
      requestedByMap == null,
      'Map of OCV Id and Account details will be present for update COP'
    );
  }

  @isTest
  private static void testPopulateModifiedByMapForGetCop() {
    registerMocks();
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());

    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, User> modifiedByMap = copHelper.populateModifiedByMap(
      mockGetAccountCoPdetails
    );

    Test.stopTest();
    Assert.isFalse(
      modifiedByMap == null,
      'Map of OCV Id and User details will be present for Get COP'
    );
  }

  @isTest
  private static void testPopulateModifiedByMapForUpdateCop() {
    registerMocks();
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());

    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, User> modifiedByMap = copHelper.populateModifiedByMap(
      mockUpdateAccountCoPdetails
    );

    Test.stopTest();
    Assert.isFalse(
      modifiedByMap == null,
      'Map of OCV Id and User details will be present for Get COP'
    );
  }

  @isTest
  private static void testGetRequestorNamesForGetCop() {
    registerMocks();
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, String> requestorNamesMap = copHelper.getRequestorNames(
      mockGetAccountCoPdetails,
      new Map<String, Account>{ '1001297679' => mockGetAccountsByOcvIds()[0] }
    );

    Test.stopTest();
    Assert.isFalse(
      requestorNamesMap == null,
      'Map of Requested Id and Name will be avaialble'
    );
  }

  @isTest
  private static void testGetRequestorNamesForUpdateCop() {
    registerMocks();
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, String> requestorNamesMap = copHelper.getRequestorNames(
      mockUpdateAccountCoPdetails,
      new Map<String, Account>{ '1001297679' => mockGetAccountsByOcvIds()[0] }
    );

    Test.stopTest();
    Assert.isFalse(
      requestorNamesMap == null,
      'Map of Requested Id and Name will be avaialble'
    );
  }

  @isTest
  private static void testFilterValidAccounts() {
    FinServ__FinancialAccount__c finAccount = mockFetchFinancialAccountsByOCVId()[0];
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();
    Map<String, FinServ__FinancialAccount__c> validAccounts = copHelper.filterValidAccounts(
      mockGetAccountCoPdetails,
      new Map<String, FinServ__FinancialAccount__c>{
        finAccount.FinServ__FinancialAccountNumber__c => finAccount
      },
      null
    );
    Test.stopTest();
    Assert.isFalse(
      validAccounts == null,
      'Map of valid account number and financial account will be expected'
    );
  }

  @isTest
  private static void testMapFinancialAccountsToModels() {
    registerMocks();
    copRepoMock.mock('getAccountsByOcvIds', mockGetAccountsByOcvIds());
    copRepoMock.mock('getUsersByLANId', mockGetUsersByLANId());
    FinServ__FinancialAccount__c finAccount = mockFetchFinancialAccountsByOCVId()[0];
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    Map<String, Account> requestedBymap = copHelper.populateRequestedByMap(
      mockGetAccountCoPdetails
    );

    Map<String, String> requestorNamesMap = copHelper.getRequestorNames(
      mockGetAccountCoPdetails,
      requestedBymap
    );

    Map<String, User> modifiedByMap = copHelper.populateModifiedByMap(
      mockGetAccountCoPdetails
    );

    Map<String, FinServ__FinancialAccount__c> validAccounts = copHelper.filterValidAccounts(
      mockGetAccountCoPdetails,
      new Map<String, FinServ__FinancialAccount__c>{
        finAccount.FinServ__FinancialAccountNumber__c => finAccount
      },
      null
    );

    List<CaseGroupFinancialAccountModel> finAccountToModelList = copHelper.mapFinancialAccountsToModels(
      mockGetAccountCoPdetails,
      validAccounts,
      requestorNamesMap,
      modifiedByMap
    );

    Test.stopTest();
    Assert.isFalse(
      finAccountToModelList == null,
      'Expected List Of CaseGroupFinancialAccountModel'
    );
  }

  @isTest
  private static void testGetUpdateCOPRequest() {
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();
    Test.startTest();

    FinancialAccModelUpdateRequestCoP listOfFinAccModelUpdate = copHelper.getUpdateCOPRequest(
      mockListOfCases('000000000')
    );

    Test.stopTest();
    Assert.isFalse(
      listOfFinAccModelUpdate == null,
      'Expected FinancialAccModelUpdateRequestCoP'
    );
  }

  @isTest
  private static void testPopulateSuccessFinancialAccNumberVsCustomerListNegative() {
    registerMocks();
    copRepoMock.mock(
      'getFinAccountRolesByAccountNum',
      mockFinancialAccountRoles('000000000')
    );
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();

    Test.startTest();
    Map<String, List<String>> finaccountNumberandCustomerMap = copHelper.populateSuccessFinancialAccNumberVsCustomerList(
      mockUpdateAccountCoPdetails
    );

    Assert.areEqual(
      finaccountNumberandCustomerMap.size(),
      0,
      'A map of financial account numbers to a list of related customer IDs is not populated'
    );
    Test.stopTest();
  }

  @isTest
  private static void testMapUpdateCOPStatusResponsePositive() {
    registerMocks();

    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();

    Test.startTest();
    CaseDetailsContainer successAndFailedCaseUpdates = copHelper.mapUpdateCOPStatusResponse(
      mockUpdateAccountCoPdetails,
      mockFinancialAccNumAndCaseMap('000000000'),
      mockRequestorNamesMap('000000000'),
      new Map<String, User>()
    );
    Assert.areEqual(
      successAndFailedCaseUpdates.successList.size(),
      1,
      'Modify COP request is not initiated successfully'
    );

    Test.stopTest();
  }

  @isTest
  private static void testMapUpdateCaseRecordsPositive() {
    registerMocks();

    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();

    Test.startTest();
    copHelper.updateCaseRecords(mockCaseDetailsContainer(null));

    List<Case> caseUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Test.stopTest();

    Assert.isTrue(caseUpdated.size() > 0, 'Case Updated Successfully');
  }

  @isTest
  private static void testMapUpdateCaseRecordsNegative() {
    registerMocks();

    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();

    Test.startTest();
    copHelper.updateCaseRecords(new CaseDetailsContainer());

    List<Case> caseUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Test.stopTest();

    Assert.isFalse(caseUpdated.size() > 0, 'Case should not Update');
  }

  @isTest
  private static void testPostResponseMessageToChatterPostive() {
    registerMocks();
    Exception thrownException;
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();

    Test.startTest();
    try {
      copHelper.postResponseMessageToChatter(
        mockCaseDetailsContainer('2025-03-19T05:42:59.000+0000'),
        new Map<String, List<String>>()
      );
    } catch (Exception e) {
      thrownException = e;
    }
    Test.stopTest();
    Assert.isNull(thrownException, 'An exception should not be thrown');
  }

  @isTest
  private static void testPostResponseMessageToChatterNegative() {
    registerMocks();
    Exception thrownException;
    ConfirmationOfPayeeHelper copHelper = new ConfirmationOfPayeeHelper();

    Test.startTest();
    try {
      copHelper.postResponseMessageToChatter(
        mockCaseDetailsContainer(null),
        new Map<String, List<String>>()
      );
    } catch (Exception e) {
      thrownException = e;
    }
    Test.stopTest();
    Assert.isNotNull(thrownException, 'An exception must have been thrown');
  }

  private static List<FinServ__FinancialAccount__c> mockFetchFinancialAccountsByOCVId() {
    Account testAccount = TestDataFactory.createPersonAccount(
      '1001297679',
      false
    );
    testAccount.Id = FAKER_ACCOUNT_ID;
    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
      FAKER_ACCOUNT_ID,
      false
    );
    finAccount1.Id = FAKER_FIN_ACCOUNT_ID;
    finAccount1.FinServ__FinancialAccountNumber__c = '000000000';
    finAccount1.BSB__c = '04311';
    financialAccountsList.add(finAccount1);
    return financialAccountsList;
  }

  private static List<Account> mockGetAccountsByOcvIds() {
    Account testAccount = TestDataFactory.createPersonAccount(
      '1001297679',
      false
    );
    testAccount.Id = FAKER_ACCOUNT_ID;
    return new List<Account>{ testAccount };
  }

  private static List<User> mockGetUsersByLANId() {
    List<User> userRecords = new List<User>();
    User usr = TestUtil.createTestUser();
    usr.Lan_Id__c = '1001297679';
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

  /**
   * @description This method helps in providing the mock response from Fabric
   * @return Fabric financial accounts
   */
  private static FinancialAccountModelGetResponseCoP mockGetAccountCoPdetails {
    get {
      String mockCOPGetAccountCoPdetails = [
          SELECT body
          FROM StaticResource
          WHERE Name = 'mock_getAccountCoPdetails'
        ]
        .body.toString();
      return FinancialAccountModelGetResponseCoP.parse(
        mockCOPGetAccountCoPdetails
      );
    }
  }

  /**
   * @description This method helps in providing the mock response from Fabric
   * @return Fabric financial accounts
   */
  private static FinancialAccModelUpdateResponseCoP mockUpdateAccountCoPdetails {
    get {
      String mockCOPUpdateAccountCoPdetails = [
          SELECT body
          FROM StaticResource
          WHERE Name = 'mock_updateAccountCoPdetails'
        ]
        .body.toString();
      return FinancialAccModelUpdateResponseCoP.parse(
        mockCOPUpdateAccountCoPdetails
      );
    }
  }

  private static List<FinServ__FinancialAccountRole__c> mockFinancialAccountRoles(
    String accNumber
  ) {
    List<FinServ__FinancialAccountRole__c> finAccountRoleList = new List<FinServ__FinancialAccountRole__c>();

    FinServ__FinancialAccountRole__c finAccountRole = new FinServ__FinancialAccountRole__c();
    finAccountRole.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SObjectType
    );
    finAccountRole.FinServ__RelatedAccount__c = FAKER_ACCOUNT_ID;
    finAccountRole.FinServ__Active__c = true;
    FinServ__FinancialAccountRole__c finAccountRole1 = (FinServ__FinancialAccountRole__c) TestUtil.setFields(
      finAccountRole,
      new Map<String, Object>{ 'Account_Number__c' => accNumber }
    );

    finAccountRoleList.add(finAccountRole1);

    return finAccountRoleList;
  }

  private static Map<String, Case> mockFinancialAccNumAndCaseMap(
    String accNumber
  ) {
    Map<String, Case> financialAccNumAndCaseMap = new Map<String, Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    financialAccNumAndCaseMap.put(accNumber, caseRecord);
    return financialAccNumAndCaseMap;
  }

  private static Map<String, String> mockRequestorNamesMap(String accNumber) {
    Map<String, String> requestorNamesMap = new Map<String, String>();
    requestorNamesMap.put(accNumber, 'Sname');

    return requestorNamesMap;
  }

  private static CaseDetailsContainer mockCaseDetailsContainer(
    String datevalue
  ) {
    List<CaseDetailsContainer.CaseDetailsWithCoPStatus> caseDetailsWithCopList = new List<CaseDetailsContainer.CaseDetailsWithCoPStatus>();
    CaseDetailsContainer.CaseDetailsWithCoPStatus caseDetailsWithCoPStatusrecord = new CaseDetailsContainer.CaseDetailsWithCoPStatus();
    caseDetailsWithCoPStatusrecord.caseId = FAKER_CHILD_CASE_ID;
    caseDetailsWithCoPStatusrecord.accountType = 'Single';
    caseDetailsWithCoPStatusrecord.caseCoPStatus = 'OPT-IN';
    caseDetailsWithCoPStatusrecord.requestedByName = 'Sname';
    caseDetailsWithCoPStatusrecord.modifiedByName = 'Kname';
    caseDetailsWithCoPStatusrecord.statusChangeDateTime = datevalue;
    caseDetailsWithCopList.add(caseDetailsWithCoPStatusrecord);

    CaseDetailsContainer casedetails = new CaseDetailsContainer();
    casedetails.successList = caseDetailsWithCopList;

    return casedetails;
  }
}
