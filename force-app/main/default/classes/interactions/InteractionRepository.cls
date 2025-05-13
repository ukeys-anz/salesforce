/**
 * @author Kopal Goswami
 * @since Sep 9 2024
 * @description Provides SOQL helpers for Interaction object
 */
public with sharing class InteractionRepository {
  /**
   * @description query existing Interaction Record based on callOrChatSid from Twilio
   * @param callOrChatSid String containing callOrChatSid from Twilio
   * @return Map<String, Interaction> Map of chatOrCallSID and Interaction record
   */
  public Map<String, Interaction> queryExistingInteractionFromCallOrChatSID(
    String callOrChatSid
  ) {
    Map<String, Interaction> existingInteractionsBySID = new Map<String, Interaction>();
    if (String.isBlank(callOrChatSid)) {
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
        Chat_or_Call_SID__c = :callOrChatSid
        OR Chat_or_Call_SID_Formula__c = :callOrChatSid
      WITH USER_MODE
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
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description query User based on agentEmail
   * @param agentEmail agentEmail from Twilio
   * @return User record
   */
  public User fetchAgentUserId(String agentEmail) {
    if (String.isBlank(agentEmail)) {
      return null;
    }

    return [
      SELECT Id, FederationIdentifier
      FROM User
      WHERE FederationIdentifier = :agentEmail AND IsActive = TRUE
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
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

  /**
   * @description query Existing Account Record based on the ocvId received
   * @param ocvIdFromTwilio ocvid received from Twilio
   * @return Account record existing
   */
  public List<Account> fetchExistingAccountByOCVId(String ocvIdFromTwilio) {
    if (String.isBlank(ocvIdFromTwilio)) {
      return new List<Account>();
    }
    return [
      SELECT Id, OCV_ID__c, PPID__c
      FROM Account
      WHERE OCV_ID__c = :ocvIdFromTwilio AND ANZx_Customer__c = TRUE
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description query Interaction Details created successfully
   * @param interactionId recordId of the Interaction
   * @return Interaction record details
   */
  public Interaction getInteractionDetails(Id interactionId) {
    if (String.isBlank(interactionId)) {
      return null;
    }
    return [
      SELECT Id, Interaction_External_Id__c, TwilioDetailsID__c, CaseId__c
      FROM Interaction
      WHERE Id = :interactionId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Fetch task details for sending back to Twilio as response
   * @param pubSubEventId pubSubEventId received from Twilio
   * @return Task record details
   */
  public List<Task> queryPushToAppTaskDetails(String pubSubEventId) {
    if(String.isBlank(pubSubEventId))
    {
       return new List<Task>();
    }

    return [
      SELECT Id, Pub_Sub_Event_Id__c, WhatId
      FROM Task
      WHERE Pub_Sub_Event_Id__c = :pubSubEventId
      WITH USER_MODE
    ];
  }
}
