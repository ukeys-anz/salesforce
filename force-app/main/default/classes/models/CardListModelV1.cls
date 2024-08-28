/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
/**
 * @author Nilesh
 * @since Aug 2024
 * @description Model for transaction card list API V1
 */
public with sharing class CardListModelV1 extends CalloutModel {
  @AuraEnabled
  public List<CardCls> cards;

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
    public String tokenizedCardNumber;
    @AuraEnabled
    public String last4Digits;
    @AuraEnabled
    public String statusCode;
    @AuraEnabled
    public Embossing embossing;
    @AuraEnabled
    public CardListModel.ExpiryDateCls expiryDate;
    @AuraEnabled
    public List<String> accounts;
    @AuraEnabled
    public List<String> eligibility;
    @AuraEnabled
    public Map<String, Integer> wallets;
    @AuraEnabled
    public Boolean cardControlsEnabled;
    @AuraEnabled
    public CardListModel.FormattedDate cardIssueDate;
    @AuraEnabled
    public Tracking tracking;
  }

  /**
   * @description Embossing contains Card holder name in line_one
   */
  public class Embossing {
    public String lineOne;
  }

  /**
   * @description Tracking contains Card holder name in line_one
   */
  public class Tracking {
    public String state;
    public DeliveryDate stateReportedDate;
  }

  /**
   * @description the card information wrapper
   */
  public class DeliveryDate {
    @AuraEnabled
    public Integer year;
    @AuraEnabled
    public Integer month;
    @AuraEnabled
    public Integer day;
  }

  /**
   * @param jsonString input string to deserialize
   * * @param mapOfAccountNumberAndOwnership input map of account number and ownership
   * @return `CardListModelV1`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CardListModel parse(
    String jsonString,
    Map<String, String> mapOfAccountNumberAndOwnership
  ) {
    CardListModelV1 cardListModelV1 = (CardListModelV1) deserialize(
      jsonString,
      CardListModelV1.class
    );
    CardListModel cardmodel = CardListModelConverter.convertToCardListModel(
      cardListModelV1,
      mapOfAccountNumberAndOwnership
    );
    return cardmodel;
  }
}
