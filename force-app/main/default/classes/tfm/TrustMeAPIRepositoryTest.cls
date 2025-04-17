/**
 * @author Shivraj Kadam
 * @since Apr 2025
 * @description Test Class for - TrustMeAPIRepository
 */
@isTest
public with sharing class TrustMeAPIRepositoryTest {
  @isTest
  static void testUpdateStatusSuccess() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('updateCaseStatus', res);

    TrustMeCaseUpdateModel caseUpdateDetails = new TrustMeCaseUpdateModel();
    caseUpdateDetails.evaluation_id = '1234';
    caseUpdateDetails.state = 'MANUAL_REVIEW_STATE_APPROVED';
    caseUpdateDetails.checks = null;

    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.updateCaseStatus(caseUpdateDetails);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testUpdateStatusServerError() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('updateCaseStatus', res);

    TrustMeCaseUpdateModel caseUpdateDetails = new TrustMeCaseUpdateModel();
    caseUpdateDetails.evaluation_id = '1234';
    caseUpdateDetails.state = 'MANUAL_REVIEW_STATE_APPROVED';
    caseUpdateDetails.checks = null;

    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.updateCaseStatus(caseUpdateDetails);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        TrustMeAPIRepository.ServerErrorException.class,
        'No Server error occurred.'
      );
    }
  }

  @isTest
  static void testUpdateStatusInsufficientAccessError() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('updateCaseStatus', res);

    TrustMeCaseUpdateModel caseUpdateDetails = new TrustMeCaseUpdateModel();
    caseUpdateDetails.evaluation_id = '1234';
    caseUpdateDetails.state = 'MANUAL_REVIEW_STATE_APPROVED';
    caseUpdateDetails.checks = null;

    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.updateCaseStatus(caseUpdateDetails);
      Test.stopTest();
      Assert.fail('InsufficientAccessException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        TrustMeAPIRepository.InsufficientAccessException.class,
        'No InsufficientAccessException occurred.'
      );
    }
  }

  @isTest
  static void testGetTrustMeDocumentsSuccess() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getTrustMeDocuments', res);

    TrustMeDocumentRequestModel requestModel = new TrustMeDocumentRequestModel();
    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.getTrustMeDocuments(requestModel);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testGetTrustMeDocumentsServerError() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getTrustMeDocuments', res);

    TrustMeDocumentRequestModel requestModel = new TrustMeDocumentRequestModel();
    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.getTrustMeDocuments(requestModel);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        TrustMeAPIRepository.ServerErrorException.class,
        'No Server error occurred.'
      );
    }
  }

  @isTest
  static void testGetTrustMeDocumentsInsufficientAccessError() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getTrustMeDocuments', res);

    TrustMeDocumentRequestModel requestModel = new TrustMeDocumentRequestModel();
    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.getTrustMeDocuments(requestModel);
      Test.stopTest();
      Assert.fail('InsufficientAccessException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        TrustMeAPIRepository.InsufficientAccessException.class,
        'No InsufficientAccessException occurred.'
      );
    }
  }

  @isTest
  static void testGetEvaluationDetailsSuccess() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    res.body = Service.getStaticResource('trustMeMock');
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getEvaluationDetails', res);

    try {
      Test.startTest();
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      TrustMeDocumentDetailsModel responseData = repo.getEvaluationDetails(
        '5cd2784f-f492-453f-a58e-ea054c5d07e4'
      );
      Assert.areEqual(
        '5cd2784f-f492-453f-a58e-ea054c5d07e4',
        responseData.evaluationOutcome.id,
        'Evaluation Id is incorrect'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testGetEvaluationDetailsServerError() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.error = new DMLException('exceptionText');
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getEvaluationDetails', res);

    try {
      Test.startTest();
      TrustMeAPIRepository.ServerErrorException serverErrorExcep = new TrustMeAPIRepository.ServerErrorException(
        res
      );
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.getEvaluationDetails('evalId');

      Test.stopTest();
      Assert.isNotNull(serverErrorExcep, 'ServerErrorException not called');
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        TrustMeAPIRepository.ServerErrorException.class,
        'No Server error occurred.'
      );
    }
  }

  @isTest
  static void testGetEvaluationDetailsInsufficientAccessError() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    res.error = new DMLException('exceptionText');
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getEvaluationDetails', res);

    try {
      Test.startTest();
      TrustMeAPIRepository.InsufficientAccessException insufficientAccessExcep = new TrustMeAPIRepository.InsufficientAccessException(
        res
      );
      TrustMeAPIRepository repo = new TrustMeAPIRepository();
      repo.getEvaluationDetails('evalId');
      Test.stopTest();
      Assert.isNotNull(insufficientAccessExcep, 'InsufficientAccessException not called');
      Assert.fail('InsufficientAccessException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        TrustMeAPIRepository.InsufficientAccessException.class,
        'No InsufficientAccessException occurred.'
      );
    }
  }
}