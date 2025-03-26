/**
 * @author Raman
 * @since November 2024
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
    List<Object> urlParameters
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
    if (response.successful == false) {
      throw new UnhandledGetSOPException(response);
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
    if (response.successful == false) {
      throw new UnhandledUpdateSOPAndPartyException(response);
    }
    SOPUpdateSOPAndPartyResponseModel updatePartyAndSOPModel = SOPUpdateSOPAndPartyResponseModel.parse(
      response.body
    );
    return new SOPViewModel(updatePartyAndSOPModel);
  }

  /**
   * @description Exception class for Unhandled Get SOP
   */
  public class UnhandledGetSOPException extends Exception {
    /**
     * @description Exception class for Unhandled Get SOP
     * @param response HttpCalloutResponse
     */
    public UnhandledGetSOPException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledGetSOPException BOHService: getSOP',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled Update SOP and Party
   */
  public class UnhandledUpdateSOPAndPartyException extends Exception {
    /**
     * @description Exception class for Unhandled Update SOP and Party
     * @param response HttpCalloutResponse
     */
    public UnhandledUpdateSOPAndPartyException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledUpdateSOPAndPartyException SOPService: updateSOPAndParty',
          response.error
        )
        .save();
    }
  }
}
