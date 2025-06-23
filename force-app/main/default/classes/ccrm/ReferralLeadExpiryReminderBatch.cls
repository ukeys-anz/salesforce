/**
 * @author       : Naman Garg
 * @since        : March 2025
 * @description  : ReferralLeadExpiryReminderBatch is the Batch class for sending reminder to receiver's Manager 48 hrs before
 **/

public with sharing class ReferralLeadExpiryReminderBatch implements Database.Batchable<SObject>, Schedulable {
  /**
   * @description Get all the Referral Leads WHERE Expiry_Date__c = 48hrs AND Referral_Status__c = 'In Progress'
   * @name start
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Id referralRecordTypeId = RTLead.referralLead;
    String inProgressStatus = 'In Progress';
    Date todayPlus2Days = Date.Today().addDays(2);
    return Database.getQueryLocator(
      'SELECT Id, Expiry_Date__c, Referral_Status__c, OwnerId, FinServ__ReferredByUser__c ' +
        'FROM Lead ' +
        'WHERE RecordTypeId =: referralRecordTypeId ' +
        ' AND Expiry_Date__c =: todayPlus2Days ' +
        ' AND Referral_Status__c =: inProgressStatus '
    );
  }

  /**
   * @description method to process data when batch is executed.
   * @name execute
   * @param bc Database.BatchableContext
   * @param referralLeadList from start method
   */
  public void execute(
    Database.BatchableContext bc,
    List<Lead> referralLeadList
  ) {
    try {
      ReferralLeadExpiryHandler.sendExpiryReminder(referralLeadList);
    } catch (Exception e) {
      Logger.error(
          'Error while sending bell notification to Owners of referral',
          e
        )
        .save();
    }
  }

  /**
   * @description To execute any post processing steps
   * @name finish
   * @param bc Database.BatchableContext
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public void finish(Database.BatchableContext bc) {
  }

  /**
   * @description execute method to run batch class
   * @name execute
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new ReferralLeadExpiryReminderBatch());
  }
}
