/**
 * @author Hinduja Upadhyay
 * @since Jan 2024
 * @description Test class for TFMSearchCustomerAPIRepositoryTest
 */
@SuppressWarnings('PMD.AvoidNonExistentAnnotations')
@isTest
public with sharing class TFMSearchCustomerAPIRepositoryTest {
  @isTest
  static void testgetValidStaffToken() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    Map<String, String> headers = new Map<String, String>();
    staffModel.headers = headers;
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = '1111';
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.action = 'SearchCustomer';
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    Test.startTest();
    headers = repo.getValidStaffToken(staffModel);
    Assert.areNotEqual(headers, null, 'headers not null');
    Test.stopTest();
  }

  @isTest
  static void testsearchCustAPI() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = '1111';
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.action = 'SearchCustomer';
    TFMSearchCustomerAPIRepository repo = new TFMSearchCustomerAPIRepository();
    Test.startTest();
    HttpCalloutResponse response = repo.searchCustAPI(staffModel);
    Assert.areNotEqual(response, null, 'response not null');
    Test.stopTest();
  }
}
