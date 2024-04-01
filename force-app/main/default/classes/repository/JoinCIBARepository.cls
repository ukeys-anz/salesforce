/**
 * @author shawg2
 * @since January 2024
 * @description Join API Repository for CIBA callouts
 * @group Repository
 * @runTests JoinCIBARepositoryTest
 */

public with sharing class JoinCIBARepository extends RepositoryBase {
  private static final String AUTHORIZATION_PENDING = 'authorization_pending';
  private static final String ACCESS_DENIED = 'access_denied';
  private static final String SLOW_DOWN = 'slow_down';
  /**
   * @description Initiate Client Initiated Backchannel Authorisation (CIBA) call on Mulesoft
   * @param ocvId OCV Id for Customer
   * @param jwtRequest jwt request payload to initiate the CIBA authentication request
   * @return CIBAAuthenticationModel
   */
  public CIBAAuthenticationModel initiateAuthenticationRequest(
    String ocvId,
    String jwtRequest
  ) {
    JoinCIBAService s = (JoinCIBAService) ServiceProvider.getService(
      JoinCIBAService.class
    );
    CIBAAuthenticationModel result;

    HttpCalloutResponse response = s.initiateAuthenticationRequest(
      ocvId,
      jwtRequest
    );
    if (response.successful) {
      try {
        result = CIBAAuthenticationModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, JoinCIBARepository.class);
      }
    } else {
      handleErrors(response, null, JoinCIBARepository.class);
    }
    return result;
  }

  /**
   * @description Initiate callout to get auth request statusid
   * @param authRequestId
   * @param ocvId
   * @return CIBAAccessTokenResponseModel
   */
  public CIBAAccessTokenResponseModel authenticationPollingResponse(
    String authRequestId,
    String ocvId
  ) {
    JoinCIBAService s = (JoinCIBAService) ServiceProvider.getService(
      JoinCIBAService.class
    );
    CIBAAccessTokenResponseModel result;

    HttpCalloutResponse response = s.authenticationPollingResponse(
      authRequestId,
      ocvId
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      result = parseAccessTokenResponse(response.body);
    } else if (response.statusCode == 400) {
      result = parseAccessTokenResponse(response.error.getMessage());

      if (
        result.additionalInfo.errorDetails.error != AUTHORIZATION_PENDING &&
        result.additionalInfo.errorDetails.error != ACCESS_DENIED &&
        result.additionalInfo.errorDetails.error != SLOW_DOWN
      ) {
        handleErrors(response, null, JoinCIBARepository.class);
      }
    } else {
      handleErrors(response, null, JoinCIBARepository.class);
    }
    return result;
  }

  /**
   * @description To get the public key
   * @param kid
   * @param ocvId
   * @return String verified
   */

  public String getPublicKey(String kid, String ocvId) {
    JoinCIBAService s = (JoinCIBAService) ServiceProvider.getService(
      JoinCIBAService.class
    );
    HttpCalloutResponse response = s.getPublicKey(kid, ocvId);
    if (response.successful) {
      Map<String, Object> resbody = (Map<String, Object>) Json.deserializeuntyped(
        response.body
      );
      return (String) resbody.get('public_key');
    } else {
      handleErrors(response, null, JoinCIBARepository.class);
    }
    return '';
  }
  /**
   * @description To parse AccessTokenResponse
   * @param response
   * @return result
   */
  private CIBAAccessTokenResponseModel parseAccessTokenResponse(
    String response
  ) {
    CIBAAccessTokenResponseModel result;
    try {
      result = CIBAAccessTokenResponseModel.parse(response);
    } catch (Exception e) {
      handleErrors(null, e, JoinCIBARepository.class);
    }
    return result;
  }
}
