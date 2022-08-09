/**
 *
 * @author Emma Bindi
 * @since July 2022
 * @description DisputesController is the controller for handling disputes functions called from LWC
 */
public with sharing class DisputesController {
  /**
   * @description  The getTokenizedCardNumber is the method to make the callout to Mulesoft to fetch the tokenized card number from Fabric
   * @param ocvId Ocv id for which tokenized card needs to be fetched
   * @param transactionId The id of the transaction relating to the dispute
   * @return `String` containing the tokenized card number
   */
  @AuraEnabled
  public static string getTokenizedCardNumber(
    String ocvId,
    String transactionId
  ) {
    DisputesAPIRepository disputesAPI = new DisputesAPIRepository();

    String tokenizedCard = disputesAPI.getTokenizedCardNumber(
      ocvId,
      transactionId
    );
    return tokenizedCard;
  }
}
