/**
 *
 * @author Emma Bindi
 * @since June 2022
 * @description Helper class for {@link CoachBankingAPIRepository}
 */
public with sharing class CoachBankingAPIRepositoryHelper extends RepositoryBase {
  private static final String CARD_INFORMATION_INVALID_ERROR = 'Card Information is invalid. Please reach out to your system administrator.';
  private static final String REPLACE_REASON_INVALID_ERROR = 'The replace reason is not valid.';

  // Reason list found here: https://github.com/anzx/fabricapis/blob/28e579f0a95a94ff45eaf667197f81c0a3b0d7a6/proto/fabric/service/card/v1beta1/card_api.proto#L359
  private static final List<String> REPLACE_REASON_LIST = new List<String>{
    'LOST',
    'STOLEN',
    'DAMAGED'
  };

  /**
   * @description constructGetAccountsBucketParamUrl sets the params on getAccountsBucket api call
   * @param pageSize amount of goals to return
   * @param nextPageToken token used to retrieve next page of data
   * @return String paramUrl url with parameters to be used in call to api
   */
  public static String constructGetAccountsBucketParamUrl(
    Integer pageSize,
    String nextPageToken
  ) {
    String paramUrl = '?status_filter=BUCKET_STATUS_FILTER_OPEN';

    if (String.isBlank(nextPageToken)) {
      paramUrl += '&page_size=' + pageSize;
    } else {
      paramUrl += '&page_token=' + nextPageToken;
    }

    return paramUrl;
  }

  /**
   * @description Construct the transaction param URL from startDate and endDate
   * @param startDate start date in the transaction search
   * @param endDate end date in the transaction search
   * @param accountNumber account number for which we want to fetch the transactions
   * @param bucketIds list of bucket ids to filter transactions by
   * @return String the url with params to retrieve transactions
   */
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
  public static String getTransactionParamUrl(
    String startDate,
    String endDate,
    String accountNumber,
    List<String> bucketIds
  ) {
    String accNum = '';
    String startTime = '';
    String endTime = '';
    String goalIds = '';
    String params = '';
    if (String.isNotBlank(accountNumber)) {
      accNum = 'account_numbers=' + accountNumber + '&';
    }
    if (String.isNotBlank(startDate)) {
      String utcStartDate = DateTimeUtils.getUTCTimeFromString(startDate);
      startTime += 'start_time=' + utcStartDate + '&';
    }
    if (String.isNotBlank(endDate)) {
      String utcEndDate = DateTimeUtils.getUTCTimeFromString(endDate);
      endTime += 'end_time=' + utcEndDate + '&';
    }
    if (!bucketIds.isEmpty()) {
      for (String bucketId : bucketIds) {
        goalIds += 'bucket_ids=' + bucketId + '&';
      }
    }
    if (
      String.isNotBlank(accNum) ||
      String.isNotBlank(startTime) ||
      String.isNotBlank(endTime) ||
      String.isNotBlank(goalIds)
    ) {
      params = '?' + accNum + startTime + endTime + goalIds;
    }
    return params;
  }

  /**
   * @description handles is valid check for each card in list
   * @param cardListResponse CardListModel returned from get call
   */
  public void handleCardIsValidCheck(CardListModel cardListResponse) {
    for (CardListModel.CardCls card : cardListResponse.cards) {
      if (!card.isValid) {
        handleErrors(
          null,
          new CoachBankingAPIRepository.InvalidInformationException(
            CARD_INFORMATION_INVALID_ERROR
          ),
          CoachBankingAPIRepository.class
        );
      }
    }
  }

  /**
   * @description validates the reason provided against allowed reasons list
   * @param reason String containing reason to replace the card
   */
  public void validateReplaceReason(String reason) {
    String reasonFormatted = reason.toUpperCase();

    if (!REPLACE_REASON_LIST.contains(reasonFormatted)) {
      handleErrors(
        null,
        new CoachBankingAPIRepository.InvalidInformationException(
          REPLACE_REASON_INVALID_ERROR
        ),
        CoachBankingAPIRepositoryHelper.class
      );
    }
  }
}
