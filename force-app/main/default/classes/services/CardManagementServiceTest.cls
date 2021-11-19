/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description Test class for {@link CardManagementService}
 * @group Services
 */
@isTest
public inherited sharing class CardManagementServiceTest {
  @isTest
  static void getRealService() {
    Test.startTest();
    Service cardManagementService = (Service) ServiceProvider.getService(
      CardManagementService.class
    );
    Test.stopTest();
    System.assert(
      cardManagementService instanceof CardManagementServiceMock,
      false
    );
  }

  @isTest
  static void getBadService() {
    Exception errorException;
    Test.startTest();
    try {
      ServiceProvider.getService('card-manage-service');
    } catch (Exception e) {
      errorException = e;
    }
    Test.stopTest();
    System.assertEquals(
      'No Service class found called [card-manage-service]',
      errorException.getMessage(),
      false
    );
  }

  @isTest
  static void testSetFraudCardStatusSuccess() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.setMock(HttpCalloutMock.class, new MockCardManagementCalloutSuccess());

    Test.startTest();
    CardManagementService service = new CardManagementService();
    Map<String, String> fraudLockInformation = new Map<String, String>{
      'cardNumber' => '123456789',
      'ocvId' => '1111',
      'status' => 'Block CNP',
      'reason' => ''
    };
    HttpCalloutResponse response = service.setFraudCardStatus(
      fraudLockInformation
    );
    Test.stopTest();

    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );

    System.assertEquals(200, response.statusCode, false);
    System.assertEquals(responseMap.get('code'), 'INFO', false);
    System.assertEquals(
      responseMap.get('message'),
      'Request was processed successfully',
      false
    );
  }

  @isTest
  static void testSetFraudCardStatusUnsuccess() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.setMock(
      HttpCalloutMock.class,
      new MockCardManagementCalloutUnsuccess()
    );

    Test.startTest();
    CardManagementService service = new CardManagementService();
    Map<String, String> fraudLockInformation = new Map<String, String>{
      'cardNumber' => '23572357',
      'ocvId' => '1111',
      'status' => 'Block CNP',
      'reason' => ''
    };
    HttpCalloutResponse response = service.setFraudCardStatus(
      fraudLockInformation
    );
    Test.stopTest();

    System.assertEquals(500, response.statusCode, false);
  }

  @isTest
  static void testCancelCardSuccess() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.setMock(HttpCalloutMock.class, new MockCardManagementCalloutSuccess());

    Test.startTest();
    CardManagementService service = new CardManagementService();
    Map<String, String> fraudLockInformation = new Map<String, String>{
      'cardNumber' => '23572357',
      'ocvId' => '1111',
      'status' => 'Delinquent (Retain Card)',
      'reason' => 'Fraud'
    };
    HttpCalloutResponse response = service.setFraudCardStatus(
      fraudLockInformation
    );
    Test.stopTest();

    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );

    System.assertEquals(200, response.statusCode, false);
    System.assertEquals(responseMap.get('code'), 'INFO', false);
    System.assertEquals(
      responseMap.get('message'),
      'Request was processed successfully',
      false
    );
  }

  /**
   * @author Farid Masjedi
   * @since Sep 2021
   * @description Mock card management api callout result - success
   */
  public class MockCardManagementCalloutSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"code": "INFO","message": "Request was processed successfully"}'
      );
      return res;
    }
  }

  /**
   * @author Farid Masjedi
   * @since Sep 2021
   * @description Mock card management api callout result - unsuccess
   */
  public class MockCardManagementCalloutUnsuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}
