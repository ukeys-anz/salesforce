/**
 * @author Kopal Goswami
 * @since March 2025
 * @description Financial Account API repository for all fabric callouts
 * @group Repository
 */
public with sharing class FinancialAccountAPIRepository extends RepositoryBase {
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
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return `UnifiedFinancialAccountModel` model class constructed from api response
   * @description fetches financial accounts from fabric, deserialized to a model
   */
  public UnifiedFinancialAccountModel getAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    if (!USER_INFO.checkCustomPermission('ANZx_Accounts_and_Goals')) {
      throw CommonUtil.logExceptionInfo(
        new CoachBankingAPIRepository.PermissionException(
          ACCOUNTS_AND_GOALS_PERMISSION_ERROR
        )
      );
    }

    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getFinancialAccounts(
      ocvId,
      accountNumbers
    );

    response = handleResponse(response, 'Fabric Service - Fetching Accounts');

    return UnifiedFinancialAccountModel.parse(response.body);
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
