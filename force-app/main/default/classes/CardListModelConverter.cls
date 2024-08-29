/**
 * @author Nilesh
 * @since August 2024
 * @description Conversion Layer to convert V1 model to V1B1
 * source model = V1 and dest model = v1b1
 */
public with sharing class CardListModelConverter {
  /**
   * @description CardListModelConverter converts the v1 response back to v1beta1 response
   * @param sourceModel Holds the values of v1
   * @param mapOfAccountNumberAndOwnership Holds the values of v1
   * @return CardListModel which holds the converted value of v1beta1
   */
  public static CardListModel convertToCardListModel(
    CardListModelV1 sourceModel,
    Map<String, String> mapOfAccountNumberAndOwnership
  ) {
    CardListModel cardListModelInstance = new CardListModel();
    cardListModelInstance.cards = new List<CardListModel.CardCls>();

    for (CardListModelV1.CardCls sourceCard : sourceModel.cards) {
      CardListModel.CardCls destCard = new CardListModel.CardCls();
      destCard.name = sourceCard?.embossing?.lineOne;
      destCard.account_numbers = trimAccountNumber(sourceCard.accounts);
      destCard.last_4_digits = sourceCard.last4Digits;
      destCard.expiry_date = sourceCard.expiryDate;
      destCard.status = sourceCard.statusCode;
      destCard.eligibilities = sourceCard.eligibility;
      destCard.tokenized_card_number = sourceCard.tokenizedCardNumber;
      destCard.card_controls_enabled = sourceCard.cardControlsEnabled;
      destCard.card_issue_date = sourceCard.cardIssueDate;
      destCard.wallets = sourceCard.wallets;
      destCard.delivery_status = sourceCard?.tracking?.state;
      destCard.delivery_date = sourceCard?.tracking?.stateReportedDate;
      destCard.accountType = getAccountTypeOfCard(
        destCard.account_numbers,
        mapOfAccountNumberAndOwnership
      );
      cardListModelInstance.cards.add(destCard);
    }
    return cardListModelInstance;
  }
  /**
   * @description trims the account number list
   * @param listOfAccountNumbers an array of account numbers from source model that is V1
   * @return List<String> listOfTrimmedAccountNumbers
   */
  @TestVisible
  private static List<String> trimAccountNumber(
    List<String> listOfAccountNumbers
  ) {
    if (listOfAccountNumbers == null) {
      return null;
    }
    List<String> listOfTrimmedAccountNumbers = new List<String>();
    for (String forEachAccountNumber : listOfAccountNumbers) {
      listOfTrimmedAccountNumbers.add(forEachAccountNumber.remove('accounts/'));
    }
    return listOfTrimmedAccountNumbers;
  }

  /**
   * @param lisOfAccountNumbers account numbers list for each card
   * @param mapOfAccountNumberAndOwnership input map of account number and ownership
   * @return String updatedAccountType
   * @description Sets accountType for each card data.
   */
  @TestVisible
  private static String getAccountTypeOfCard(
    List<String> lisOfAccountNumbers,
    Map<String, String> mapOfAccountNumberAndOwnership
  ) {
    for (String accnumber : lisOfAccountNumbers) {
      if (mapOfAccountNumberAndOwnership.containsKey(accnumber)) {
        return mapOfAccountNumberAndOwnership.get(accnumber) ==
          FinancialAccountConstant.MULTI_PARTY
          ? FinancialAccountConstant.JOINT
          : FinancialAccountConstant.SOLE;
      }
    }
    return null;
  }
}
