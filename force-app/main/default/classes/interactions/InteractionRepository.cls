/**
 * @author Kopal Goswami
 * @since Sep 9 2024
 * @description Provides SOQL helpers for Interaction object
 */
public with sharing class InteractionRepository {
  /**
   * @description query existing Interaction Record
   * @param callOrChatSidList Set<String> containing callOrChatSid from Interaction
   * @return Map<String, Interaction> Map of chatOrCallSID and Interaction record
   */
  public Map<String, Interaction> queryExistingInteractionFromCallOrChatSID(
    Set<String> callOrChatSidList
  ) {
    Map<String, Interaction> existingInteractionsBySID = new Map<String, Interaction>();
    if (callOrChatSidList.isEmpty()) {
      return existingInteractionsBySID;
    }

    for (Interaction interact : [
      SELECT
        Id,
        Interaction_External_Id__c,
        Account.OCV_ID__c,
        Chat_or_Call_SID__c,
        Chat_or_Call_SID_Formula__c
      FROM Interaction
      WHERE
        Chat_or_Call_SID__c IN :callOrChatSidList
        OR Chat_or_Call_SID_Formula__c IN :callOrChatSidList
      WITH SECURITY_ENFORCED
    ]) {
      String chatOrCallSid = interact.Chat_or_Call_SID__c ??
        interact.Chat_or_Call_SID_Formula__c;
      existingInteractionsBySID.put(chatOrCallSid, interact);
    }
    return existingInteractionsBySID;
  }
}
