/**
 * @author Vidhya Raghavan
 * @since Dec 2022
 * @description banking API repository for all Home Loan callouts
 * @group Repository
 */

public with sharing class HomeLoanAPIRepository extends RepositoryBase {
  private static final string BOH_READ_ONLY_PERMISSION_ERROR = 'User does not have permissions to view home loans';

  private static final HomeLoanService HL_SERVICE = (HomeLoanService) Lib_InstanceProvider.forType(
    HomeLoanService.class
  );

  private static final FinancialAccountService FA_SERVICE = (FinancialAccountService) Lib_InstanceProvider.forType(
    FinancialAccountService.class
  );

  private static final List<String> HOME_LOAN_MARKETING_CODES = new List<String>{
    'HLVAR01',
    'HLFXD01'
  };

  /**
   * @param ocvId customer id
   * @param accountNumbers param to filter by account numbers
   * @return `HomeLoanAccountModel` model class constructed from api response
   * @description fetches financial accounts from fabric, deserialized to a model when the data has NOT been stored in the session cache
   */
  public HomeLoanModel getHomeLoanAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    if (FeatureManagement.checkPermission('ANZx_Home_Loan') == false) {
      throw new PermissionException(BOH_READ_ONLY_PERMISSION_ERROR);
    }
    HomeLoanModel h1AccountDetails = DataPartitionUtil.getH1AccountDetailsCache(
      ocvId
    );
    if (h1AccountDetails != null) {
      return h1AccountDetails;
    }
    HttpCalloutResponse response = HL_SERVICE.getHomeLoanAccounts(
      ocvId,
      accountNumbers
    );
    return handleGetHomeLoanResponse(response, ocvId);
  }

  /**
   * @param ocvId ocv id
   * @param loanAccNumber param to get the offset linked with financial account
   * @param recordId record ID
   * @return `OffsetAccountModel`
   * @description fetches linked offset account from lex, deserialized to a model
   */
  public OffsetAccountModel getOffsetAccounts(
    String ocvId,
    String loanAccNumber,
    String recordId
  ) {
    OffsetAccountModel offsetDetails = (OffsetAccountModel) DataPartitionUtil.getDataFromCache(
      recordId
    );
    if (offsetDetails != null) {
      return offsetDetails;
    }
    HttpCalloutResponse response = FA_SERVICE.getOffsetAccounts(
      ocvId,
      loanAccNumber
    );
    return handleGetListOffsetResponse(response, recordId);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @param ocvId OCV Id
   * @return model class constructed from api response
   */
  private static HomeLoanModel handleGetHomeLoanResponse(
    HttpCalloutResponse response,
    String ocvId
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorException(response, 'getHomeLoan');
    }
    if (response.statusCode == 400) {
      throw new UserErrorException(response, 'get Home Loan');
    }
    if (!response.successful) {
      throw new UnhandledException(
        response,
        'HomeLoanService: getHomeLoanAccounts'
      );
    }
    HomeLoanModel h1AccountDetails = HomeLoanModel.parse(response.body);
    filterOutNonHomeLoanAccounts(h1AccountDetails);
    DataPartitionUtil.storeH1AccountDetailsCache(ocvId, h1AccountDetails);

    return h1AccountDetails;
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @param recordId record ID
   * @return OffsetAccountModel processed viewModel
   */
  private static OffsetAccountModel handleGetListOffsetResponse(
    HttpCalloutResponse response,
    String recordId
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorException(response, 'getOffsetAccounts');
    }
    if (
      response.statusCode == 400 ||
      (response.statusCode == 404 &&
      response.error?.getMessage().contains('HTTP:NOT_FOUND'))
    ) {
      throw new UserErrorException(response, 'get Offset Accounts');
    }
    if (!response.successful) {
      throw new UnhandledException(
        response,
        'FinancialAccountService: getOffsetAccounts'
      );
    }
    String offsetStr = (response.body).replace('accounts/', '');
    OffsetAccountModel offsetDetails = OffsetAccountModel.parse(offsetStr);
    DataPartitionUtil.storeDataToCache(recordId, offsetDetails);
    return offsetDetails;
  }

  /**
   * @description Exception class for Server Error on Get Home Loan, Get List Offset APIs
   */
  public class ServerErrorException extends Exception {
    /**
     * @description Exception class for ServerError Get Home Loan, Get List Offset APIs
     * @param response HttpCalloutResponse
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
   * @description Exception class for UserError on Get Home Loan, Get List Offset APIs
   */
  public class UserErrorException extends Exception {
    /**
     * @description Exception class for UserError on Get Home Loan, Get List Offset APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public UserErrorException(
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
   * @description Exception class for Unhandled error on Get Home Loan, Get List Offset APIs
   */
  public class UnhandledException extends Exception {
    /**
     * @description Exception class for Unhandled error on Get Home Loan, Get List Offset APIs
     * @param response HttpCalloutResponse
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
   * @author Vidhya Raghavan
   * @since December 2022
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }

  private static void filterOutNonHomeLoanAccounts(HomeLoanModel result) {
    List<HomeLoanModel.HomeLoanAccount> homeLoanAccounts = new List<HomeLoanModel.HomeLoanAccount>();
    for (HomeLoanModel.HomeLoanAccount acc : result.accounts) {
      if (isHomeLoanAccount(acc)) {
        homeLoanAccounts.add(acc);
      }
      result.accounts = homeLoanAccounts;
    }
  }
  /**
   * @description checking if the retrieved data only passes through Home Loan Account(H1) Details
   * @param acc containing all information related to the account
   * @return true if product_code is 'ANZ Plus Standard Variable Rate Home Loan' (Variable & Fixed Loan)
   */
  private static boolean isHomeLoanAccount(HomeLoanModel.HomeLoanAccount acc) {
    return (acc.product_details?.marketing_code != null &&
    HOME_LOAN_MARKETING_CODES.contains(acc.product_details.marketing_code));
  }
}