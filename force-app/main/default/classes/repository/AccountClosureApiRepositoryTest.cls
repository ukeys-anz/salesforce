/**
 * @author Shivam Swaraj
 * @date April 2025
 * @description Test class for {@link AccountClosureApiRepository}
 * @group Repository
 */
@isTest
public with sharing class AccountClosureApiRepositoryTest {
    private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
        Case.getSObjectType()
        );

    private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
    );

    private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
        Account.getSObjectType()
        );
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(
      new List<String>{
        'Accounts_Goals_Read_Only',
        'View_Card_Details',
        'View_Transaction_History',
        'Product_Read_Only'
      }
    );
  }

  /**
   * @description initiatePrecheck valid response
   */
  @isTest
  static void testInitiatePrecheckValidResponse() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    success.body = AccountClosureServiceMock.INITIATE_ACCOUNT_CLOSURE_SUCCESS;
    Lib_MockProvider.forType(AccountClosureService.class)
      .mock('initiateAccountClosurePreChecks', success);
    Exception ex = null;
    try {
      new AccountClosureApiRepository()
        .initiateAccountClosurePreChecks(
          '1111', mockCaseRecords()
        );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

   /**
   * @description initiatePrecheck Invalid response
   */
  @isTest
  static void testInitiatePrecheckInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 500;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(AccountClosureService.class)
      .mock('initiateAccountClosurePreChecks', response);
      Exception ex;
      try {
        new AccountClosureApiRepository()
        .initiateAccountClosurePreChecks(
          '1111', mockCaseRecords()
        );
      } catch (Exception e) {
        ex = e;
      }
      Assert.isTrue(
        ex instanceof AccountClosureApiRepository.ServerErrorException,
        'Server Exception should be thrown.'
      );
  }

  /**
   * @description initiatePrecheck Access Error or Invalid Request
   */
  @isTest
  static void testInitiatePrecheckInvalidAccessResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 401;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(AccountClosureService.class)
      .mock('initiateAccountClosurePreChecks', response);
      Exception ex;
      try {
        new AccountClosureApiRepository()
        .initiateAccountClosurePreChecks(
          '1111', mockCaseRecords()
        );
      } catch (Exception e) {
        ex = e;
      }
      Assert.isTrue(
        ex instanceof AccountClosureApiRepository.AccessErrorException,
        'Access Exception should be thrown.'
      );
  }

  /**
   * @description initiatePrecheck Unhandled Error
   */
  @isTest
  static void testInitiatePrecheckUnhandledError() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 404;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(AccountClosureService.class)
      .mock('initiateAccountClosurePreChecks', response);
      Exception ex;
      try {
        new AccountClosureApiRepository()
        .initiateAccountClosurePreChecks(
          '1111', mockCaseRecords()
        );
      } catch (Exception e) {
        ex = e;
      }
      Assert.isTrue(
        ex instanceof AccountClosureApiRepository.AccessErrorException,
        'Access Exception should be thrown.'
      );
  }
  
 

  private static List<Case> mockCaseRecords() {
    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = FAKER_CHILD_CASE_ID,
        AccountId = FAKER_ACCOUNT_ID,
        Status = GetHelpConstants.ESCALATED_STATUS,
        OwnerId = UserInfo.getUserId(),
        ParentId = FAKER_PARENT_CASE_ID,
        RecordTypeId = RTCase.accountClosure,
        FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.getSObjectType()
        ),
        ProductId = Lib_FakeIdGenerator.getMockId(Product2.getSObjectType())
      ),
      new Map<String, Object>{ 'CaseNumber' => '03771916' }
    );
    return new List<Case>{caseRecord};
  }

}