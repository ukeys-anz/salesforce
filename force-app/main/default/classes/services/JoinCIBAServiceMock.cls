/**
 * @author shawg2
 * @since January 2024
 * @description Mock JWT header payload for CIBA request
 * @group Services
 * @runTests JoinCIBARepositoryTest
 */

public with sharing class JoinCIBAServiceMock extends JoinCIBAService {
  @TestVisible
  private static final String GETPUBLICKEYRESPONSE =
    '{"public_key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxhznn9Ok8iR3kuoSXgXIt0' +
    'I14ckHTm+GEOpBx6olgTyW74rTv2dgc5aR1HPRIigHTjRfUCHXGxPXTQoIiJtSaqj/Tg7TgSSMfu5uMBym/' +
    'GwRfO3GW6LsPLYlq0Tny90vYPsbPNameIHGThmkysN5u428KyFrqDNpF13h8GZHAFkdq0kxYIi3GG2Ti0Db' +
    'N2fPpgvyF8Zw1yax7vbg6jTBoMrE4HdWj3WfXutOerNewulkH2GCQciNTWtHjB8yuDUDzTW3nWM7KXa8EGx+' +
    'Q98XmVg36MNiDd3WnvKgGn5JOsoYmpFWp8GbZCRG2rddJr2PHjhNIrpBDrARLXJ53UpRDQIDAQAB"}';
  @TestVisible
  private static final string CUSTOMERDENIEDRESPONSE =
    '{' +
    '    "code": "ERROR",' +
    '    "message": "Internal Server Error",' +
    '    "additionalInfo": {' +
    '        "reason": "HTTP:BAD_REQUEST",' +
    '        "category": "TECHNICAL",' +
    '        "errorDetails": {' +
    '            "error_description": "Login failure",' +
    '            "error": "access_denied"' +
    '        }' +
    '    }' +
    '}';

  @TestVisible
  private static final string CUSTOMERPENDINGRESPONSE =
    '{' +
    '    "code": "ERROR",' +
    '    "message": "Internal Server Error",' +
    '    "additionalInfo": {' +
    '        "reason": "HTTP:BAD_REQUEST",' +
    '        "category": "TECHNICAL",' +
    '        "errorDetails": {' +
    '            "error_description": "End user has not yet been authenticated",' +
    '            "error": "authorization_pending"' +
    '        }' +
    '    }' +
    '}';
  /**
   * @description constructor which sets default status code and successful
   */
  public JoinCIBAServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  public override HttpCalloutResponse initiateAuthenticationRequest(
    String ocvId,
    String jwtRequest
  ) {
    response.body =
      '{"auth_req_id": "' +
      CommonUtil.generateUUID() +
      '",' +
      '"expires_in": 300,' +
      '"interval": 5' +
      '}';

    return response;
  }

  public override HttpCalloutResponse authenticationPollingResponse(
    String authRequestId,
    String ocvId
  ) {
    if (!preset) {
      response.body = '{"access_token": "' + getEncodedToken() + '"}';
    }
    return response;
  }
  private string getEncodedToken() {
    String uuid = CommonUtil.generateUUID();
    JWTUtil util = new JWTUtil(
      AuthenticateCustomerController.CIBA_JWT_SETTING_NAME
    );
    return util.getSignedJWT('1234', 'IAL4.AAL3.FAL1', uuid);
  }

  public override HttpCalloutResponse getPublicKey(String kid, String ocvId) {
    response.body = GETPUBLICKEYRESPONSE;
    return response;
  }
}
