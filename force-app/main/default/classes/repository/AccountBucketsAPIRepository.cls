/**
 * @author Kopal Goswami
 * @since March 2025
 * @description Account Buckets API repository for all fabric callouts
 * @group Repository
 */
public with sharing class AccountBucketsAPIRepository {
  private static final String ACCOUNTS_AND_GOALS_PERMISSION_ERROR = 'User does not have the ANZx Accounts and Goals permission';
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
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
   * @param ocvId customer id
   * @param pageSize amount of goals to return
   * @param nextPageToken token used to retrieve next page of data
   * @param accountNumber accountnumber for which goals needs to fetch
   * @return `AccountBucketsModel` model class constructed from api response
   * @description fetches account buckets from fabric, deserialized to a model
   */
  public AccountBucketsModel getAccountBuckets(
    String ocvId,
    Integer pageSize,
    String nextPageToken,
    String accountNumber
  ) {
    if (!USER_INFO.checkCustomPermission('ANZx_Accounts_and_Goals')) {
      throw CommonUtil.logExceptionInfo(
        new CoachBankingAPIRepository.PermissionException(
          ACCOUNTS_AND_GOALS_PERMISSION_ERROR
        )
      );
    }

    Service serviceInstance = ServiceProvider.getService(FabricService.class);
    String paramUrl = CoachBankingAPIRepositoryHelper.constructGetAccountsBucketParamUrl(
      pageSize,
      nextPageToken,
      accountNumber
    );
    HttpCalloutResponse response = serviceInstance.getAccountBuckets(
      ocvId,
      paramUrl
    );

    response = handleResponse(response, 'Fabric Service - Fetch Saving Goals');

    return AccountBucketsModel.parse(response.body);
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

  /**
   * @author Kopal Goswami
   * @since March 2025
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }
}
