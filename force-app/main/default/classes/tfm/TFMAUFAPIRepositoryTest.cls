/**
 * @author Hinduja Upadhyay
 * @since Jan 2024
 * @description Test class for TFMAUFAPIRepositoryTest
 */
@isTest
public with sharing class TFMAUFAPIRepositoryTest {
  @isTest
  static void testupdatePinStatus() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String pinRefId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    String action = 'Locked';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.updatePinStatus(
      staffModel,
      pinRefId,
      action
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }
  @isTest
  static void testupdatePinStatusErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String pinRefId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    String action = 'Locked';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
        repo.updatePinStatus(
        staffModel,
        pinRefId,
        action
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testupdateStatus() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String status = TFMConstants.UNSUSPEND;
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.updateStatus(staffModel, status);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }
  @isTest
  static void testupdateStatusErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String status = TFMConstants.UNSUSPEND;
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
      repo.updateStatus(staffModel, status);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testupdateMobileNumber() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '40122344656';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.updateMobileNumber(staffModel, value);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }
  @isTest
  static void testupdateMobileNumberErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '40122344656';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
      repo.updateMobileNumber(staffModel, value);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testupdateOcvid() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '100000000';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.updateOcvid(staffModel, value);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }
  @isTest
  static void testupdateOcvidErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '100000000';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
      repo.updateOcvid(staffModel, value);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testderegisterDevice() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String deviceResourceId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.deregisterDevice(
      staffModel,
      deviceResourceId
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }
  @isTest
  static void testderegisterDeviceResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String deviceResourceId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
        repo.deregisterDevice(
        staffModel,
        deviceResourceId
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testResetPin() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String pin = '203040';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.resetPin(staffModel, pin);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }
  @isTest
  static void testResetPinErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String pin = '203040';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
      repo.resetPin(staffModel, pin);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testArchiveUser() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String status = TFMConstants.ARCHIVED;
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.archiveUser(staffModel, status);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code is not equal to 200'
    );
  }

  @isTest
  static void testArchiveUserErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String status = TFMConstants.ARCHIVED;
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
      repo.archiveUser(staffModel, status);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
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
  static void testupdateMobileNumberDuplicateErrorResp() {
    String exceptionMsg;
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponseDuplicateMobile();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '40122344656';
    TFMAUFAPIRepository repo = new TFMAUFAPIRepository();
    Test.startTest();
    try {
      repo.updateMobileNumber(staffModel, value);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      TFMConstants.ERROR_OCCURRED,
      exceptionMsg,
      'Mobile number should be duplicate.'
    );
  }
}