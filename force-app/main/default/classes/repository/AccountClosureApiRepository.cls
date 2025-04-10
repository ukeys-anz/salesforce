/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Account Closure Api Repository for all the callouts to Fabric Seal via Mulesoft and GCP
 */
public with sharing class AccountClosureApiRepository {

  private static final AccountClosureService SERVICE = (AccountClosureService) Lib_InstanceProvider.forType(
    AccountClosureService.class
  );

  private static final Set<Integer> SERVER_ERROR_CODES = new Set<Integer>{
    500
  };
  private static final Set<Integer> ACCESS_ERROR_CODES = new Set<Integer>{
    401,
    403
  };
  /**
   * @param ocvId ocvId of the customer
   * @param eligibleCaseList card number to be detokenzed
   * @return List<AccountClosurePrecheckResponseModel> fabric seal responses for each cases
   * @description initiate Fabric Seal Prechecks for eligible cases
   */
  public List<AccountClosurePrecheckResponseModel> initiateAccountClosurePreChecks(
    String ocvId,
    List<Case> eligibleCaseList
  ) {
    List<AccountClosurePrecheckRequestModel> contextReq = generateAccountClosurePrecheckRequest(
      eligibleCaseList
    );
    HttpCalloutResponse response = SERVICE.initiateAccountClosurePreChecks(
      ocvId,
      contextReq
    );

    List<AccountClosurePrecheckResponseModel> responseFinal = new List<AccountClosurePrecheckResponseModel>();
    
    if (!response.successful)
    {
      try{
         responseFinal = AccountClosurePrecheckResponseModel.parse(response?.error.getMessage());
      }
     catch (Exception objException){
      handleErrorResponse(response, 'Fabric Seal Service - Fetch Precheck for Accounts');
     }
    }
    
    if(response.successful)
    {
      responseFinal = AccountClosurePrecheckResponseModel.parse(response.body);
    }

    return responseFinal;
  }

  /**
   * @description Generate Json Request to be sent to Mulesoft
   * @param eligibleCaseList contains list of eligible cases for sending to Fabric Seal for prechecks
   * @return AccountClosurePrecheckRequestModel to be sent to Mulesoft
   */
  @testVisible
  private List<AccountClosurePrecheckRequestModel> generateAccountClosurePrecheckRequest(
    List<Case> eligibleCaseList
  ) {
    List<AccountClosurePrecheckRequestModel> accountClosurePrecheckRequestList = new List<AccountClosurePrecheckRequestModel>();
    for (Case eligibleCase : eligibleCaseList) {
      AccountClosurePrecheckRequestModel accountClosurePrecheckInput = new AccountClosurePrecheckRequestModel(
        'accounts/' +
        eligibleCase.FinServ__FinancialAccount__r
          ?.FinServ__FinancialAccountNumber__c,
        eligibleCase.CaseNumber,
        new AccountClosurePrecheckRequestModel.ForwardingAccount(
          eligibleCase.Intended_Account_Number__c,
          eligibleCase.Intended_Account_Name__c,
          eligibleCase.Intended_Account_BSB__c
        )
      );
      accountClosurePrecheckRequestList.add(accountClosurePrecheckInput);
    }
    return accountClosurePrecheckRequestList;
  }

  /**
   * @author Shivam Swaraj
   * @since December 2024
   * @description required field missing excpetion
   */
  public class RequiredFieldMissingException extends Exception {
  }

  @TestVisible
  private static void handleErrorResponse(
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