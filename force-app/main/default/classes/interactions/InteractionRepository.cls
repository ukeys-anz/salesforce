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

  /**
   * @description query existing Interaction Record to get TwilioDetailId associated
   * @param interactionId Interaction Id from Twilio for updating
   * @return Interaction record with Twilio Details
   */
  public Interaction fetchTwilioDetailIdFromInteraction(Id interactionId) {
    if (interactionId == null) {
      return null;
    }

    return [
      SELECT TwilioDetailsID__c
      FROM Interaction
      WHERE Id = :interactionId
      WITH SECURITY_ENFORCED
    ];
  }

  /**
   * @description query User based on agentEmail
   * @param agentEmail agentEmail from Twilio
   * @return List of User
   */
  public List<User> fetchAgentUserId(String agentEmail) {
    if (String.isBlank(agentEmail) || SObjectType.User.isQueryable() == false) {
      return new List<User>();
    }

    return [
      SELECT Id, FederationIdentifier
      FROM User
      WHERE FederationIdentifier = :agentEmail AND IsActive = TRUE
    ];
  }

  /**
   * @description query ocvId based on customer on Interaction
   * @param refObject object reference to get OCVId from related account
   * @param recordId record id
   * @return SObject
   */
  public SObject fetchOCVId(String refObject, String recordId) {
    Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe()
      .get(refObject)
      .getDescribe();
    if (String.isBlank(refObject) || !describeResult.isQueryable()) {
      return null;
    }
    return Database.query(
      'SELECT Account.OCV_ID__c FROM ' +
        String.escapeSingleQuotes(refObject) +
        ' WHERE Id = :recordId'
    );
  }

  /**
   * @description find accounts based on OCVId
   * @param ocvId String ocvid to search account details
   * @return Account record
   */
  public Account findAccountByOCVId(String ocvId) {
    PermissionUtils.canQuery('Account');
    return [
      SELECT PersonContactId
      FROM Account
      WHERE
        OCV_ID__c = :ocvId
        AND RecordTypeId = :QueryRT.of(Account.SObjectType)
          .getId('PersonAccount')
        AND ANZx_Customer__c = TRUE
    ];
  }
}