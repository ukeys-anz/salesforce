/**
 * @author Mouhamed "Mo" Assafiri
 * @since  02/2022
 * @description APEX REST API Controller to handle Chatter Copying across two accounts
 * @usage Use Endpoint: /ChatterMigrate/migrate?victimId=XXXXX&survivorId=XXXXXX
 */

@RestResource(urlMapping='/ChatterMigrate/*')
global with sharing class ChatterMigrationServiceController {
  /**
   * @description Initialise the Rest API Controller and log the request
   *
   */
  private static void init() {
    UniqueIdUtil.captureTraceAndSpanIdFromRestRequest(RestContext.Request);

    lib_systemLog log = new lib_systemLog(
      ChatterMigrationServiceController.class.getName(),
      'ChatterMigrationServiceController Recieved'
    );

    log.info('ChatterMigrationServiceController - Request Recieved');

    log.insertLogAsync();
  }

  /**
   * @description Exposes OCV Migration via Aura for LWC
   * @param recordId String | the Id of the Account record about to be migrated
   * @return Boolean | True if Migraiton is OK. Throws an exception if something goes wrong.
   */
  @AuraEnabled
  public static Boolean migrateViaButton(String recordId) {
    lib_systemLog log = new lib_systemLog(
      ChatterMigrationServiceController.class.getName(),
      'ChatterMigrationServiceController Recieved'
    );
    log.info(
      'Manual OCV Merge Via button Triggered by: ' + UserInfo.getUserId()
    );
    log.insertLogAsync();

    Account record = [
      SELECT Id, Survivor_Party_ID__c, External_Id__c
      FROM Account
      WHERE Id = :recordId
    ][0];

    if (record.Survivor_Party_ID__c == null) {
      throw new AuraHandledException(
        'Please check that the Survivor Party Id is set on the account you are attempting to merge'
      );
    }
    if (
      ChatterMigrationService.cloneChatterFromVictimToSurvivor(
        record.External_Id__c,
        record.Survivor_Party_ID__c
      )
    ) {
      return true;
    } else {
      throw new AuraHandledException(
        'Could not migrate to Surviving Party. Please contact support: Error Code: CHATTEROCV-001'
      );
    }
  }

  /**
   * @description The endpoint for migrating the Chatter items from the Victim to the Survivor
   */
  @HttpPost
  global static void migrate() {
    init();
    String victimId;
    String survivorId;

    Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.request.requestBody.toString()
    );

    if (!params.containsKey('victimId') || !params.containsKey('survivorId')) {
      responseHandler(
        400,
        new Map<String, String>{
          'error' => 'Bad paylod: required input missing'
        }
      );
      return;
    } else {
      victimId = params.get('victimId').toString();
      survivorId = params.get('survivorId').toString();
    }

    try {
      ChatterMigrationService.cloneChatterFromVictimToSurvivor(
        victimId,
        survivorId
      );
      responseHandler(200, new Map<String, String>{ 'success' => 'true' });
    } catch (System.ListException err) {
      responseHandler(
        404,
        new Map<String, String>{ 'error' => err.getMessage() }
      );
    } catch (Exception err) {
      responseHandler(
        500,
        new Map<String, String>{ 'error' => err.getMessage() }
      );
    }
  }

  /**
   * @description Helper function to set the StatusCode and body of the responsse
   * @param statusCode Integer | the corresponding HTTP Code (2xx = Valid, 4xx = Not Found, 5xx = Error)
   * @param response Map <String, String> | An Object with Key=>Value that will be converted into JSON for the Response Body
   */
  private static void responseHandler(
    Integer statusCode,
    Map<String, String> response
  ) {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;
    RestContext.response.statusCode = statusCode;

    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    RestContext.response.addHeader('Content-Type', 'application/json');

    lib_systemLog log = new lib_systemLog(
      ChatterMigrationServiceController.class.getName(),
      'ChatterMigrationServiceController Response'
    );

    log.info('HTTP Code: ' + String.valueOf(statusCode));

    if (response.containsKey('error')) {
      log.error(response.get('error'));
    }

    log.insertLogAsync();
  }
}
