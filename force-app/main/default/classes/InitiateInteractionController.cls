/**
 * @author Lance Shi
 * @since 07/2022
 * @description InitiateInteractionController is apex side controller for Initiate Voice Call LWC
 */
public with sharing class InitiateInteractionController {
  public static final String PERMISSIONS_ERROR = 'Please check you have the permissions to create an Interaction';

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
    try {
      Interaction intToReturn = new Interaction();
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
      if (Interaction.sObjectType.getDescribe().isCreateable()) {
        insert newInteraction;
        if (Interaction.sObjectType.getDescribe().isQueryable()) {
          intToReturn = [
            SELECT Id, Interaction_External_Id__c
            FROM Interaction
            WHERE Id = :newInteraction.Id
          ];
        }
        return intToReturn;
      } else {
        throw new System.AuraHandledException(PERMISSIONS_ERROR);
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
