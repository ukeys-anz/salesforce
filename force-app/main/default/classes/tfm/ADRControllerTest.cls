/**
 * @description       : Test class for ADRController
 * @author            : Hinduja Upadhyay
 * @group             : TFM
 * @last modified on  : 09-24-2024
 **/
@isTest
public with sharing class ADRControllerTest {
  @isTest
  static void testgetDataFromApi() {
    List<ADRDataTableResponseWrapper> wrapperList = new List<ADRDataTableResponseWrapper>();
    Test.startTest();
    wrapperList = ADRController.getDataFromApi('');
    Test.stopTest();
    Assert.areNotEqual(0, wrapperList.size(), 'API callout is unsuccessful.');
  }

  @isTest
  static void testgetDataFromApiServerError() {
    String exceptionMsg = 'serverError';
    Integer statusCode = 500;
    HttpCalloutResponse res = ADRServiceMock.setMockErrorResponse(statusCode);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    List<ADRDataTableResponseWrapper> wrapperList = new List<ADRDataTableResponseWrapper>();
    Test.startTest();
    wrapperList = ADRController.getDataFromApi('');
    ADRDataTableResponseWrapper wrapperEle = wrapperList[0];
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      wrapperEle.isError,
      'No exception has occurred, expecting 500 for server error'
    );
  }

  @isTest
  static void testgetDataFromApi401Error() {
    String exceptionMsg = 'insufficientAccess';
    Integer statusCode = 401;
    HttpCalloutResponse res = ADRServiceMock.setMockErrorResponse(statusCode);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    List<ADRDataTableResponseWrapper> wrapperList = new List<ADRDataTableResponseWrapper>();
    Test.startTest();
    wrapperList = ADRController.getDataFromApi('');
    ADRDataTableResponseWrapper wrapperEle = wrapperList[0];
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      wrapperEle.isError,
      'No exception has occurred, expecting 401 for Insufficient access'
    );
  }

  @isTest
  static void testperformADRAction() {
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'suspend';
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ADRController.performADRAction(rspId, actionToPerform);
    Test.stopTest();

    Assert.areEqual(
      'Success',
      response.get('status'),
      'API callout is unsuccessful.'
    );
  }

  @isTest
  static void testperformADRActionError() {
    String exceptionMsg = 'The server encountered an unexpected error. Please retry after some time.';
    Integer statusCode = 404;
    HttpCalloutResponse res = ADRServiceMock.setMockErrorResponse(statusCode);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'unsuspend';
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ADRController.performADRAction(rspId, actionToPerform);
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'No exception has occurred, expecting 404 for server error'
    );
  }

  @isTest
  static void testperformADRActionError401() {
    String exceptionMsg = 'You don\'t have required permission to perform this action.';
    Integer statusCode = 401;
    HttpCalloutResponse res = ADRServiceMock.setMockErrorResponse(statusCode);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'unsuspend';
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ADRController.performADRAction(rspId, actionToPerform);
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'No exception has occurred, expecting 401 for Insufficient access'
    );
  }
}
