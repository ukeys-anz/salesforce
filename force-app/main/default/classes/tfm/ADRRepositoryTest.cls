/**
 * @author Hinduja Upadhyay
 * @since Sep 2024
 * @description Test class for ADRRepository
 */
@isTest
public with sharing class ADRRepositoryTest {
  @isTest
  static void testgetADRRows() {
    ADRRepository repo = new ADRRepository();
    Test.startTest();
    List<ADRDataTableResponseWrapper> wrapperList = repo.getADRRows();
    Test.stopTest();
    Assert.areNotEqual(
      null,
      wrapperList.size(),
      'API response is null and status is not 200'
    );
  }

  @isTest
  static void testgetADRRowsErrorResp() {
    String exceptionMsg;
    Integer statusCode = 404;
    HttpCalloutResponse res = ADRServiceMock.setMockErrorResponse(statusCode);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    ADRRepository repo = new ADRRepository();
    List<ADRDataTableResponseWrapper> wrapperList = new List<ADRDataTableResponseWrapper>();
    Test.startTest();
    try {
      wrapperList = repo.getADRRows();
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(0, wrapperList.size(), 'API response is not null');
  }

  @isTest
  static void testgetStatus() {
    ADRRepository repo = new ADRRepository();
    Test.startTest();
    String statusValue = repo.getStatus('ACTIVE');
    Test.stopTest();
    Assert.areEqual(
      ADRRepository.ACTIVE_ADR_VALUE,
      statusValue,
      'Error in fetching status value'
    );
  }

  @isTest
  static void testgetDateTime() {
    ADRRepository repo = new ADRRepository();
    Test.startTest();
    String dateTimeValue = repo.getDateTime('2023-11-20T05:12:57.394Z');
    Test.stopTest();
    Assert.areNotEqual(null, dateTimeValue, 'Date Value is null');
  }

  @isTest
  static void testgetADRList() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.realm = 'system';
    ADRServiceMock mock = new ADRServiceMock();
    HttpCalloutResponse res = mock.getADRRows(staffModel);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    ADRResponseModel aDRResponse = ADRResponseModel.parse(res.body);
    List<ADRResponseModel.Result> resultList = (List<ADRResponseModel.Result>) aDRResponse.result;
    ADRRepository repo = new ADRRepository();
    Test.startTest();
    List<ADRDataTableResponseWrapper> wrapperList = repo.getADRList(resultList);
    Test.stopTest();
    Assert.areNotEqual(
      0,
      wrapperList.size(),
      'Response was not set sucessfully in model class'
    );
  }

  @isTest
  static void testperformADRAction() {
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'suspend';
    ADRRepository repo = new ADRRepository();
    HttpCalloutResponse response = new HttpCalloutResponse();
    Test.startTest();
    response = repo.performADRAction(rspId, actionToPerform);
    Test.stopTest();
    Assert.areEqual(200, response.statusCode, 'CallOut is not successfully');
  }

  @isTest
  static void testperformADRActionError() {
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'suspend';
    String exceptionMsg;
    Integer statusCode = 401;
    HttpCalloutResponse res = ADRServiceMock.setMockErrorResponse(statusCode);
    Service s = ServiceProvider.getService(ADRService.class);
    s.setCalloutResponse(res);
    ADRRepository repo = new ADRRepository();
    HttpCalloutResponse response = new HttpCalloutResponse();
    Test.startTest();
    try {
      response = repo.performADRAction(rspId, actionToPerform);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Expecting server error'
    );
  }
}
