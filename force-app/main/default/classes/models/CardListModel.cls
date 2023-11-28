/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.FieldNamingConventions, PMD.VariableNamingConventions, PMD.TooManyFields, PMD.PropertyNamingConventions'
)
/**
 * @author Lance Shi
 * @since April 2021
 * @description Model for card list API
 */
public with sharing class CardListModel extends CalloutModel {
  @AuraEnabled
  public List<CardCls> cards;

  /**
   * @description the card information wrapper
   */
  public class ExpiryDateCls {
    @AuraEnabled
    public DateCls year;
    @AuraEnabled
    public DateCls month;
  }

  /**
   * @description the card information wrapper
   */
  public class DateCls {
    @AuraEnabled
    public Integer value;
  }

  /**
   * @description the card information wrapper
   */
  public class CardCls {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String tokenized_card_number;
    @AuraEnabled
    public String last_4_digits;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public ExpiryDateCls expiry_date;
    @AuraEnabled
    public List<String> account_numbers;
    /**
     * @description concate account numbers and show on card details screen
     */
    // ANZX-128122 : Show Account Numbers on Card Details section.
    @AuraEnabled
    public String concatAccountNumber {
      get {
        String accountNumbers;
        if (this.account_numbers != null && !this.account_numbers.isEmpty()) {
          accountNumbers = (this.account_numbers.size() > 0)
            ? String.join(this.account_numbers, ',')
            : this.account_numbers[0];
        }
        return accountNumbers;
      }
      set;
    }

    @AuraEnabled
    public List<String> eligibilities;
    @AuraEnabled
    public Map<String, Integer> wallets;
    @AuraEnabled
    public Boolean card_controls_enabled;
    @AuraEnabled
    public String accountType;

    /**
     * @description stores the card controls for the card
     */
    @AuraEnabled
    public List<CardControlModel.CardControlCls> cardControlsList;

    /**
     * @description validates response for expected values by the UI
     */
    @AuraEnabled
    public Boolean isValid {
      get {
        return (String.isNotBlank(this.name) &&
          String.isNotBlank(this.last_4_digits) &&
          this.expiry_date.month.value != null &&
          this.expiry_date.year.value != null &&
          String.isNotBlank(this.status))
          ? true
          : false;
      }
      set;
    }

    /**
     * @description translate the wallet map into a list to be displayed on the UI
     */
    @AuraEnabled
    public List<String> walletList {
      get {
        List<String> wList = new List<String>();
        if (wallets != null && !wallets.isEmpty()) {
          for (String key : this.wallets.keySet()) {
            if (this.wallets.get(key) != 0) {
              String keyStr = key;
              if (keyStr != 'eCommerce') {
                keyStr = keyStr.capitalize();
              }
              wList.add(keyStr + ' - ' + this.wallets.get(key));
            }
          }
        }
        return wList;
      }
      set;
    }

    /**
     * @description tells whether this card has any digital wallet
     */
    @AuraEnabled
    public Boolean hasWallet {
      get {
        if (
          !walletList.isEmpty() &&
          (status == 'Issued' ||
          status == 'Temporary Block')
        ) {
          return true;
        } else {
          return false;
        }
      }
      set;
    }

    /**
     * @description tells whether this card has controls enabled
     */
    public Boolean hasControlsEnabled {
      get {
        if (
          this.card_controls_enabled != null &&
          this.card_controls_enabled == true
        ) {
          return true;
        } else {
          return false;
        }
      }
      set;
    }
  }

  /**
   * @param json input string to deserialize
   * @param mapOfAccountNumberAndOwnership input map of account number and ownership
   * @return `CardListModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CardListModel parse(
    String json,
    Map<String, String> mapOfAccountNumberAndOwnership
  ) {
    CardListModel cardmodel = (CardListModel) deserialize(
      json,
      CardListModel.class
    );
    List<CardCls> listOfCards = cardmodel.cards;
    for (CardCls card : listOfCards) {
      if (card.account_numbers != null && !card.account_numbers.isEmpty()) {
        for (String accnumber : card.account_numbers) {
          if (mapOfAccountNumberAndOwnership.containsKey(accnumber)) {
            card.accountType = mapOfAccountNumberAndOwnership.get(accnumber) ==
              GetHelpConstants.MULTI_PARTY
              ? GetHelpConstants.JOINT
              : GetHelpConstants.SINGLE;
          }
        }
      }
    }
    return cardmodel;
  }
}
