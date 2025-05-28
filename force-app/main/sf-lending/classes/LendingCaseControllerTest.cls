/**
 *
 * @author Jaya Srivastava
 * @since Jan 2025
 * @description Test class for {@link LendingCaseController)
 */

@isTest
public with sharing class LendingCaseControllerTest {
  static Lib_MockProvider lendingCaseRefinance;
  static Lib_MockProvider lendingCaseAPIRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    lendingCaseRefinance = Lib_MockProvider.forType(LendingCaseRepository.class)
      .mock('queryCaseByRecordId', getCase);
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    lendingCaseAPIRepoMock = Lib_MockProvider.forType(
      LendingCaseAPIRepository.class
    );
  }

  /**
   * @description Static method to return Case Record
   */
  static Case getCase {
    get {
      case caseRecord = new Case();
      caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRecord.Address__c = 'Test';
      caseRecord.Status = 'New';
      return caseRecord;
    }
  }

  @isTest
  static void testUpdateCaseStatusApproveSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    LendingCaseResponseModel mockLendingCase = new LendingCaseResponseModel(
      true,
      true
    );
    lendingCaseAPIRepoMock.mock(
      'updateCaseStatusApproveReject',
      mockLendingCase
    );
    Test.startTest();
    LendingCaseResponseModel response = LendingCaseController.updateCaseStatusApproveReject(
      'STATE_APPROVED',
      recordId
    );
    Test.stopTest();
    Assert.isTrue(response.approveRejectSuccess, 'Success Response');
  }

  @isTest
  static void testUpdateCaseStatusRejectSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    LendingCaseResponseModel mockLendingCase = new LendingCaseResponseModel(
      true,
      true
    );
    lendingCaseAPIRepoMock.mock(
      'updateCaseStatusApproveReject',
      mockLendingCase
    );
    Test.startTest();
    LendingCaseResponseModel response = LendingCaseController.updateCaseStatusApproveReject(
      'STATE_REJECTED',
      recordId
    );
    Test.stopTest();
    Assert.isTrue(response.approveRejectSuccess, 'Success Response');
  }

  @isTest
  static void testUpdateCaseStatusApproveRejectFailure() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    LendingCaseResponseModel mockLendingCase = new LendingCaseResponseModel(
      false,
      false
    );
    lendingCaseAPIRepoMock.mock(
      'updateCaseStatusApproveReject',
      mockLendingCase
    );
    Test.startTest();
    LendingCaseResponseModel response = LendingCaseController.updateCaseStatusApproveReject(
      '',
      recordId
    );
    Test.stopTest();
    Assert.isFalse(response.approveRejectSuccess, 'Failure Response');
  }

  @isTest
  static void testUpdateCaseStatusApproveRejectException() {
    HttpCalloutResponse res = getInvalidUpdateResponse();
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    lendingCaseAPIRepoMock.mock('updateCaseStatusApproveReject', res);
    Test.startTest();
    LendingCaseResponseModel response = LendingCaseController.updateCaseStatusApproveReject(
      'STATE_REJECTED',
      recordId
    );
    Test.stopTest();
    Assert.isFalse(response.approveRejectSuccess, 'Failure Response');
  }

  @isTest
  static void testUpdateCaseStatusApproveRejectPartialSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    LendingCaseResponseModel mockLendingCase = new LendingCaseResponseModel(
      true,
      false
    );
    lendingCaseAPIRepoMock.mock(
      'updateCaseStatusApproveReject',
      mockLendingCase
    );
    dmlMockProvider.mockException(
      'doUpdate',
      new AuraHandledException('Update failed!')
    );
    Test.startTest();
    LendingCaseResponseModel response = LendingCaseController.updateCaseStatusApproveReject(
      'STATE_APPROVED',
      recordId
    );
    Test.stopTest();
    Assert.isFalse(response.caseUpdateSuccess, 'Case update Failed');
    Assert.isTrue(response.approveRejectSuccess, 'API Callout was successful');
  }

  private static HttpCalloutResponse getInvalidUpdateResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Invalid Details');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
