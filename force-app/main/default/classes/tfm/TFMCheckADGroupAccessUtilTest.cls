/**
 * @author Hinduja Upadhyay
 * @since 01/2023
 * @description  Test class for {@link TFMCheckADGroupAccessUtil}
 */
@isTest
public class TFMCheckADGroupAccessUtilTest {
  /**
   * @description tests functionality allowed for AD group
   */
  @isTest
  static void testcheckADGroupWithfunctionality() {
    String func = 'SearchCustomer';
    String headerJson = '{"typ":"JWT","kid":"fK2HSN5juEOPzIzlvjig51vqGEU=","alg":"RS512"}';
    String payloadJson = '{"sub":"aegis_user2@anznp.com","cts":"OAUTH2_STATELESS_GRANT","auditTrackingId":"423636a1-13f0-41db-8515-36ab36865cb5-676530","subname":"spa-ea","iss":"https://identity-services-sit-int-gw.apps-int.x.gcpnp.anz/am/oauth2/customer","tokenName":"access_token","token_type":"Bearer","authGrantId":"rZvXVKeXMehqeHu7XLdbXJhuDMw","aud":"spa-ea","nbf":1704784209,"grant_type":"client_credentials","scope":"aegis-introspect au_anzx_fraudx_ops_admin","auth_time":1704784209,"realm":"/customer","exp":1704787809,"iat":1704784209,"expires_in":3600,"jti":"rJtsrKCHsH7pkTsdqZobMbsVfTo","rqf":{"sub":"7f772c2d-9c25-41af-9af7-54df686acbc4","persona":{"_id":"bdb572c8-4bee-4d30-b614-8970f7848cb7","type":"retail"},"ocvid":"1001088703"},"acr":"IAL4.AAL3.FAL2","act":{"sub":"spa-ea"},"amr":["pwd"],"anz_token_type":"staffRqfCustomer","nonce":"e9e0945737","scopes":["aegis-introspect","au_anzx_fraudx_ops_admin"]}';
    String encodedHeader = EncodingUtil.base64Encode(Blob.valueOf(headerJson))
      .toString();
    String encodedPayload = EncodingUtil.base64Encode(Blob.valueOf(payloadJson))
      .toString();
    String jwtToken = encodedHeader + '.' + encodedPayload;
    Test.startTest();
    String checkValid = TFMCheckADGroupAccessUtil.checkADGroupWithfunctionality(
      func,
      jwtToken
    );
    Assert.areEqual('true', checkValid, 'User is not part of allowed AD group');
    Test.stopTest();
  }
}
