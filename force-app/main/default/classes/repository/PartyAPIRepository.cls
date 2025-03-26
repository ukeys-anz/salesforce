/**
 * @author Ankit Garg
 * @since Feb 2025
 * @description Party API repository for all Party API callouts
 * @group Repository
 */
public with sharing class PartyAPIRepository extends RepositoryBase {
  private static final MaintainPartyService MAINTAIN_PARTY_SERVICE = (MaintainPartyService) Lib_InstanceProvider.forType(
    MaintainPartyService.class
  );
  private static final RetrievePartyService RETRIEVE_PARTY_SERVICE = (RetrievePartyService) Lib_InstanceProvider.forType(
    RetrievePartyService.class
  );

  /**
   * @param requestBody OCVRetrievePartyPayloadWrapper wrapper record
   * @return result
   * @description calls the service class methods for integration/callout
   */
  public String retrieveParty(OCVRetrievePartyPayloadWrapper requestBody) {
    HttpCalloutResponse response = RETRIEVE_PARTY_SERVICE.retrieveParty(
      requestBody
    );
    return handleRetrievePartyResponse(response);
  }

  /**
   * @param requestBody OCVRequestPayloadWrapper record
   * @return MaintainPartyModel result
   * @description calls the service class methods for integration/callout
   */
  public MaintainPartyModel maintainParty(
    OCVRequestPayloadWrapper requestBody
  ) {
    HttpCalloutResponse response = MAINTAIN_PARTY_SERVICE.maintainPartyForIndividual(
      requestBody
    );
    return handleMaintainPartyResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  private static HttpCalloutResponse handleResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorException(response);
    }
    if (response.statusCode == 400) {
      throw new UserErrorException(response);
    }
    if (response.successful == false) {
      throw new UnhandledException(response);
    }
    return response;
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return MaintainPartyModel response
   * @description handle received response and either return the response or throw exception
   */
  private static MaintainPartyModel handleMaintainPartyResponse(
    HttpCalloutResponse response
  ) {
    HttpCalloutResponse response = handleResponse(response);
    return MaintainPartyModel.parse(response.body);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return String response
   * @description handle received response and either return the response or throw exception
   */
  private static String handleRetrievePartyResponse(
    HttpCalloutResponse response
  ) {
    HttpCalloutResponse response = handleResponse(response);
    return response.body;
  }

  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
    /**
     * @description constructor for ServerErrorException
     * @param response HttpCalloutResponse
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from PARTY_SERVICE',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class UserErrorException extends Exception {
    /**
     * @description constructor for UserErrorException
     * @param response HttpCalloutResponse
     */
    public UserErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from PARTY_SERVICE',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class UnhandledException extends Exception {
    /**
     * @description constructor for UnhandledException
     * @param response HttpCalloutResponse
     */
    public UnhandledException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledException ServiceName: <PARTY_SERVICE>',
          response.error
        )
        .save();
    }
  }
}
