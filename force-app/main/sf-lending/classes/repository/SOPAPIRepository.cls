/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description SOP API repository for all SOP callouts
 * @group Repository
 */
public with sharing class SOPAPIRepository extends RepositoryBase {
  private static final SOPService SOP_SERVICE = (SOPService) Lib_InstanceProvider.forType(
    SOPService.class
  );

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `SOPViewModel` model class constructed from api response
   * @description fetches a list of assets from flex for a sop, deserialized to a model
   */
  public SOPViewModel getSOP(String ocvId, String sopId) {
    HttpCalloutResponse response = SOP_SERVICE.getSOP(ocvId, sopId);
    return handleGetSOPResponse(response);
  }

  /**
   * @description updateSOPandParty to update sop and party details
   * @param ocvId ocv id of the customer account
   * @param updateSOPAndPartyBody post data of about you party information
   * @param urlParameters parameters to retrieve customer information
   * @return SOPViewModel data
   */
  public SOPViewModel updateSOPAndParty(
    String ocvId,
    SOPUpdateSOPAndPartyRequestModel updateSOPAndPartyBody,
    List<String> urlParameters
  ) {
    HttpCalloutResponse response = SOP_SERVICE.updateSOPAndParty(
      ocvId,
      updateSOPAndPartyBody,
      urlParameters
    );
    return handleUpdateSopAndPartyResponse(response);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return SOPViewModel processed viewModel
   */
  private static SOPViewModel handleGetSOPResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorSOPAPIException(response, 'getSOP');
    }
    if (response.statusCode == 400) {
      throw new UserErrorSOPAPIException(response, 'getSOP');
    }
    if (response.successful == false) {
      throw new UnhandledSOPAPIException(response, 'getSOP');
    }
    return SOPViewModel.parse(response.body);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return SOPViewModel processed viewModel
   */
  private static SOPViewModel handleUpdateSopAndPartyResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorSOPAPIException(response, 'updateSopAndParty');
    }
    if (response.statusCode == 400) {
      throw new UserErrorSOPAPIException(response, 'updateSopAndParty');
    }
    if (response.successful == false) {
      throw new UnhandledSOPAPIException(response, 'updateSopAndParty');
    }

    SOPUpdateSOPAndPartyResponseModel updatePartyAndSOPModel = SOPUpdateSOPAndPartyResponseModel.parse(
      response.body
    );
    return new SOPViewModel(updatePartyAndSOPModel);
  }

  /**
   * @description Exception class for server errors receiving from API
   */
  public class ServerErrorSOPAPIException extends Exception {
    /**
     * @description Exception class for server errors receiving from API
     * @param response HttpCalloutResponse
     * @param serviceName service name of Callout
     */
    public ServerErrorSOPAPIException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Error from ServiceName:' +
            serviceName,
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for User related errors receiving from API
   */
  public class UserErrorSOPAPIException extends Exception {
    /**
     * @description Exception class for User related errors receiving from API
     * @param response HttpCalloutResponse
     * @param serviceName service name of Callout
     */
    public UserErrorSOPAPIException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from ServiceName: ' +
            serviceName,
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled SOP APIs error
   */
  public class UnhandledSOPAPIException extends Exception {
    /**
     * @description Exception class for  Unhandled SOP APIs error
     * @param response HttpCalloutResponse
     * @param serviceName service name of Callout
     */
    public UnhandledSOPAPIException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledException ServiceName: ' + serviceName,
          response.error
        )
        .save();
    }
  }
}
