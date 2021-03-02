@isTest
public inherited sharing class CoachBankingAPIRepositoryTest {
  /**
   * @description fetch valid accounts, mocked values in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void validResponse() {
    Test.startTest();
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    AccountsAndGoalsModel model = coachapi.getAccounts('1111');
    Test.stopTest();

    System.assertEquals(2, model.accountList.size());
    System.assertEquals('000000000', model.accountList[0].accountNumber);
  }

  /**
   * @description fetch invalid accounts
   */
  @isTest
  static void invalidResponse() {
    AccountsAndGoalsModel model;
    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(FabricService.class);
    s.setCalloutResponse(res);
    Exception resultException;
    Test.startTest();
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    try {
      model = coachapi.getAccounts('1111');
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals('Get accounts failed', resultException.getMessage());
  }

  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get accounts failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  /**
   * @description fetch valid accounts, mocked values in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void auraResponse() {
    Test.startTest();
    AccountsAndGoalsModel model = CoachBankingAPIRepository.getAccountsAura(
      '1111'
    );
    Test.stopTest();

    System.assertEquals(2, model.accountList.size());
    System.assertEquals('000000000', model.accountList[0].accountNumber);
  }
}
