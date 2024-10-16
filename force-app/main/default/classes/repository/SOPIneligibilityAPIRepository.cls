/**
 * @author @ramvilas
 * @since August 2024
 * @description SOP API repository for getSOP callouts
 * @group Repository
 */
public with sharing class SOPIneligibilityAPIRepository extends RepositoryBase {
  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return 'SOPIneligibleModel' model class constructed from api response
   * @description fetches a list of ineligible reasons from flex for a sop, deserialized to a model
   */
  public SOPIneligibleModel getSOP(String ocvId, String sopId) {
    Service s = ServiceProvider.getService(BOHService.class);
    SOPIneligibleModel sopCache = (SOPIneligibleModel) DataPartitionUtil.getDataFromCache(
      sopId
    );
    if (sopCache != null) {
      return sopCache;
    }

    HttpCalloutResponse response = s.getSOP(ocvId, sopId);

    if (response.successful == false) {
      throw response.error;
    }
    try {
      SOPIneligibleModel modelResponse = (SOPIneligibleModel) JSON.deserialize(
        response.body,
        SOPIneligibleModel.class
      );

      DataPartitionUtil.storeDataToCache(sopId, modelResponse);

      return modelResponse;
    } catch (Exception e) {
      handleErrors(response, e, SOPIneligibleModel.class);
      return null;
    }
  }
}
