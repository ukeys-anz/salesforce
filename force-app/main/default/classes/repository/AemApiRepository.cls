/**
 * @author Kopal Goswami
 * @since April 2025
 * @description AemApiRepository for all the callouts to AEM System
 * @group Repository
 */
public with sharing class AemApiRepository {
  private static final AemService SERVICE = (AemService) Lib_InstanceProvider.forType(
    AemService.class
  );

  private static final Set<Integer> SUCCESS_CODES = new Set<Integer>{
    200,
    206
  };
  private static final Set<Integer> SERVER_ERROR_CODES = new Set<Integer>{
    500
  };
  private static final Set<Integer> ACCESS_ERROR_CODES = new Set<Integer>{
    401,
    403
  };

  private static final String CACHE_LOCAL_UTILITY_KEY = 'local.Utility.';

  /**
   * @param aemContentId Id of the template selected by user
   * @param recordId The Id of the record for which notification needs to be sent.
   * @return `AemDataModel` Transformed data
   * @description This method return the AEM data that can be utilised in LWC . Also, stores the data in Org Cache.
   */
  public static AemDataModel getAemContentDataForNotification(
    String aemContentId,
    Id recordId
  ) {
    //Get aem content data from cache
    String aemContentIdWithoutSpecialChars = TextUtils.removeNonAlphanumericChar(
      aemContentId
    );
    AemDataModel cachedAemContentData = (AemDataModel) Cache.Org.get(
      CACHE_LOCAL_UTILITY_KEY + aemContentIdWithoutSpecialChars
    );

    //Returning aem content data from cache
    if (cachedAemContentData != null) {
      return cachedAemContentData;
    }

    //Get the aem content data from api if not fround in Cache
    HttpCalloutResponse response = SERVICE.getAemContentData(aemContentId);

    response = handleResponse(response);

    //Replace the merged fields with appropriate field values in the response received from AEM
    String aemDataWithReplacedFields = AemDataMergeFieldProcessor.replaceMergedFields(
      response.body,
      recordId
    );

    AemDataModel aemContentData = AemDataModel.parse(
      aemDataWithReplacedFields,
      recordId
    );

    //Store aem content data to cache
    Cache.Org.put(
      CACHE_LOCAL_UTILITY_KEY + aemContentIdWithoutSpecialChars,
      aemContentData
    );
    return aemContentData;
  }

  private static HttpCalloutResponse handleResponse(
    HttpCalloutResponse response
  ) {
    if (SERVER_ERROR_CODES.contains(response.statusCode)) {
      throw new ServerErrorException(response);
    }
    if (ACCESS_ERROR_CODES.contains(response.statusCode)) {
      throw new AccessErrorException(response);
    }
    if (response.successful == false) {
      throw new UnhandledException(response);
    }
    return response;
  }

  /**
   * @description ServerErrorException custom exception
   */
  public class ServerErrorException extends Exception {
    /**
     * @description ServerErrorException custom exception
     * @param response
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from AemService',
          response.error
        )
        .save();
    }
  }

  /**
   * @description AccessErrorException custom exception
   */
  public class AccessErrorException extends Exception {
    /**
     * @description AccessErrorException custom exception
     * @param response
     */
    public AccessErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from AemService',
          response.error
        )
        .save();
    }
  }

  /**
   * @description UnhandledException custom exception
   */

  public class UnhandledException extends Exception {
    /**
     * @description AccessErrorException custom exception
     * @param response
     */
    public UnhandledException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error('UnhandledException from: AemService', response.error)
        .save();
    }
  }
}
