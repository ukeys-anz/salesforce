/**
 * @description       :
 * @author            : TFM Squad - Shivraj
 * @group             :
 * @last modified on  : 04-17-2024
 * @last modified by  : TFM Squad - Shivraj
 **/
@isTest
public with sharing class TFMDataINAPIRepositoryTest {
  @isTest
  static void testGetDataINConsentsListAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.getDataINConsentsListAPI(staffModel);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Valid data is returned in response'
    );
  }
  @isTest
  static void testGetDataINConsentsListAPIErrorResp() {
    String exceptionMsg;
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.startTest();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    try {
      HttpCalloutResponse response = repo.getDataINConsentsListAPI(staffModel);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'Server Error',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testGetDataINAccountListAPI() {
    String consentId = 'x00Bm000008L9jfake';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.getDataINAccountListAPI(
      staffModel,
      consentId
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Valid data is returned in response'
    );
  }

  @isTest
  static void testGetDataINAccountListAPIErrorResp() {
    String consentId = 'x00Bm000008L9jfake';
    String exceptionMsg;
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    Test.startTest();
    try {
      HttpCalloutResponse response = repo.getDataINAccountListAPI(
        staffModel,
        consentId
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      'Server Error',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testExportConsentAPI() {
    String consentId = 'x00Bm000008L9jfake';
    String methodName = 'ExportConsentReport';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    Test.startTest();

    HttpCalloutResponse response = repo.exportConsent(
      methodName,
      consentId,
      staffModel
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Valid data is returned in response'
    );
  }

  @isTest
  static void testExportConsentAPIErrorResp() {
    String consentId = 'x00Bm000008L9jfake';
    String methodName = 'ExportConsentReport';
    String exceptionMsg;
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.startTest();

    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    try {
      HttpCalloutResponse response = repo.exportConsent(
        methodName,
        consentId,
        staffModel
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'Server Error',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  private static StaffTokenRequestModel setStaffModel() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = '1122r5421';
    staffModel.anzTokenType = 'staffRqfCustomer';
    Cache.Session.put(
      'local.ForgeToken.forgeJWTToken' + staffModel.idValue,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    return staffModel;
  }

  @isTest
  static void testRevokeConsentAPI() {
    String consentId = 'x00Bm000008L9jfake';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.revokeConsent(consentId, staffModel);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Valid data is returned in response'
    );
  }

  @isTest
  static void testRevokeConsentErrorResp() {
    String consentId = 'x00Bm000008L9jfake';
    String exceptionMsg;
    TFMDataINServiceMock.isError = true;
    TFMDataINServiceMock.throwExceptionResponse = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMDataINAPIRepository repo = new TFMDataINAPIRepository();
    Test.startTest();
    try {
      HttpCalloutResponse response = repo.revokeConsent(consentId, staffModel);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'Server Error',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }
}