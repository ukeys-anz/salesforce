/**
 * @author Hitesh
 * @since July 2025
 * @description unit testing class for FinancialSummaryService class
 * @group Service
 */
@isTest
private class FinancialSummaryServiceTest {
  @isTest
  static void generateHeaderTest() {
    Test.startTest();
    Map<String, String> headers = FinancialSummaryService.generateHeader();
    Test.stopTest();
    Assert.areEqual(
      'DCRM',
      headers.get('Channel'),
      'Channel value is not correct in header'
    );
    Assert.areEqual(
      System.Label.Customer_Auth_Workstation,
      headers.get('X-Workstation'),
      'Workstation value is not correct in header'
    );
    Assert.areEqual(
      System.Label.Customer_Auth_Originating_App,
      headers.get('X-Originating-App'),
      'Originating app value is not correct in header'
    );
  }

  @isTest
  static void generateHeaderForStaffTokenTest() {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      AuthTokenCacheUtil.getHashedKey('forgeJWTToken' + '' + 'DCRM_FinSummary'),
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    Map<String, String> headers = FinancialSummaryService.generateHeaderForStaffToken();
    Test.stopTest();
    Assert.areEqual(
      '1234',
      headers.get('X-Operator-Branch'),
      'Operator value is not correct in header'
    );
    Assert.areEqual(
      'CRM',
      headers.get('X-Originating-App'),
      'Originating app value is not correct in header'
    );
  }
}
