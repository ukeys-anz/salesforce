/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description banking API repository for all banking callouts
 * @group Repository
 */
public with sharing class CoachBankingAPIRepository extends RepositoryBase {
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
        new PermissionException(
          'User does not have the ANZx Accounts and Goals permission'
        ),
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
   * @param accountNumber Account number for which we want to fetch the transactions
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `TransactionHistoryModel` model class constructed from api response
   * @description fetches transaction history from fabric, deserialized to a model
   */
  public TransactionHistoryModel getTransactionHistory(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    TransactionHistoryModel result;
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getTransactionHistory(
      ocvId,
      accountNumber,
      paramUrl
    );
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
      ? getTransactionParamUrl(startDate, endDate, accountNumber, bucketIds)
      : paramUrl;
    try {
      TransactionHistoryModel responseModel = coachapi.getTransactionHistory(
        ocvId,
        accountNumber,
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
          for (CardListModel.CardCls card : result.cards) {
            if (!card.isValid) {
              handleErrors(
                null,
                new InvalidInformationException(
                  'Card Information is invalid. Please reach out to your system administrator.'
                ),
                CoachBankingAPIRepository.class
              );
            }
          }
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrors(
        null,
        new PermissionException('User does not have the view cards permission'),
        CoachBankingAPIRepository.class
      );
    }
    return result;
  }

  /**
   * @param ocvId customer id
   * @return `CardListModel` model class constructed from api response
   * @description fetches card list from fabric, deserialized to a model used in lwc
   */
  @AuraEnabled(cacheable=false)
  public static CardListModel getCardListAura(String ocvId) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    CardListModel result = coachapi.getCardList(ocvId);
    return result;
  }

  /**
   * @description Construct the transaction param URL from startDate and endDate
   * @param startDate start date in the transaction search
   * @param endDate end date in the transaction search
   * @param accountNumber account number for which we want to fetch the transactions
   * @param bucketIds list of bucket ids to filter transactions by
   * @return String the url with params to retrieve transactions
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  private static String getTransactionParamUrl(
    String startDate,
    String endDate,
    String accountNumber,
    List<String> bucketIds
  ) {
    String params = '?';
    if (
      String.isNotBlank(startDate) &&
      String.isNotBlank(endDate) &&
      String.isNotBlank(accountNumber)
    ) {
      String utcStartDate = DateTimeUtils.getUTCTimeFromString(startDate);
      String utcEndDate = DateTimeUtils.getUTCTimeFromString(endDate);
      params +=
        'account_numbers=' +
        accountNumber +
        '&start_time=' +
        utcStartDate +
        '&end_time=' +
        utcEndDate +
        '&';
    }

    if (!bucketIds.isEmpty()) {
      for (String bucketId : bucketIds) {
        params += 'bucket_ids=' + bucketId + '&';
      }
    }
    return params;
  }

  /**
   * @param cardNumber card number to get locked
   * @param ocvId customer id
   * @return `Boolean` the status of the response
   * @description temporarily block cards api
   */
  public Boolean lockCard(String cardNumber, String ocvId) {
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.lockCard(cardNumber, ocvId);
    if (!response.successful) {
      handleErrors(response, null, CoachBankingAPIRepository.class);
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    return (Boolean) responseMap.get('status');
  }

  /**
   * @param cardNumber card number to get replaced
   * @param ocvId customer id
   * @param reason reason to replace the card
   * @return `String` the new replaced card number
   * @description replace card with a new one when lost, stolen or damaged situation
   */
  public String replaceCard(String cardNumber, String ocvId, String reason) {
    String reasonFormatted = reason.toUpperCase();
    //Reason list found here: https://github.com/anzx/fabricapis/blob/28e579f0a95a94ff45eaf667197f81c0a3b0d7a6/proto/fabric/service/card/v1beta1/card_api.proto#L359
    List<String> reasonList = new List<String>{ 'LOST', 'STOLEN', 'DAMAGED' };
    if (!reasonList.contains(reasonFormatted)) {
      handleErrors(
        null,
        new InvalidInformationException('The replace reason is not valid.'),
        CoachBankingAPIRepository.class
      );
    }
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
      String paramUrl = '?status_filter=BUCKET_STATUS_FILTER_OPEN';
      if (String.isBlank(nextPageToken)) {
        paramUrl += '&page_size=' + pageSize;
      } else {
        paramUrl += '&page_token=' + nextPageToken;
      }

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
        new PermissionException(
          'User does not have the ANZx Accounts and Goals permission'
        ),
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
