/**
 * @author Shivraj - TFM
 * @since Nov 2024
 * @description Test class for OpenBankingAPIRepository
 */
@isTest
public with sharing class OpenBankingAPIRepositoryTest {
  @isTest
  public static void testgetConsentDataSharingHistory() {
    Test.startTest();
    String consentId = 'x00Bm000008L9jfake';
    String fromTimestamp = 'fakeTS';
    String toTimestamp = 'fakeTS';
    StaffTokenRequestModel staffModel = setStaffModel();
    OpenBankingAPIRepository repo = new OpenBankingAPIRepository();
    HttpCalloutResponse response = repo.getConsentDataSharingHistory(
      consentId,
      fromTimestamp,
      toTimestamp,
      staffModel
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Valid data is not returned in response'
    );
  }

  @isTest
  public static void testgetConsentDataSharingHistoryErrorResp() {
    HttpCalloutResponse res = TFMSearchCustomerServiceMock.setMockErrorResponse();
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    s.setCalloutResponse(res);
    String exceptionMsg;
    Test.startTest();
    TFMSearchCustomerServiceMock.isError = true;
    String consentId = 'x00Bm000008L9jfake';
    String fromTimestamp = 'fakeTS';
    String toTimestamp = 'fakeTS';
    StaffTokenRequestModel staffModel = setStaffModel();
    OpenBankingAPIRepository repo = new OpenBankingAPIRepository();
    try {
      repo.getConsentDataSharingHistory(
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
      'Script-thrown exception',
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