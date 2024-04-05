/**
 * @author Hinduja Upadhyay
 * @since Jan 2024
 * @description Test class for TFMSearchCustomerAPIRepositoryTest
 */
@isTest
public with sharing class TFMSearchCustomerAPIRepositoryTest {
  @isTest
  static void testsearchCustAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    staffModel.anzTokenType = 'staffRqfCustomer';
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    Test.startTest();
    TFMPersonDigitalIdentityModel response = repo.searchCustAPI(staffModel);
    Assert.areNotEqual(
      response.result,
      null,
      'Valid data is not returned in response'
    );
    Test.stopTest();
  }

  @isTest
  static void testgetDeviceDetailsWithoutBiometric() {
    StaffTokenRequestModel staffModel = setStaffModel();
    staffModel.anzTokenType = 'staffRqfCustomer';
    String userInternalId = 'fakeXXX';
    String deviceResourceId = 'fakeXXX';
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.getDeviceDetailsWithoutBiometric(
      staffModel,
      userInternalId,
      deviceResourceId
    );
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
    Test.stopTest();
  }

  @isTest
  static void testgetDeviceDetailsWithBiometric() {
    StaffTokenRequestModel staffModel = setStaffModel();
    staffModel.anzTokenType = 'staffRqfCustomer';
    String userInternalId = 'fakeXXX';
    String appCorrelationId = 'fakeXXX';
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.getDeviceDetailsWithBiometric(
      staffModel,
      userInternalId,
      appCorrelationId
    );
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
    Test.stopTest();
  }

  @isTest
  static void testGetJointAccountPermissions() {
    Test.startTest();
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.getJointAccountPermissions(staffModel);
    Test.stopTest();
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
  }

  @isTest
  static void testGetJointAccountPermissionsErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.getJointAccountPermissions(
        staffModel
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testupdatedisclosureStatus() {
    Test.startTest();
    String bsb = '000011';
    String accountNumber = '000000011';
    Boolean enabled = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.updatedisclosureStatus(
      bsb,
      accountNumber,
      enabled,
      staffModel
    );
    Test.stopTest();
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
  }

  @isTest
  static void testupdatedisclosureStatusErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    String bsb = '000011';
    String accountNumber = '000000011';
    Boolean enabled = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.updatedisclosureStatus(
        bsb,
        accountNumber,
        enabled,
        staffModel
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testgetORModifyJointAccountNotificationAPI() {
    Test.startTest();
    String accountId = 'testst';
    Boolean emailEnabled = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.getORModifyJointAccountNotificationAPI(
      staffModel,
      accountId,
      emailEnabled
    );
    Test.stopTest();
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
  }

  @isTest
  static void testgetORModifyJointAccountNotificationAPIErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    String accountId = 'testst';
    Boolean emailEnabled = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.getORModifyJointAccountNotificationAPI(
        staffModel,
        accountId,
        emailEnabled
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testgetConsentAccountList() {
    Test.startTest();
    String consentAccounts =
      '[' +
      '{' +
      '"bsb": "014111",' +
      '"accountNumber": "391077004",' +
      '"displayName": "ANZ Plus",' +
      '"state": "STATE_ELIGIBLE"' +
      '},' +
      '{' +
      '"bsb": "014111",' +
      '"accountNumber": "391077012",' +
      '"displayName": "ANZ Save",' +
      '"state": "STATE_ELIGIBLE"' +
      '}' +
      ']';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.getConsentAccountList(
      staffModel,
      consentAccounts
    );
    Test.stopTest();
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
  }

  @isTest
  static void testgetConsentAccountListErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    String consentAccounts =
      '[' +
      '{' +
      '"bsb": "014111",' +
      '"accountNumber": "391077004",' +
      '"displayName": "ANZ Plus",' +
      '"state": "STATE_ELIGIBLE"' +
      '},' +
      '{' +
      '"bsb": "014111",' +
      '"accountNumber": "391077012",' +
      '"displayName": "ANZ Save",' +
      '"state": "STATE_ELIGIBLE"' +
      '}' +
      ']';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.getConsentAccountList(
        staffModel,
        consentAccounts
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testrevokeConsents() {
    Test.startTest();
    String arrangementId = 'x00Bm000008L9jfake';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.revokeConsent(
      arrangementId,
      staffModel
    );
    Test.stopTest();
    Assert.areEqual(
      response.statusCode,
      200,
      'API Response return with a Successful 200'
    );
  }
  @isTest
  static void testrevokeConsentsErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    String arrangementId = 'x00Bm000008L9jfake';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.revokeConsent(
        arrangementId,
        staffModel
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  static void testgetConsentsList() {
    Test.startTest();
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.getConsentsList(staffModel);
    Test.stopTest();
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
  }

  @isTest
  static void testgetConsentsListErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.getConsentsList(staffModel);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
      exceptionMsg,
      'Status code is not equal to 401'
    );
  }

  @isTest
  public static void testgetConsentDataSharingHistory() {
    Test.startTest();
    String consentId = 'x00Bm000008L9jfake';
    String fromTimestamp = 'fakeTS';
    String toTimestamp = 'fakeTS';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = repo.getConsentDataSharingHistory(
      consentId,
      fromTimestamp,
      toTimestamp,
      staffModel
    );
    Test.stopTest();
    Assert.areNotEqual(
      response,
      null,
      'Valid data is not returned in response'
    );
  }

  @isTest
  public static void testgetConsentDataSharingHistoryErrorResp() {
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    String consentId = 'x00Bm000008L9jfake';
    String fromTimestamp = 'fakeTS';
    String toTimestamp = 'fakeTS';
    StaffTokenRequestModel staffModel = setStaffModel();
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = repo.getConsentDataSharingHistory(
        consentId,
        fromTimestamp,
        toTimestamp,
        staffModel
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      'UNAUTHORIZED',
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
}
