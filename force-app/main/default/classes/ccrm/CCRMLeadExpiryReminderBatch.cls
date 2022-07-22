/**
 * @author Sahil S
 * @since  10/2021
 * @description Batch class to send Reminder to Lead owners when Lead is about to get expired.
 */
public with sharing class CCRMLeadExpiryReminderBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all the Leads WHERE Expiry_Date__c = LAST_N_DAYS:n AND Status NOT IN ('Expired', 'Offer accepted', 'Converted')
   * @name start
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    string ccrmLeadRtId = CCRMConstants.CCRM_LEAD_RT_ID;
    Set<String> leadStatuses = new Set<String>{
      CCRMConstants.STATUS_NEW,
      CCRMConstants.STATUS_IN_PROGRESS
    };
    return Database.getQueryLocator(
      'SELECT Id, Status, Expiry_Date__c, OwnerId, Owner.Name, Name ' +
      'FROM Lead ' +
      'WHERE Status IN :leadStatuses' +
      ' AND CCRM_ExpiryNotificationCheck__c = true' +
      ' AND RecordTypeId = :ccrmLeadRtId'
    );
  }

  /**
   * @description method to process data when batch is executed.
   * @name execute
   * @param bc Database.BatchableContext
   * @param leadScope from start method
   */
  public void execute(Database.BatchableContext bc, List<Lead> leadScope) {
    ChatterPostActions.createLeadChatterPost(
      leadScope,
      Label.CCRM_ExpiryReminderMessage
    );
  }

  /**
   * @description To execute any post processing steps
   * @name finish
   * @param bc Database.BatchableContext
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public void finish(Database.BatchableContext bc) {
    //No post processing steps as of now
  }
}
