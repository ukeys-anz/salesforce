/**
 * @author @ramvilas
 * @since August 2024
 * @description SOP API repository for getSOP callouts
 * @group Repository
 */
public with sharing class SOPIneligibilityAPIRepository extends RepositoryBase {
  private static final SOPService SOP_SERVICE = (SOPService) Lib_InstanceProvider.forType(
    SOPService.class
  );
  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return 'SOPIneligibleModel' model class constructed from api response
   * @description fetches a list of ineligible reasons from flex for a sop, deserialized to a model
   */
  public SOPIneligibleModel getSOP(String ocvId, String sopId) {
    SOPIneligibleModel sopCache = (SOPIneligibleModel) DataPartitionUtil.getDataFromCache(
      BOHConstants.CACHE_DATA_KEY_PREFIX_SOPINELIGIBLE + sopId
    );
    if (sopCache != null) {
      return sopCache;
    }

    HttpCalloutResponse response = SOP_SERVICE.getSOP(ocvId, sopId);
    return handleGetSOPIneligibleResponse(response, sopId);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @param sopId sop id to retrieve customer information
   * @return SOPIneligibleModel
   */
  private static SOPIneligibleModel handleGetSOPIneligibleResponse(
    HttpCalloutResponse response,
    String sopId
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorGetSOPIneligibleException(response);
    }
    if (response.statusCode == 400) {
      throw new UserErrorGetSOPIneligibleException(response);
    }
    if (!response.successful) {
      throw new UnhandledGetSOPIneligibleException(response);
    }
    SOPIneligibleModel modelResponse = (SOPIneligibleModel) JSON.deserialize(
      response.body,
      SOPIneligibleModel.class
    );

    DataPartitionUtil.storeDataToCache(
      BOHConstants.CACHE_DATA_KEY_PREFIX_SOPINELIGIBLE + sopId,
      modelResponse
    );

    return modelResponse;
  }

  /**
   * @description Exception class for ServerError on GetSOPIneligible
   */
  public class ServerErrorGetSOPIneligibleException extends Exception {
    /**
     * @description Exception class for ServerError GetSOPIneligible
     * @param response HttpCalloutResponse
     */
    public ServerErrorGetSOPIneligibleException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Error from GetSOPIneligible Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for UserError on GetSOPIneligible
   */
  public class UserErrorGetSOPIneligibleException extends Exception {
    /**
     * @description Exception class for UserError GetSOPIneligible
     * @param response HttpCalloutResponse
     */
    public UserErrorGetSOPIneligibleException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from GetSOPIneligible Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled Get SOP API for Ineligible Reasons
   */
  public class UnhandledGetSOPIneligibleException extends Exception {
    /**
     * @description Exception class for Unhandled Get SOP API for Ineligible Reasons
     * @param response HttpCalloutResponse
     */
    public UnhandledGetSOPIneligibleException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledGetSOPIneligibleException SOPService: getSOP',
          response.error
        )
        .save();
    }
  }
}
