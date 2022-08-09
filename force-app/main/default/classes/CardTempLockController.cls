/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardTempLockController is used to handle the temporary card block
 * with the Card Temp Block LWC and Card Replace LWC
 */
public with sharing class CardTempLockController {
  /**
   * @description the card control type which places temp lock on customer card
   */
  @testVisible
  private static final String GCT_GLOBAL_CONTROL_STRING = 'GCT_GLOBAL';

  /**
   * @description  lockCard calls card controls to place card temp lock
   * @param cardNumber the tokenised card number
   * @param ocvId Ocv id for which account the card belongs to
   * @return `Boolean` confirms whether lock was successfully placed
   */
  @AuraEnabled(cacheable=false)
  public static Boolean lockCard(String cardNumber, String ocvId) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();

    CardControlModel.CardControlWrapper result = coachapi.lockCard(
      cardNumber,
      ocvId
    );

    // Validates lockCard success if control type returned in response matches control type sent in request
    Boolean tempLockSuccessful = result?.card_controls[0].control_type ==
      GCT_GLOBAL_CONTROL_STRING
      ? true
      : false;

    return tempLockSuccessful;
  }
}
