/**
 * @author Lance Shi
 * @since 07/2022
 * @description InitiateInteractionController is apex side controller for Initiate Voice Call LWC
 */
public with sharing class InitiateInteractionController {
  public static final String PERMISSIONS_ERROR = 'Please check you have the permissions to create an Interaction';
  public static final String SEND_MESSAGE_ERROR = 'Failed to send the outbound chat message. Please try sending it again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @description Retrieves the phone number based on record context for the initiateInteraction LWC
   * @param sId Id to pass through to gather a records object context
   * @return `phoneNumber` Returns the phone number as relevant to object context
   */
  // PermissionUtils not used as it throws PMD errors
  @AuraEnabled
  public static String getPhoneNumber(Id sId) {
    String sobjectType = sId.getSObjectType().getDescribe().getName();
    String phoneNumber = '';
    if (sobjectType == 'Account' && PermissionUtils.canQuery('Account')) {
      Account acc = [SELECT Id, PersonMobilePhone FROM Account WHERE Id = :sId];
      phoneNumber = acc.PersonMobilePhone;
    } else if (sobjectType == 'Case' && PermissionUtils.canQuery('Case')) {
      Case c = [SELECT Id, Account.PersonMobilePhone FROM Case WHERE Id = :sId];
      phoneNumber = c.Account.PersonMobilePhone;
    } else if (
      sobjectType == 'Coaching_Summary__c' &&
      PermissionUtils.canQuery('Coaching_Summary__c')
    ) {
      Coaching_Summary__c cS = [
        SELECT Id, Account__r.PersonMobilePhone
        FROM Coaching_Summary__c
        WHERE Id = :sId
      ];
      phoneNumber = cS.Account__r.PersonMobilePhone;
    } else if (
      sobjectType == 'Interaction' && PermissionUtils.canQuery('Interaction')
    ) {
      Interaction i = [SELECT Id, Mobile__c FROM Interaction WHERE Id = :sId];
      phoneNumber = i.Mobile__c;
    } else if (sobjectType == 'Lead' && PermissionUtils.canQuery('Lead')) {
      Lead l = [SELECT Id, MobilePhone FROM Lead WHERE Id = :sId];
      phoneNumber = l.MobilePhone;
    }
    return phoneNumber;
  }

  /**
   * @description Creates the Interaction with the data presented
   * @param fields An Map<String, String> to pass in parameters to create the interaction
   * @return `newInteraction` Returns the newly created Interaction as an Interaction Object
   */
  @AuraEnabled
  public static Interaction createInteraction(Map<String, String> fields) {
    if (Interaction.sObjectType.getDescribe().isCreateable() == false) {
      throw new AuraHandledException(PERMISSIONS_ERROR);
    }
    if (Interaction.sObjectType.getDescribe().isQueryable() == false) {
      throw new AuraHandledException(PERMISSIONS_ERROR);
    }
    try {
      Interaction newInteraction = new Interaction(
        RecordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
          .get(fields.get('recordType'))
          .getRecordTypeId(),
        AccountId = fields.get('accountId'),
        CaseId__c = fields.get('caseId'),
        Coaching_Summary__c = fields.get('coachingSummaryId'),
        Lead__c = fields.get('leadId'),
        InteractionType = fields.get('interactionType'),
        Contact_Mobile__c = fields.get('contactNumber'),
        Direction__c = fields.get('direction'),
        Interaction_Purpose__c = fields.get('reason')
      );
      insert newInteraction;
      Interaction intToReturn = [
        SELECT Id, Interaction_External_Id__c
        FROM Interaction
        WHERE Id = :newInteraction.Id
        LIMIT 1
      ];
      return intToReturn;
    } catch (Exception e) {
      Logger.error('Failed creating Interaction', e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Initiates chat with customer
   * @param accountId the id of the customers account
   * @param messageContent contains the content of the message sent to initiate chat
   * @return `InitiateChatModel` Returns the response from the callout
   */
  @AuraEnabled
  public static InitiateChatModel initiateChat(
    Id accountId,
    String messageContent
  ) {
    CallCenterAPIRepository callCenterAPI = new CallCenterAPIRepository();
    try {
      if (PermissionUtils.canQuery('Account') == false) {
        CommonUtil.logAndThrowIAE(
          'InitiateInteractionController',
          'initiateChat',
          'Not enough permissions to query account.'
        );
      }

      Account acc = getAccountDetails(accountId, 'initiateChat');
      InitiateChatModel response = callCenterAPI.initiateChat(
        acc.OCV_ID__c,
        messageContent,
        acc.FirstName
      );

      //Confirm we have a conversationSID
      if (String.isBlank(response.conversationSid)) {
        Logger.error(
          'Failed initiating outbound chat. Missing conversationSID or chat ID'
        );
        Logger.saveLog();
        throw new AuraHandledException(SEND_MESSAGE_ERROR);
      }
      return response;
    } catch (Exception e) {
      throw new AuraHandledException(SEND_MESSAGE_ERROR);
    }
  }

  /**
   * @description Reinitiates chat with customer
   * @param accountId the id of the customers account
   * @param conversationSid the id of the chat to reinitiate
   * @return `ReinitiateChatModel` Returns the response from the callout
   */
  @AuraEnabled
  public static ReinitiateChatModel reinitiateChat(
    Id accountId,
    String conversationSid
  ) {
    CallCenterAPIRepository callCenterAPI = new CallCenterAPIRepository();
    try {
      Account acc = getAccountDetails(accountId, 'reinitiateChat');
      return callCenterAPI.reinitiateChat(acc.OCV_ID__c, conversationSid);
    } catch (CallCenterAPIRepository.CustomException e) {
      throw new AuraHandledException(e.getMessage());
    } catch (Exception e) {
      throw new AuraHandledException(SEND_MESSAGE_ERROR);
    }
  }

  /**
   * @description Fetches customer details
   * @param accountId the id of the customers account
   * @param methodName the name of the method calling this
   * @return `Account` Returns the customer
   */
  private static Account getAccountDetails(Id accountId, String methodName) {
    if (PermissionUtils.canQuery('Account') == false) {
      CommonUtil.logAndThrowIAE(
        'InitiateInteractionController',
        methodName,
        'Not enough permissions to query account.'
      );
    }
    Account accountRecord = [
      SELECT Id, OCV_ID__c, FirstName
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
    return accountRecord;
  }
}
