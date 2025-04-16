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

  /**
   * @param aemContentId Id of the template selected by user
   * @param recordId The Id of the record for which notification needs to be sent.
   * @return `AemDataWrapper` Transformed data
   * @description This method return the AEM data that can be utilised in LWC . Also, stores the data in Org Cache.
   */
  public static AemDataWrapper getAemContentDataForNotification(
    String aemContentId,
    Id recordId
  ) {
    AemDataWrapper aemContentData;

    //Get aem content data from cache
    String aemContentIdWithoutUnderscores = aemContentId.replace('_', '');
    aemContentData = (AemDataWrapper) Cache.Org.get(
      'local.Utility.' + aemContentIdWithoutUnderscores
    );

    //Returning aem content data from cache
    if (aemContentData != null) {
      return aemContentData;
    }

    //Get the aem content data from api if not fround in Cache
    HttpCalloutResponse response = SERVICE.getAemContentData(aemContentId);

    response = handleResponse(response, 'AemService');

    //Store aem content data to cache
    aemContentData = AemDataModel.parse(response.body, recordId);
    Cache.Org.put(
      'local.Utility.' + aemContentIdWithoutUnderscores,
      aemContentData
    );
    return aemContentData;
  }

  private static HttpCalloutResponse handleResponse(
    HttpCalloutResponse response,
    String serviceName
  ) {
    if (SERVER_ERROR_CODES.contains(response.statusCode)) {
      throw new ServerErrorException(response, serviceName);
    }
    if (ACCESS_ERROR_CODES.contains(response.statusCode)) {
      throw new AccessErrorException(response, serviceName);
    }
    if (response.successful == false) {
      throw new UnhandledException(response, serviceName);
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
     * @param serviceName
     */
    public ServerErrorException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from ' + serviceName,
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
     * @param serviceName
     */
    public AccessErrorException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from ' + serviceName,
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
     * @param serviceName
     */
    public UnhandledException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error('UnhandledException from: ' + serviceName, response.error)
        .save();
    }
  }
}
