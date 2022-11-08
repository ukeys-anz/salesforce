/**
 * @author Peter Charalambous
 * @since 2020
 * @description CardDetailsController is the apex side controller for the cardDetails LWC
 */
public with sharing class CardDetailsController {
  /**
   * @param ocvId customer id
   * @return `CardListModel` model class constructed from api response
   * @description fetches card list from fabric, checks if controls are enabled for
   * any of the customer's cards, if so, subsequently fetches card control list
   * result is deserialized to a model used in viewCards lwc
   */
  @AuraEnabled(cacheable=false)
  public static CardListModel getCardList(String ocvId) {
    Map<String, CardListModel.CardCls> cardByTokenizedNumberMap = new Map<String, CardListModel.CardCls>();
    CardControlModel cardControlsListResponse;
    Boolean cardControlsAreEnabled = false;

    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    CardListModel cardListResponse = coachapi.getCardList(ocvId);

    for (CardListModel.CardCls card : cardListResponse.cards) {
      // Put cards into map by tokenized card number used to match against card controls
      cardByTokenizedNumberMap.put(card.tokenized_card_number, card);

      // If card controls are enabled, then a call to getCardControlsList is required
      if (card.hasControlsEnabled) {
        cardControlsAreEnabled = true;
      }
    }

    if (cardControlsAreEnabled) {
      cardControlsListResponse = getCardControlsList(ocvId);
      storeCardControlsOnCard(
        cardControlsListResponse,
        cardByTokenizedNumberMap
      );

      /* [AR-21317] commenting out to adjust fabric changes to card controls being missing even when
       eligibilities contain ELIGIBILITY_CARD_CONTROLS and card_controls_enabled == true */
      //verifyCardControlsStored(cardListResponse);
    }

    return cardListResponse;
  }

  /**
   * @param ocvId customer id
   * @return `CardControlModel` card controls representing ListControlsResponse
   * @description getCardControlsList retrieves the list of controls for all the customers cards
   */
  public static CardControlModel getCardControlsList(String ocvId) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    CardControlModel result = coachapi.getCardControlsList(ocvId);
    return result;
  }

  /**
   * @param cardControlsListResponse card controls representing ListControlsResponse
   * @param cardByTokenizedNumberMap map of cards by tokenized card number
   * @description stores card controls on each card where tokenized card number is a match
   */
  private static void storeCardControlsOnCard(
    CardControlModel cardControlsListResponse,
    Map<String, CardListModel.CardCls> cardByTokenizedNumberMap
  ) {
    if (cardControlsListResponse.card_controls?.size() > 0) {
      for (
        CardControlModel.CardControlWrapper cardControlPerCard : cardControlsListResponse.card_controls
      ) {
        CardListModel.CardCls card = cardByTokenizedNumberMap.get(
          cardControlPerCard.tokenized_card_number
        );
        if (card != null) {
          card.cardControlsList = cardControlPerCard.card_controls;
        }
      }
    }
  }

  /**
   * @param cardListResponse list of cards to
   * @description handle throwing error for any cards in Issued status
   * which have controls enabled but no controlList stored
   */
  public static void verifyCardControlsStored(CardListModel cardListResponse) {
    for (CardListModel.CardCls card : cardListResponse.cards) {
      if (card.status == 'Issued' && card.cardControlsList == null) {
        throw new AuraHandledException(
          'Failed to retrieve card list. Please refresh and try again. Raise a fault through TechAssist if the problem persists.'
        );
      }
    }
  }
}
