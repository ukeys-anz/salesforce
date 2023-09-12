/**
 * @author Tan Phan
 * @since  09/2023
 * @description APEX REST endpoint to delete FARs related to a customer where the customer is Additional Owner
 * @usage Use Endpoint: /ChatterMigrate/migrate?victimId=XXXXX&survivorId=XXXXXX
 */
@RestResource(urlMapping='/FarOwnersRemoval/*')
global with sharing class FarOwnersRemovalService {
  private static final String ERR_BAD_REQUEST = 'Bad paylod: required input missing';
  private static final String FAR_ROLE_ADDITIONAL = 'Additional Owner';

  /**
   * @description The main logic to delete FARs related to a customer where the customer is Additional Owner
   */
  @HttpPost
  global static void doPost() {
    try {
      RequestPayload payload = (RequestPayload) JSON.deserialize(
        RestContext.request.requestBody.toString(),
        RequestPayload.class
      );

      if (String.isBlank(payload.victimId)) {
        handleResponse(
          400,
          new Map<String, String>{ 'error' => ERR_BAD_REQUEST }
        );
        return;
      }

      removeAdditionOwnerFarsFromAccounts(new List<String>{ payload.victimId });
      handleResponse(200, new Map<String, Object>{ 'success' => true });
    } catch (Exception err) {
      handleResponse(
        500,
        new Map<String, String>{ 'error' => err.getMessage() }
      );
    }
  }

  /**
   * @description query for FAR related to given customeres where the customers role are Additional Owner
   * @param accountExternalIds the list of customers' External IDs to query for related FARs
   */
  @TestVisible
  private static void removeAdditionOwnerFarsFromAccounts(
    List<String> accountExternalIds
  ) {
    List<FinServ__FinancialAccountRole__c> fars = [
      SELECT Id
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__Role__c = :FAR_ROLE_ADDITIONAL
        AND FinServ__RelatedAccount__r.External_Id__c IN :accountExternalIds
      WITH USER_MODE
    ];
    if (!fars.isEmpty()) {
      List<Database.DeleteResult> results = Database.delete(
        fars,
        false,
        AccessLevel.USER_MODE
      );

      String error = DatabaseResultHelper.getDeleteResultError(results);
      if (!String.isBlank(error)) {
        DMLUtilHelper.processDeleteResults(results);
        throw new DeleteException(error);
      }
    }
  }

  /**
   * @description Helper function to set the StatusCode and body of the responsse
   * @param statusCode Integer | the corresponding HTTP Code (2xx = Valid, 4xx = Not Found, 5xx = Error)
   * @param response Map <String, Object> | An Object with Key=>Value that will be converted into JSON for the Response Body
   */
  private static void handleResponse(
    Integer statusCode,
    Map<String, Object> response
  ) {
    RestContext.response.statusCode = statusCode;
    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    RestContext.response.addHeader('Content-Type', 'application/json');

    Logger.info('HTTP Code: ' + String.valueOf(statusCode));

    if (response.containsKey('error')) {
      Logger.error(response.get('error').toString());
    }

    Logger.saveLog();
  }

  /**
   * @description wrapper class for the request payload
   */
  private class RequestPayload {
    String victimId { get; set; }
  }

  /**
   * @description extend the Exception class to allow errors to be thrown if delete operation fails
   */
  private class DeleteException extends Exception {
  }
}
