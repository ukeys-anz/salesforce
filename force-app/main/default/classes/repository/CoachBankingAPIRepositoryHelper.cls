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
    ParameterBuilder builder = new ParameterBuilder();
    builder.append('status_filter', 'BUCKET_STATUS_FILTER_OPEN');

    if (String.isBlank(nextPageToken)) {
      builder.append('page_size', pageSize);
    } else {
      builder.append('page_token', nextPageToken);
    }

    String paramUrl = builder.get();

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
    String paramUrlString = '';

    String startTime = Label.TransactionAPIUpliftedToV1 == 'True'
      ? 'origin_time.after'
      : 'start_time';
    String endTime = Label.TransactionAPIUpliftedToV1 == 'True'
      ? 'origin_time.before'
      : 'end_time';
    String bucketIdsList = Label.TransactionAPIUpliftedToV1 == 'True'
      ? 'buckets'
      : 'bucket_ids';

    String precedingBucketValue = EncodingUtil.urlEncode(
      'accounts/' +
      accountNumber +
      '/buckets/',
      'UTF-8'
    );

    ParameterBuilder builder = new ParameterBuilder();
    //It an issue in Transaction API where if page_size parameter is not found then the "next_uri" node does not come in response.
    builder.append('account_numbers', accountNumber)
      .append(startTime, DateTimeUtils.getUTCTimeFromString(startDate))
      .append(endTime, DateTimeUtils.getUTCTimeFromString(endDate))
      .append('page_size', Label.TransactionPageSize);

    if (!bucketIds.isEmpty()) {
      for (String bucketId : bucketIds) {
        String bucketValue = Label.TransactionAPIUpliftedToV1 == 'True'
          ? precedingBucketValue + bucketId
          : bucketId;
        builder.append(bucketIdsList, bucketValue);
      }
    }

    paramUrlString = builder.get();

    return paramUrlString;
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

  /**
   * @description filter the card list based on the financial account status. This is created as part of ANZX-112715 By Shivam, September 2023
   * @param ocvId String containing ocvId of the customer
   * @param cardListResponse Response received from Fabric after parsing
   * @return CardListModel
   */
  public static CardListModel filterCardsBasedOnAccountStatus(
    String ocvId,
    CardListModel cardListResponse
  ) {
    List<String> statusList = new List<String>{
      GetHelpConstants.CLOSED_STATUS
    };
    List<String> accountNumbersAvailable = new List<String>();
    List<CardListModel.CardCls> cardsToBeRemovedList = new List<CardListModel.CardCls>();

    //Fetch the financial account list whose status is closed in order to filter the card list.
    List<FinServ__FinancialAccount__c> finacialAccountListByStatus = FinancialAccountService.fetchFinancialAccountsByStatus(
      ocvId,
      statusList
    );

    //Fetch the map of financial account numbers based on the list of financial accounts in order to filter out card response.
    Map<String, List<String>> accountNumbersList = FinancialAccountService.getAccountNumbersByStatusMap(
      finacialAccountListByStatus
    );

    //Return CardListModel after filtering the card list
    CardListModel filteredCardListResponse;

    //Get the account numbers from the Map based on the status passed.
    if (!accountNumbersList.isEmpty()) {
      accountNumbersAvailable = accountNumbersList.get(
        GetHelpConstants.CLOSED_STATUS
      );
    }

    //list of cards which is to be removed
    if (!accountNumbersAvailable.isEmpty()) {
      for (CardListModel.CardCls card : cardListResponse.cards) {
        Boolean foundClosedCard = true;
        if (!card.account_numbers.isEmpty()) {
          for (String acc : card.account_numbers) {
            if (accountNumbersAvailable.contains(acc)) {
              foundClosedCard = false;
              break;
            }
          }
        }
        if (!foundClosedCard) {
          cardsToBeRemovedList.add(card);
        }
      }

      if (!cardsToBeRemovedList.isEmpty()) {
        Integer cardIndex = 0;
        while (cardIndex < cardListResponse.cards.size()) {
          if (
            cardsToBeRemovedList.contains(cardListResponse.cards[cardIndex])
          ) {
            cardListResponse.cards.remove(cardIndex);
          } else {
            cardIndex++;
          }
        }
      }
    }

    filteredCardListResponse = cardListResponse;
    return filteredCardListResponse;
  }
}
