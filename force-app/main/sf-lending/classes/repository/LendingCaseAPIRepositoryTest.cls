/**
 * @author Jaya Srivastava
 * @date Jan 2025
 * @description Test class for {@link LendingCaseAPIRepository}
 */

@isTest
public with sharing class LendingCaseAPIRepositoryTest {
  static Lib_MockProvider lendingCaseServiceMock;

  static void registerMocks() {
    lendingCaseServiceMock = Lib_MockProvider.forType(LendingCaseService.class);
  }

  /**
   * @description Static method to return Case Record
   */
  static Case getCase {
    get {
      case caseRecord = new Case();
      caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRecord.Address__c = 'Test';
      return caseRecord;
    }
  }
  /**
   * @description Static method to return CaseRequestModel
   */
  static LendingCaseRequestModel lendingCaseReqModel {
    get {
      LendingCaseRequestModel lendingCase = new LendingCaseRequestModel(
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
    lendingCaseServiceMock.mock(
      'updateCaseStatusApproveReject',
      successResponse
    );

    Test.startTest();
    LendingCaseAPIRepository lendingCaseApi = new LendingCaseAPIRepository();
    LendingCaseResponseModel responseModel = lendingCaseApi.updateCaseStatusApproveReject(
      getCase,
      lendingCaseReqModel
    );
    Test.stopTest();

    Assert.isTrue(responseModel.approveRejectSuccess, 'Success Response');
  }

  @isTest
  static void testUpdateCaseStatusApproveRejectFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('callout failed');
    lendingCaseServiceMock.mock('updateCaseStatusApproveReject', errorResponse);

    Exception resultException;
    Test.startTest();
    try {
      LendingCaseAPIRepository lendingCaseApi = new LendingCaseAPIRepository();
      lendingCaseApi.updateCaseStatusApproveReject(
        getCase,
        lendingCaseReqModel
      );
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();
    Assert.isTrue(
      resultException instanceof LendingCaseAPIRepository.ServerErrorUpdateCaseStatusApproveRejectException,
      'Exception should be thrown.'
    );
    Assert.areEqual(
      'callout failed',
      resultException.getMessage(),
      'Should throw invalid data exception'
    );
  }
}
