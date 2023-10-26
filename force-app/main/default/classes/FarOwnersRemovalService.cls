/**
 * @author Tan Phan
 * @since  09/2023
 * @description APEX REST endpoint to cleanup related data of victim profile
 * @runTests FarOwnersRemovalServiceTest
 */
@RestResource(urlMapping='/FarOwnersRemoval/*')
global with sharing class FarOwnersRemovalService {
  private static final String ERR_BAD_REQUEST = 'Bad payload: required input missing';
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
      Account victim = getAccountByExternalId(payload.victimId);

      removeP2PRelationsFromAccounts(new List<Account>{ victim });
      removeAdditionalOwnerFarsFromAccounts(new List<Account>{ victim });
      removeContactDataFromAccounts(new List<Account>{ victim });

      handleResponse(200, new Map<String, Object>{ 'success' => true });
    } catch (Exception err) {
      handleResponse(
        500,
        new Map<String, Object>{
          'error' => err.getMessage() +
          ' | ' +
          err.getStackTraceString()
        }
      );
    }
  }

  private static Account getAccountByExternalId(String externalId) {
    return [
      SELECT Id, PersonContactId
      FROM Account
      WHERE External_Id__c = :externalId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description remove party to party relationships related to the provided customers
   * @param accounts the list of customers
   */
  @TestVisible
  private static void removeP2PRelationsFromAccounts(List<Account> accounts) {
    Set<Id> personContactIds = new Set<Id>();
    for (Account acc : Accounts) {
      if (!String.isBlank(acc.PersonContactId)) {
        personContactIds.add(acc.PersonContactId);
      }
    }
    handleDelete(
      [
        SELECT Id
        FROM FinServ__ContactContactRelation__c
        WHERE
          FinServ__Contact__c IN :personContactIds
          OR FinServ__RelatedContact__c IN :personContactIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description remove FAR related to given customers where the customers role are Additional Owner
   * @param accounts the list of customers
   */
  @TestVisible
  private static void removeAdditionalOwnerFarsFromAccounts(
    List<Account> accounts
  ) {
    handleDelete(
      [
        SELECT Id
        FROM FinServ__FinancialAccountRole__c
        WHERE
          FinServ__Role__c = :FAR_ROLE_ADDITIONAL
          AND FinServ__RelatedAccount__c IN :accounts
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description remove contact data (commercial contacts, contact point objects) related to the provided customers
   * @param accounts the list of customers
   */
  @TestVisible
  private static void removeContactDataFromAccounts(List<Account> accounts) {
    List<SObject> recordsToDelete = new List<SObject>();
    recordsToDelete.addAll(
      [
        SELECT Id
        FROM ContactPointAddress
        WHERE ParentId IN :accounts OR Customer_Name__c IN :accounts
        WITH USER_MODE
      ]
    );
    recordsToDelete.addAll(
      [
        SELECT Id
        FROM ContactPointEmail
        WHERE ParentId IN :accounts OR Customer_Name__c IN :accounts
        WITH USER_MODE
      ]
    );
    recordsToDelete.addAll(
      [
        SELECT Id
        FROM ContactPointPhone
        WHERE ParentId IN :accounts OR Customer_Name__c IN :accounts
        WITH USER_MODE
      ]
    );
    handleDelete(recordsToDelete);
  }

  /**
   * @description perform delete DML, log error and throw exception if any
   * @param records the list of records to delete
   */
  private static void handleDelete(List<SObject> records) {
    if (!records.isEmpty()) {
      List<Database.DeleteResult> results = Database.delete(
        records,
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
