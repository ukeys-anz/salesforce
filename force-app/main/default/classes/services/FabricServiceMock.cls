/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Mock implementation of fabric api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 */
public with sharing class FabricServiceMock extends Service {
  @TestVisible
  private static final String ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE = '{\"accountList\":[{\"accountNumber\":\"000000000\",\"bsb\":\"111111\",\"name\":\"FAKE S\",\"balance\":{\"currency\":\"AUD\",\"value\":\"$259\"},\"currentBalance\":{\"currency\":\"AUD\",\"value\":\"$259\"},\"balanceValidAsOf\":\"2021-02-09T23:18:09.559214981Z\",\"openDate\":\"2020-08-14\",\"openDateTime\":\"2020-08-14T02:53:39.399216613Z\",\"accountType\":\"Transaction\"},{\"accountNumber\":\"111111111\",\"bsb\":\"111111\",\"name\":\"FAKE S\",\"balance\":{\"currency\":\"AUD\",\"value\":\"$598.99\"},\"currentBalance\":{\"currency\":\"AUD\",\"value\":\"$598.99\"},\"balanceValidAsOf\":\"2021-02-09T23:18:09.559221757Z\",\"openDate\":\"2020-08-13\",\"openDateTime\":\"2020-08-13T06:42:03.318380789Z\",\"accountType\":\"Savings\",\"goal\":{\"name\":\"House construction\\n\",\"iconId\":\"\ud83d\ude18\",\"startDate\":\"2020-08-13\",\"startDateTime\":\"2020-08-13T06:42:03.380747219Z\",\"themeId\":\"11103f1f-4631-43ba-a1cf-d3c0cbd8ef1d\",\"themeColour\":\"#FFFFFF\",\"targetDate\":\"2023-02-04\",\"targetDateTime\":\"2023-02-04T05:46:55Z\",\"targetAmount\":{\"currency\":\"AUD\",\"value\":\"$5,000\"}}}]}';
  /**
   * @description construct a mock with hardcoded success value
   */
  public FabricServiceMock() {
    response.statusCode = 200;
    response.body = FabricServiceMock.ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE;
    response.successful = true;
  }

  public override HttpCalloutResponse getAccountsAndGoals(String ocvId) {
    return response;
  }
}
