/**
 * @author Ayushi Gupta
 * @since  03/2025
 * @description Batch class to set Lead status to Cancelled and send notifications when Expiry_Date__c is passed.
 */
public with sharing class ReferralLeadExpiryBatch implements Database.Batchable<sObject>, Schedulable {
  private static final String NEW_REFERRAL_STATUS = 'New';
  private static final String IN_PROGRESS_REFERRAL_STATUS = 'In Progress';

  /**
   * @description execute method to run ReferralExpiryBatch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new ReferralLeadExpiryBatch());
  }

  /**
   * @description Get all the Leads WHERE Expiry_Date__c < today AND Status = 'New/In progress'
   * @name start
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public static Database.QueryLocator start(Database.BatchableContext bc) {
    Id referralRecordTypeId = RTLead.referralLead;
    Set<String> leadReferralStatuses = new Set<String>{
      NEW_REFERRAL_STATUS,
      IN_PROGRESS_REFERRAL_STATUS
    };
    return Database.getQueryLocator(
      'SELECT Id, FinServ__ReferredByUser__c, RecordTypeId, Expiry_Date__c, Name, Referral_Status__c ' +
        'FROM Lead ' +
        'WHERE Referral_Status__c IN :leadReferralStatuses' +
        ' AND Expiry_Date__c < TODAY' +
        ' AND RecordTypeId = :referralRecordTypeId'
    );
  }

  /**
   * @description method to process data when batch is executed.
   * @name execute
   * @param bc Database.BatchableContext
   * @param leadScope from start method
   */
  public static void execute(
    Database.BatchableContext bc,
    List<Lead> leadScope
  ) {
    ReferralLeadExpiryHandler.updateCancelledLeads(leadScope);
    ReferralLeadExpiryHandler.sendNotification(leadScope);
  }

  /**
   * @description To execute any post processing steps
   * @name finish
   * @param bc Database.BatchableContext
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public static void finish(Database.BatchableContext bc) {
    //No post processing steps as of now
  }
}
