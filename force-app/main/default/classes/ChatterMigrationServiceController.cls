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
