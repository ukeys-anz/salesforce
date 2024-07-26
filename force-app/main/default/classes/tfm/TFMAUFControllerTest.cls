@isTest
public with sharing class TFMAUFControllerTest {
  @isTest
  static void testupdateStatuslocked() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.STATUS_WITH_SMALL_S, 'locked');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('updatePinAndStatus', args);
    Test.stopTest();

    Map<String, Object> payload = (Map<String, Object>) output.get(
      TFMConstants.RESULT
    );
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
  }

  @isTest
  static void testupdateStatus() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.UNSUSPEND);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('updatePinAndStatus', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void testupdateStatusSuspended() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.STATUS_WITH_SMALL_S, 'suspended');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('updatePinAndStatus', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void testupdateStatusSuspendedErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.STATUS_WITH_SMALL_S, 'suspended');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('updatePinAndStatus', args);
    Test.stopTest();
    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);
    Assert.areEqual(false, showToast, 'Error Toast is not displayed');
  }

  @isTest
  static void testupdateStatusArchive() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('archiveUser', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void testupdateStatusArchiveErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('archiveUser', args);
    Test.stopTest();
    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);
    Assert.areEqual(false, showToast, 'Error Toast is not displayed');
  }

  @isTest
  static void testupdateStatusArchiveError2() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.ACTION_NAME, TFMConstants.ERROR);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('archiveUser', args);
    Test.stopTest();

    String totalActiveConsents = (String) output.get(
      TFMConstants.TOTAL_ACTIVE_CONSENTS
    );

    String successfullyArchivedConsents = (String) output.get(
      TFMConstants.SUCCESSFULLY_ARCHIVED_CONSENTS
    );

    Assert.areEqual(
      true,
      totalActiveConsents != successfullyArchivedConsents,
      'Active consents is equal to archived consents.'
    );
  }

  @isTest
  static void updateMobileNumber() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.AUF_MOBILE_NUMBER, '0468150252');
    input.put(TFMConstants.ACTION_NAME, TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void updateMobileNumberErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.AUF_MOBILE_NUMBER, '0468150252');
    input.put(TFMConstants.ACTION_NAME, TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();
    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);
    Assert.areEqual(false, showToast, 'Error Toast is not displayed');
  }

  @isTest
  static void updateOcvid() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.AUF_OCV_ID, '1001298392');
    input.put(TFMConstants.ACTION_NAME, TFMConstants.UPDATE_OCV_NUMBER);
    input.put('action', TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void updateOcvidErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.AUF_OCV_ID, '1001298392');
    input.put(TFMConstants.ACTION_NAME, TFMConstants.UPDATE_OCV_NUMBER);
    input.put('action', TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();
    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);
    Assert.areEqual(false, showToast, 'Error Toast is not displayed');
  }

  @isTest
  static void deregisterDevice() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put('deviceResourceId', 'F7AE26D3-5AFA-427D-9DDC-fake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('deregisterDevice', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void deregisterDeviceErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put('deviceResourceId', 'F7AE26D3-5AFA-427D-9DDC-fake');
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('deregisterDevice', args);
    Test.stopTest();
    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);
    Assert.areEqual(false, showToast, 'Error Toast is not displayed');
  }

  @isTest
  static void callResetPin() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.RESET_PIN_KEY, '203040');
    input.put('action', TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);

    Boolean isValid = (Boolean) output.get(TFMConstants.ISVALID);

    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areEqual(true, showToast, 'Error Toast is displayed');
    Assert.areEqual(
      true,
      isValid,
      'User is not having access to do the operation'
    );
  }

  @isTest
  static void callResetPinErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.RESET_PIN_KEY, '203040');
    input.put('action', TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();

    Boolean showToast = (Boolean) output.get(TFMConstants.SHOWSUCCESSTOAST);
    Assert.areEqual(false, showToast, 'Error Toast is not displayed');
  }

  @isTest
  static void updateMobileNumberDuplicateErrorResp() {
    TFMAUFController controller = new TFMAUFController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(TFMConstants.IDVALUE, 'F7AE26D3-5AFA-427D-9DDC-fake');
    input.put(TFMConstants.AUF_MOBILE_NUMBER, '0400000000');
    input.put(TFMConstants.ACTION_NAME, TFMConstants.UPDATE_MOBILE_NUMBER);
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    HttpCalloutResponse res = TFMAUFServiceMock.setMockErrorResponseDuplicateMobile();
    Service s = ServiceProvider.getService(TFMAUFService.class);
    s.setCalloutResponse(res);
    Test.startTest();
    Object isInvoked = controller.call('updateMobileNumberAndOcvid', args);
    Test.stopTest();
    Boolean duplicateMobileNumber = (Boolean) output.get(
      TFMConstants.DUPLICATE_MOBILE_NUMBER
    );
    Assert.areEqual(
      true,
      duplicateMobileNumber,
      'Mobile Number should be duplicate'
    );
  }
}
