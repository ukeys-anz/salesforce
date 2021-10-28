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
  public class CardCls {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String tokenizedCardNumber;
    @AuraEnabled
    public String last4Digits;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String expiryDate;
    @AuraEnabled
    public String accountNumber;
    @AuraEnabled
    public List<String> eligibilities;
    @AuraEnabled
    public Map<String, Integer> wallets;

    /**
     * @description validates response for expected values by the UI
     */
    @AuraEnabled
    public Boolean isValid {
      get {
        return (String.isNotBlank(this.name) &&
          String.isNotBlank(this.last4Digits) &&
          String.isNotBlank(this.expiryDate) &&
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
        for (String key : this.wallets.keySet()) {
          if (this.wallets.get(key) != 0) {
            String keyStr = key;
            if (keyStr != 'eCommerce') {
              keyStr = keyStr.capitalize();
            }
            wList.add(keyStr + ' - ' + this.wallets.get(key));
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
        return !walletList.isEmpty();
      }
      set;
    }
  }

  /**
   * @param json input string to deserialize
   * @return `CardListModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CardListModel parse(String json) {
    return (CardListModel) deserialize(json, CardListModel.class);
  }
}
