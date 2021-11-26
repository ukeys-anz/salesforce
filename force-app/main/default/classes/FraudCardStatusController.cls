/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description FraudCardStatusController to handle fraud lock/unlock/cancel card with cardFraudLock LWC
 */
public with sharing class FraudCardStatusController {
  /**
   * @param fraudLockObject which is a `Map<String,Map<String,String>>` that contains:
   * 1. `Map<String,String>` chatterInformation which contains:
   * - recordId to make a chatter post on it's page
   * - chatterMessage to make the chatter post
   * 2. `Map<String,String>` fraudLockInformation which contains:
   * - cardNumber card number to send to api
   * - ocvId customer id
   * - status chosen by fraud agent
   * - reason for fraud action. If chosen to cancel the card, this will be "Fraud"
   * @return `Boolean` to check if it is successful or not
   * @description fraud lock/unlock/cancel/remove temporary lockin LWC and making a chatter post
   */
  @AuraEnabled(cacheable=false)
  public static Boolean setFraudCardStatus(
    Map<String, Map<String, String>> fraudLockObject
  ) {
    Map<String, String> chatterInformation = fraudLockObject.get(
      'chatterInformation'
    );
    Map<String, String> fraudLockInformation = fraudLockObject.get(
      'fraudLockInformation'
    );

    String recordId = chatterInformation.get('recordId');
    String chatterMessage = chatterInformation.get('chatterMessage');

    CardManagementAPIRepository cardManagementApi = new CardManagementAPIRepository();
    Boolean result = cardManagementApi.setFraudCardStatus(fraudLockInformation);

    ChatterUtils.makeAPost(recordId, chatterMessage);

    return result;
  }
}
