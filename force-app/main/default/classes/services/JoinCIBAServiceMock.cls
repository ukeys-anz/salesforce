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
    '{"public_key": "-----BEGIN PUBLIC KEY-----MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC' +
    'AgEAmagDNBLR4ref++CzHjO+ReCB1PkcQut2GNns7TkR/9o8qMOeK9XKbDSIJ+QdKhSxGyOj3/tz2G54Wa' +
    'KlFY+RPl9o8cNl+cgw70jKLS3L1yroa092GdfCpVEW8MWKtP3mhM6Qneb0ObDvYNJbW7IKYdBE3VbUpMLi' +
    'J8fWnYhZOK+VYANRzrMaeMIpirrkeI0I3HbVrG6OZkT2pMruAKE7ymur3p+Mt3rm6/G5xoJHkV3kT+HjBp' +
    'iJr9BJ8CzPLAT60MTg8zuc8EgOsYTsIghzZqVFtN1gEORZz6vxeDak5HbkD3PvnpQaEu100qLttoyb7Lay' +
    'MTNhNFycDhA1hYUF4kgN1WFN0YG+JuHTodzCDTIyjZTQZMAbYX/y9g/r88wSsITV1PNRDCHyE4RFNiU82k' +
    'rO+IucoxLBtrRJihCw5sAwuoT2pk4gIRWIzwQgtofB/xatSD/iewp122X+d3oUF9TRawZtWtW/n8NKgQsY' +
    'QTYGgef5GH9LTxBd5e3x2irNa7XPqTqVzk2OtGujKRDoEHfzRpEiSgDiGa9qfDVi59FNBBdqk2DxA+N/c3' +
    'lxXwrO8ZCl8LIvRR7/YR8xPdMWgTwlGAtJ6cpzBlzmKiC1DRNYkA5+x8OLfPh1K2/rpSf5v72wE3g6NKq8' +
    'QQKOpaLLCXh4e+Lr2F4uTlc7fV8MoxMCAwEAAQ==-----END PUBLIC KEY-----"}';

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
