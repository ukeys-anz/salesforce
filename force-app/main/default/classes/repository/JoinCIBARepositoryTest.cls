/**
 * @author shawg2
 * @since January 2024
 * @description Test class for JoinCIBARepository
 * @group Repository
 */

@IsTest
public class JoinCIBARepositoryTest {
  @IsTest
  static void initiateAuthenticationRequest() {
    Test.startTest();
    JoinCIBARepository repo = new JoinCIBARepository();
    CIBAAuthenticationModel model = repo.initiateAuthenticationRequest(
      '123',
      '4567'
    );
    Test.stopTest();
    assert.isNotNull(model.auth_req_id, 'Auth request id should not be null');
  }

  @isTest
  static void testaAuthenticationPollingResponse() {
    HttpCalloutResponse res = getInvalidTokenResponse();
    Service serv = ServiceProvider.getService(JoinCIBAService.class);
    serv.setCalloutResponse(res);
    JoinCIBARepository repo = new JoinCIBARepository();
    Test.startTest();
    CIBAAccessTokenResponseModel s = repo.authenticationPollingResponse(
      'authRequestId',
      'ocvId'
    );

    Test.stopTest();
    assert.areEqual(
      'slow_down',
      s.additionalInfo.errorDetails.error,
      'The response should be as expected.'
    );
  }

  private static HttpCalloutResponse getInvalidTokenResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(
      '{"additionalInfo":{"errorDetails":{"error":"slow_down"}}}'
    );
    response.statusCode = 400;
    response.successful = false;
    return response;
  }
  @isTest
  static void testGetPublicKey() {
    JoinCIBARepository repo = new JoinCIBARepository();
    Test.startTest();
    String actualPublicKey = repo.getPublicKey('kid', 'ocvId');

    Map<String, Object> mockResponse = (Map<String, Object>) Json.deserializeuntyped(
      JoinCIBAServiceMock.GETPUBLICKEYRESPONSE
    );
    String expectedPublicKey = (String) mockResponse.get('public_key');

    Test.stopTest();
    assert.areEqual(
      expectedPublicKey,
      actualPublicKey,
      'Failed to fetch public key'
    );
  }
}
