/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 06-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class AUFAPIRepositoryTest {
  @isTest
  static void updatePinStatus() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updatePinStatus', res);

    String pinRefId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    String action = 'Locked';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updatePinStatus(uuid, pinRefId, action);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void updatePinStatusErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.error = new DMLException('exceptionText');
    Lib_MockProvider.forType(TFMAUFService.class).mock('updatePinStatus', res);

    String pinRefId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    String action = 'Locked';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updatePinStatus(uuid, pinRefId, action);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ServerErrorException.class,
        'ServerErrorException expected.'
      );
    }
  }

  @isTest
  static void updatePinStatusInsufficientErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    res.error = new DMLException('exceptionText');
    Lib_MockProvider.forType(TFMAUFService.class).mock('updatePinStatus', res);

    String pinRefId = 'F7AE26D3-5AFA-427D-9DDC-fake';
    String action = 'Locked';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updatePinStatus(uuid, pinRefId, action);
      Test.stopTest();
      Assert.fail('InsufficientAccessException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.InsufficientAccessException.class,
        'InsufficientAccessException excepted.'
      );
    }
  }

  @isTest
  static void testupdateStatus() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateStatus', res);

    String status = 'Locked';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateStatus(uuid, status);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }
  @isTest
  static void testupdateStatusErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateStatus', res);

    String status = 'Locked';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateStatus(uuid, status);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ServerErrorException.class,
        'serverErrorException expected.'
      );
    }
  }

  @isTest
  static void testupdateMobileNumber() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TFMAUFService.class)
      .mock('updateMobileNumber', res);

    String value = '40122344656';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateMobileNumber(uuid, value);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }
  @isTest
  static void testupdateMobileNumberErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TFMAUFService.class)
      .mock('updateMobileNumber', res);

    String value = '40122344656';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateMobileNumber(uuid, value);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ServerErrorException.class,
        'serverErrorException expected.'
      );
    }
  }

  @isTest
  static void testupdateOcvid() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateOcvid', res);

    String value = '100000000';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateOcvid(uuid, value);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }
  @isTest
  static void testupdateOcvidErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateOcvid', res);
    String value = '100000000';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateOcvid(uuid, value);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ServerErrorException.class,
        'serverErrorException expected.'
      );
    }
  }
  @isTest
  static void testResetPin() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TFMAUFService.class).mock('resetPin', res);

    String pin = '203040';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.resetPin(uuid, pin);
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }
  @isTest
  static void testResetPinErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TFMAUFService.class).mock('resetPin', res);
    String pin = '203040';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();

      repo.resetPin(uuid, pin);
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ServerErrorException.class,
        'serverErrorException excepted.'
      );
    }
  }

  @isTest
  static void testResetPinErrorBadPinResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 400;
    res.error = new DMLException(
      '{\"code\":\"ERROR\",\"message\":\"400 Bad Request\",\"additionalInfo\":{\"reason\":\"APP:BAD_REQUEST_ERROR\",\"category\":\"TECHNICAL\",\"errorDetails\":{\"error\":{\"code\":\"20004\",\"description\":\"Pin history check failed\",\"details\":[{\"name\":\"pin\",\"reason\":\"Pin history check failed\"}]}}}}'
    );
    Lib_MockProvider.forType(TFMAUFService.class).mock('resetPin', res);
    String pin = '203040';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.resetPin(uuid, pin);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ResetPinBadException.class,
        'resetPinBadException expected.'
      );
    }
  }

  @isTest
  static void testArchiveUser() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateStatus', res);

    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.archiveUser(uuid, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception expected');
    }
  }

  @isTest
  static void testArchiveUserErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateStatus', res);
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();

      repo.archiveUser(uuid, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.InsufficientAccessException.class,
        'insufficientExceptionError expected.'
      );
    }
  }

  @isTest
  static void testArchiveUserErrorArchiveResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.error = new DMLException('exceptionText');
    Lib_MockProvider.forType(TFMAUFService.class).mock('updateStatus', res);
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.archiveUser(uuid, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.ArchiveFailException.class,
        'serverErrorException excepted.'
      );
    }
  }

  @isTest
  static void testupdateMobileNumberDuplicateErrorResp() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 409;
    res.error = new DMLException('exceptionText');
    Lib_MockProvider.forType(TFMAUFService.class)
      .mock('updateMobileNumber', res);
    String value = '40122344656';
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';

    AUFAPIRepository repo = new AUFAPIRepository();
    try {
      Test.startTest();
      repo.updateMobileNumber(uuid, value);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AUFAPIRepository.DuplicateMobileNumberException.class,
        'duplicateNumberException expected.'
      );
    }
  }
}
