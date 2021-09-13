/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardReplaceController is used to handle the replace card with the replaceCard LWC
 */
public with sharing class CardReplaceController {
  /**
   * @param cardNumber card number to get replaced
   * @param ocvId customer id
   * @param reason reason to replace the card
   * @return `String` the new replaced card number
   * @description replace card when lost, stolen, damaged for use in LWC
   */
  @AuraEnabled(cacheable=false)
  public static String replaceCard(
    String cardNumber,
    String ocvId,
    String reason
  ) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    String result = coachapi.replaceCard(cardNumber, ocvId, reason);
    return result;
  }
}
