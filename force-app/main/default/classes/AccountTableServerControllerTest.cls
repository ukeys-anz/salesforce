/**
 *
 * @author Lance Shi
 * @since 2020
 * @description AccountTableServerController is the test class to cover tests for {@link AccountTableServerController}
 */

@isTest
public class AccountTableServerControllerTest {
  private static final String SUCCESS_RESPONSE_BODY = '{"account_list":[{"account_number":"1232343","bsb":"013434","name":"test","balance":{"currency_code":"AUD","value":"1000.24"},"balance_valid_asof":"2017-07-21T17:32:28Z"}]}';

  /**
   * @description testGetAccInfo is to test success response including deserialising JSON to Map
   */
  @isTest
  public static void testGetAccInfo() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(200, SUCCESS_RESPONSE_BODY)
    );

    List<AccountTableServerController.AccountInfo> accList = AccountTableServerController.getAccInfo();
    System.assertEquals(1, accList.size());
  }

  /**
   * @description testGetAccInfoException is to test error response with exception handling
   */
  @isTest
  public static void testGetAccInfoException() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(new JSONException('Test Exception'))
    );

    Test.startTest();
    try {
      List<AccountTableServerController.AccountInfo> accList = AccountTableServerController.getAccInfo();
    } catch (Exception e) {
      System.Assert(
        e.getMessage().equals('Test Exception'),
        'Exception thrown: ' + e.getMessage()
      );
    }

    Test.stopTest();

    List<Application_Log__c> appLog = [
      SELECT Id, Request_Body__c
      FROM Application_Log__c
    ];
    System.assertEquals(1, appLog.size(), 'Matches the log record size');
  }
}
