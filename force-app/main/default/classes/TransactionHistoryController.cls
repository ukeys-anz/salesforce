/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TransactionHistoryController is apex side controller for Transaction history LWC
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class TransactionHistoryController {
  /**
   * @description  The getTransactions(ocvId, accountNumber) is the method to make the Http callout to Mulesoft to fetch the transaction details from Fabric.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   *
   * @param ocvId Ocv id for which account transaction details needs to be fetched
   * @param accountNumber Account number for which we want to fetch the transactions
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=false)
  public static String getTransactions(String ocvId, String accountNumber) {
    String responseBody = null;
    if (String.isNotBlank(ocvId) && String.isNotBlank(accountNumber)) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'callout:SF_MS_Fabric' +
        Label.MS_Get_Transactions +
        accountNumber
      );

      request.setMethod('GET');
      String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvId);
      request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      request.setHeader('x-correlation-id', RequestUtils.getRequestId());
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
        Lib_SystemLog.logAPIError(
          TransactionHistoryController.class.getName(),
          'getTransactions',
          e.getMessage(),
          e.getTypeName(),
          RequestUtils.getRequestId(),
          null,
          response != null ? response.getBody() : null
        );
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }
}
