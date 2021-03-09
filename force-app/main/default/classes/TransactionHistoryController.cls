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
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return String
   * @exception CalloutException
   */
  @SuppressWarnings('PMD.CyclomaticComplexity')
  @AuraEnabled(cacheable=false)
  public static String getTransactions(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    String responseBody = null;
    if (
      FeatureManagement.checkPermission('ANZx_Accounts_and_Goals') &&
      String.isNotBlank(ocvId) &&
      String.isNotBlank(accountNumber)
    ) {
      HttpRequest request = new HttpRequest();

      String endPointParams = String.isNotBlank(paramUrl)
        ? paramUrl
        : '?account_number=' + accountNumber;

      request.setEndpoint(
        'callout:SF_MS_Fabric' +
        Label.MS_Get_Transactions +
        endPointParams
      );

      RequestUtils.setAuthHeaders(request, ocvId, 'GET');
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
