/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description banking API repository for all banking callouts
 * @group Repository
 */
public with sharing class CoachBankingAPIRepository extends RepositoryBase {
  private static final String VIEW_CARD_PERMISSION_ERROR = 'User does not have the view cards permission';
  private static final String ACCOUNTS_AND_GOALS_PERMISSION_ERROR = 'User does not have the ANZx Accounts and Goals permission';
  private static final String VIEW_TRANSACTION_HISTORY_ERROR = 'User does not have the transaction history permission';

  /**
   * @param ocvId customer id
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return `FinancialAccountModel` model class constructed from api response
   * @description fetches financial accounts from fabric, deserialized to a model
   */
  public FinancialAccountModel getAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    FinancialAccountModel result;
    if (FeatureManagement.checkPermission('ANZx_Accounts_and_Goals')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getFinancialAccounts(
        ocvId,
        accountNumbers
      );
      if (response.successful) {
        try {
          if (GetHelpConstants.isAccountV1()) {
            result = FinancialAccountModelV1.parse(response.body);
          } else {
            result = FinancialAccountModel.parse(response.body);
          }
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrorAsInfo(
        null,
        new PermissionException(ACCOUNTS_AND_GOALS_PERMISSION_ERROR),
        CoachBankingAPIRepository.class
      );
    }
    return result;
  }

  /**
   * @author Lance
   * @since March 2021
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }
  /**
   * @param ocvId customer id
   * @param ownership Used to control visibility of Transaction Initiator column under TransactionHistory
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `TransactionHistoryModel` model class constructed from api response
   * @description fetches transaction history from fabric, deserialized to a model
   */
  public TransactionHistoryModel getTransactionHistory(
    String ocvId,
    String ownership,
    String paramUrl
  ) {
    TransactionHistoryModel result;
    Map<String, String> mapPersonaIdAndCustomerName;
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getTransactionHistory(ocvId, paramUrl);
    if (response.successful) {
      try {
        // Story ANZX-120154 : Retrieve the user's persona ID from the JWT token to display the Transaction Initiator in Transaction History records.
        if (
          String.isNotBlank(ownership) &&
          ownership == GetHelpConstants.MULTI_PARTY
        ) {
          mapPersonaIdAndCustomerName = AuthTokenCacheUtil.getCustomerNameFromStaffToken(
            Service.IdType.OCVID,
            ocvId
          );
        }
        if (GetHelpConstants.isTransactionsV1()) {
          result = TransactionHistoryModelV1.parse(
            response.body,
            mapPersonaIdAndCustomerName
          );
        } else {
          result = TransactionHistoryModel.parse(response.body);
        }
      } catch (Exception e) {
        handleErrors(null, e, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CoachBankingAPIRepository.class);
    }
    return result;
  }

  /**
   * @description  The getTransactionHistory is the method to make the Http callout to Mulesoft to fetch the transaction history details from Fabric.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   *
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @param ocvId customer id
   * @param accountNumber Account number for which we want to fetch the transactions
   * @param startDate start date of the transaction search filter
   * @param endDate end date of the transaction search filter
   * @param ownership holds the value as Single or Multi-Party Account
   * @param bucketIds list of bucket ids to filter transactions by
   * @return String
   * @exception CalloutException
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  @AuraEnabled(cacheable=false)
  public static TransactionHistoryModel getTransactionHistoryAura(
    String paramUrl,
    String ocvId,
    String accountNumber,
    String startDate,
    String endDate,
    String ownership,
    List<String> bucketIds
  ) {
    if (FeatureManagement.checkPermission('ANZx_View_Transaction_History')) {
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      paramUrl = String.isBlank(paramUrl)
        ? CoachBankingAPIRepositoryHelper.getTransactionParamUrl(
            startDate,
            endDate,
            accountNumber,
            bucketIds
          )
        : paramUrl;
      try {
        TransactionHistoryModel responseModel = coachapi.getTransactionHistory(
          ocvId,
          ownership,
          paramUrl
        );
        return responseModel;
      } catch (Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    } else {
      AuraHandledException ahe = new AuraHandledException(
        VIEW_TRANSACTION_HISTORY_ERROR
      );
      ahe.setMessage(VIEW_TRANSACTION_HISTORY_ERROR);
      throw ahe;
    }
  }

  /**
   * @param ocvId customer id
   * @return `CardListModel` model class constructed from api response
   * @description fetches card list from fabric, deserialized to a model
   */
  public CardListModel getCardList(String ocvId) {
    CardListModel result;
    List<FinServ__FinancialAccount__c> finanancialAccountList;
    Map<String, String> mapOfAccountNumberAndOwnership = new Map<String, String>();
    if (FeatureManagement.checkPermission('ANZx_View_Cards')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getCardList(ocvId);
      if (response.successful) {
        try {
          finanancialAccountList = FinancialAccountService.fetchFinancialAccountsByStatus(
            ocvId,
            null
          );
          for (FinServ__FinancialAccount__c finAcc : finanancialAccountList) {
            mapOfAccountNumberAndOwnership.put(
              finAcc.FinServ__FinancialAccountNumber__c,
              finAcc.Ownership__c
            );
          }
          result = CardListModel.parse(
            response.body,
            mapOfAccountNumberAndOwnership
          );
          CoachBankingAPIRepositoryHelper helper = new CoachBankingAPIRepositoryHelper();
          helper.handleCardIsValidCheck(result);
          // Adding this line to filter the card list based on the status as part of ANZX-112715 - By Shivam , Sept 2023
          result = CoachBankingAPIRepositoryHelper.filterCardsBasedOnAccountStatus(
            ocvId,
            result
          );
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrorAsInfo(
        null,
        new PermissionException(VIEW_CARD_PERMISSION_ERROR),
        CoachBankingAPIRepository.class
      );
    }
    return result;
  }

  /**
   * @param cardNumber card number to be locked
   * @param ocvId customer id
   * @return `CardControlModel.CardControlWrapper` the card control response
   * @description calls card controls api to place card temp lock
   */
  public CardControlModel.CardControlWrapper lockCard(
    String cardNumber,
    String ocvId
  ) {
    Service s = ServiceProvider.getService(FabricService.class);

    HttpCalloutResponse response = s.lockCard(cardNumber, ocvId);
    if (!response.successful) {
      handleErrors(response, null, CoachBankingAPIRepository.class);
    }
    CardControlModel.CardControlWrapper result = CardControlModel.parseCardControl(
      response.body
    );
    return result;
  }

  /**
   * @param cardNumber card number to get replaced
   * @param ocvId customer id
   * @param reason reason to replace the card
   * @return `String` the new replaced card number
   * @description replace card with a new one when lost, stolen or damaged situation
   */
  public String replaceCard(String cardNumber, String ocvId, String reason) {
    CoachBankingAPIRepositoryHelper helper = new CoachBankingAPIRepositoryHelper();
    helper.validateReplaceReason(reason);

    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.replaceCard(cardNumber, ocvId, reason);
    if (!response.successful) {
      handleErrors(response, null, CoachBankingAPIRepository.class);
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    return (String) responseMap.get('new_tokenized_card_number');
  }

  /**
   * @param ocvId customer id
   * @param pageSize amount of goals to return
   * @param nextPageToken token used to retrieve next page of data
   * @return `AccountBucketsModel` model class constructed from api response
   * @description fetches account buckets from fabric, deserialized to a model
   */
  public AccountBucketsModel getAccountBuckets(
    String ocvId,
    Integer pageSize,
    String nextPageToken
  ) {
    AccountBucketsModel result;
    if (FeatureManagement.checkPermission('ANZx_Accounts_and_Goals')) {
      Service s = ServiceProvider.getService(FabricService.class);

      String paramUrl = CoachBankingAPIRepositoryHelper.constructGetAccountsBucketParamUrl(
        pageSize,
        nextPageToken
      );

      HttpCalloutResponse response = s.getAccountBuckets(ocvId, paramUrl);
      if (response.successful) {
        try {
          result = AccountBucketsModel.parse(response.body);
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrorAsInfo(
        null,
        new PermissionException(ACCOUNTS_AND_GOALS_PERMISSION_ERROR),
        CoachBankingAPIRepository.class
      );
    }
    return result;
  }

  /**
   * @param ocvId customer id
   * @return `CardControlModel` card controls constructed from ListControlsResponse
   * @description getCardControlsList retrieves the list of controls for all the customers cards
   */
  public CardControlModel getCardControlsList(String ocvId) {
    CardControlModel result;
    if (FeatureManagement.checkPermission('ANZx_View_Cards')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getCardControlsList(ocvId);

      if (response.successful) {
        try {
          result = CardControlModel.parseCardControlList(response.body);
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrorAsInfo(
        null,
        new PermissionException(VIEW_CARD_PERMISSION_ERROR),
        CoachBankingAPIRepository.class
      );
    }
    return result;
  }

  /**
   * @author Lance
   * @since April 2021
   * @description invaid information exception
   */
  public class InvalidInformationException extends Exception {
  }
}
