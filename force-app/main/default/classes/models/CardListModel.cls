/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
/**
 * @author Lance Shi
 * @since April 2021
 * @description Model for card list API
 */
public with sharing class CardListModel extends CalloutModel {
  public static final Set<String> VALID_WALLET_CARD_STATUSES = new Set<String>{
    'CARD_STATUS_CODE_ISSUED',
    'CARD_STATUS_CODE_TEMPORARYBLOCK'
  };
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
  public class FormattedDate {
    @AuraEnabled
    public DateCls year;
    @AuraEnabled
    public DateCls month;
    @AuraEnabled
    public DateCls day;
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
    @AuraEnabled
    public FormattedDate card_issue_date;
    @AuraEnabled
    public String delivery_status;
    @AuraEnabled
    public CardListModelV1.DeliveryDate delivery_date;

    /**
     * @description concate account numbers and show on card details screen
     */
    // ANZX-128122 : Show Account Numbers on Card Details section.
    @AuraEnabled
    public String concatAccountNumber {
      get {
        if (!this.account_numbers.isEmpty()) {
          return String.join(this.account_numbers, ',');
        }
        return null;
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
        List<String> listOfCapitalizedWallets = new List<String>();
        if (wallets == null || wallets.isEmpty()) {
          return new List<String>();
        }
        for (String key : this.wallets.keySet()) {
          if (this.wallets.get(key) == 0) {
            continue;
          }
          String keyStr = key != 'eCommerce' ? key.capitalize() : key;
          listOfCapitalizedWallets.add(keyStr + ' - ' + this.wallets.get(key));
        }
        return listOfCapitalizedWallets;
      }
      set;
    }

    /**
     * @description tells whether this card has any digital wallet
     */
    @AuraEnabled
    public Boolean hasWallet {
      get {
        return !walletList.isEmpty() &&
          VALID_WALLET_CARD_STATUSES.contains(status);
      }
      set;
    }

    /**
     * @description tells whether this card has controls enabled
     */
    public Boolean hasControlsEnabled {
      get {
        return this.card_controls_enabled != null &&
          this.card_controls_enabled == true;
      }
      set;
    }
  }
}
