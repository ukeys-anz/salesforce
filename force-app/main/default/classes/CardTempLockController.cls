/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardTempLockController is used to handle the temporary card block with the Card Temp Block LWC
 */
public with sharing class CardTempLockController {
  /**
   * @description  The lockCard(cardNumber, ocvId) is the method to make the Http callout to Mulesoft to temporarily block the card.
   * @param cardNumber the tokenised card number
   * @param ocvId Ocv id for which account the card belongs to
   * @return Boolean
   */
  @AuraEnabled(cacheable=false)
  public static Boolean lockCard(String cardNumber, String ocvId) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    Boolean result = coachapi.lockCard(cardNumber, ocvId);
    return result;
  }
}
