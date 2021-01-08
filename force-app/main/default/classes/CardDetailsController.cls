/**
 * @author Peter Charalambous
 * @since 2020
 * @description CardDetailsController is the apex side controller for the cardDetails LWC
 */
public with sharing class CardDetailsController {
  /**
   * @description The Card Details component uses this to fetch the record details to display.
   *
   * @param recordId the card record to retrieve
   * @return List<FinServ__Card__c>
   */
  @AuraEnabled
  public static List<FinServ__Card__c> getCardDetails(Id recordId) {
    List<FinServ__Card__c> cardDetails;
    if (FinServ__Card__c.sObjectType.getDescribe().isQueryable()) {
      cardDetails = [
        SELECT Card_Number__c, FinServ__AccountHolder__r.Name
        FROM FinServ__Card__c
        WHERE Id = :recordId
      ];
    }

    if (cardDetails.isEmpty()) {
      return null;
    }

    return cardDetails;
  }
}
