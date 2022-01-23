/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description card management implementation of the API service
 * @group Services
 */

public with sharing class CardManagementService extends Service {
  /**
   * @param fraudLockInformation `Map<String,String>` which contains:
   * - cardNumber card number to send to api
   * - ocvId customer id
   * - status chosen by fraud agent
   * - reason for fraud action. If chosen to cancel the card, this will be "Fraud"
   * @return `HttpCalloutResponse` the api response
   * @description fraud lock/unlock/cancel cards api
   */
  public override HttpCalloutResponse setFraudCardStatus(
    Map<String, String> fraudLockInformation
  ) {
    String cardNumber = fraudLockInformation.get('cardNumber');
    String ocvID = fraudLockInformation.get('ocvId');
    String status = fraudLockInformation.get('status');
    String reason = fraudLockInformation.get('reason');

    String callBody = String.isBlank(reason)
      ? '{"status":"' + status + '","cardNumber":"' + cardNumber + '"}'
      : '{"status":"' +
        status +
        '","cardNumber":"' +
        cardNumber +
        '","reason":"' +
        reason +
        '"}';

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();

    setCalloutCommonHeaders(ocvID, headers);
    headers.put('x-span-id', UniqueIdUtil.getParentId());
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Fraud_Lock_Card,
      HTTP_METHOD.HTTP_POST,
      headers,
      callBody
    );
    return response;
  }
}
