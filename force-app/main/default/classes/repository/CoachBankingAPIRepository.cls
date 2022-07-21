/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description banking API repository for all banking callouts
 * @group Repository
 */
public with sharing class CoachBankingAPIRepository extends RepositoryBase {
  private static final String VIEW_CARD_PERMISSION_ERROR = 'User does not have the view cards permission';
  private static final String ACCOUNTS_AND_GOALS_PERMISSION_ERROR = 'User does not have the ANZx Accounts and Goals permission';

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
          result = FinancialAccountModel.parse(response.body);
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrors(
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
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `TransactionHistoryModel` model class constructed from api response
   * @description fetches transaction history from fabric, deserialized to a model
   */
  public TransactionHistoryModel getTransactionHistory(
    String ocvId,
    String paramUrl
  ) {
    TransactionHistoryModel result;
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getTransactionHistory(ocvId, paramUrl);
    if (response.successful) {
      try {
        result = TransactionHistoryModel.parse(response.body);
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
    List<String> bucketIds
  ) {
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
        paramUrl
      );
      return responseModel;
    } catch (Exception e) {
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
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
    if (FeatureManagement.checkPermission('ANZx_View_Cards')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getCardList(ocvId);
      if (response.successful) {
        try {
          result = CardListModel.parse(response.body);
          CoachBankingAPIRepositoryHelper helper = new CoachBankingAPIRepositoryHelper();
          helper.handleCardIsValidCheck(result);
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrors(
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
    return (String) responseMap.get('newTokenizedCardNumber');
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
      handleErrors(
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
      handleErrors(
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
