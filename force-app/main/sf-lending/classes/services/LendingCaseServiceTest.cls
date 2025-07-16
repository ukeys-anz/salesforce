/**
 * @author Jaya Srivastava
 * @date Nov 2024
 * @description Test class for {@link LendingCaseService}
 */

@isTest
public with sharing class LendingCaseServiceTest {
  static Lib_MockProvider calloutMock;

  static void registerMocks() {
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  /**
   * @description Static method to return Case Record
   */
  static Case getCase {
    get {
      return new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        Address__c = 'Test',
        Account = getAccount,
        FinServ__FinancialAccount__r = getFinancialAccount,
        Loan_Account_Change_Number__c = 'accounts_391450876_changes_aa15100e-ce05-4c2e-bbc4-b9d1031da112'
      );
    }
  }

  /**
   * @description Static method to return Account
   */
  static Account getAccount {
    get {
      return new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Loan Account',
        OCV_Id__c = '1234'
      );
    }
  }

  /**
   * @description Static method to return FinServ__FinancialAccount__c
   */
  static FinServ__FinancialAccount__c getFinancialAccount {
    get {
      return new FinServ__FinancialAccount__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.SObjectType
        ),
        FinServ__FinancialAccountNumber__c = '391450876'
      );
    }
  }

  /**
   * @description Static method to return LendingCaseRequestModel
   */
  static LendingCaseRequestModel lendingCaseReqModel {
    get {
      LendingCaseRequestModel lendingCase = new LendingCaseRequestModel();
      lendingCase.approval = new LendingCaseRequestModel.Approval(
        'STATE_APPROVED'
      );
      return lendingCase;
    }
  }

  @isTest
  static void testUpdateCaseStatusApproveRejectSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_SubmitLoanAccountChangeApproval'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;
    calloutMock.mock('makeRestCallout', successResponse);

    String ocvId = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    LendingCaseService service = new LendingCaseService();
    HttpCalloutResponse response = service.updateCaseStatusApproveReject(
      getCase,
      lendingCaseReqModel
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.areEqual(
      JSON.serialize(lendingCaseReqModel),
      (String) calloutMock.getHistory('makeRestCallout')
        .getParam('requestBody'),
      'Request body should be serialized request'
    );
  }

  @isTest
  static void testUpdateCaseStatusApproveRejectFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');
    calloutMock.mock('makeRestCallout', errorResponse);

    String ocvId = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LendingCaseService service = new LendingCaseService();
    HttpCalloutResponse response = service.updateCaseStatusApproveReject(
      getCase,
      lendingCaseReqModel
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isFalse(response.successful, 'Response should be error');
    Assert.areEqual(
      500,
      response.statusCode,
      'Status code of the response should be 500'
    );
  }
}
