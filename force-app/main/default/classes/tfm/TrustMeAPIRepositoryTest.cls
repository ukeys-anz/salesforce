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
}