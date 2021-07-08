/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardTempBlockController is used to handle the temporary card block with the Card Temp Block LWC
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class CardTempBlockController {
  /**
   * @description  The blockCard(cardNumber, ocvId) is the method to make the Http callout to Mulesoft to temporarily block the card.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   *
   * @param cardNumber the tokenised card number
   * @param ocvId Ocv id for which account the card belongs to
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=false)
  public static String blockCard(String cardNumber, String ocvId) {
    String responseBody = null;
    if (String.isNotBlank(ocvId) && String.isNotBlank(cardNumber)) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'callout:SF_MS_Fabric' +
        Label.MS_Temp_Block_Card +
        cardNumber +
        '/block'
      );

      request.setMethod('PUT');
      String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvId);
      request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      request.setHeader('Content-Type', 'application/json');
      request.setBody('{"action":"ACTION_BLOCK"}');
      //Todo: This needs to be replaced with uniquely generated id based on what is accepted by forge
      //request.setHeader('x-correlation-id', RequestUtils.getRequestId());
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          responseBody = response.getBody();
        } else {
          throw new CalloutException(response.getBody());
        }
      } catch (Exception e) {
        Boolean logResult = Lib_SystemLog.logAPIError(
          CardTempBlockController.class.getName(),
          'blockCard',
          e.getMessage(),
          e.getTypeName(),
          null,
          response != null ? response.getBody() : null,
          request.getEndpoint(),
          HTTP_METHOD.HTTP_PUT.name(),
          response.getStatusCode()
        );
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }
}
