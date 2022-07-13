/**
 * @author Sahil S
 * @since  09/2021
 * @description Batch class to set Leads to Expired when Expiry_Date__c is passed.
 */
public with sharing class CCRMLeadExpiryBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all the Leads WHERE Expiry_Date__c <= yesterday AND Status != 'Expired'
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
      'SELECT Id, Status, Expiry_Date__c, Name ' +
      'FROM Lead ' +
      'WHERE Status IN :leadStatuses' +
      ' AND Expiry_Date__c <= YESTERDAY' +
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
    CCRMLeadExpiryHandler.updateExpiredLeads(leadScope);
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
