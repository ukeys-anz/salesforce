/**
 * @author Hrushikesh Pathak
 * @since 11/2023
 * @description  Get All the BOH Lead and closes them if criteria not satisfied.
 */
public with sharing class BOHLeadAutoClosureBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all not actioned BOH Leads
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          FirstName,
          LastName,
          Is_BOH_Lead__c,
          Email,
          MobilePhone,
          Status,
          LeadSource,
          OpportunityType__c,
          SubStatus__c,
          CreatedDate
        FROM Lead
        WHERE Is_BOH_Lead__c = TRUE AND Status = 'New'
      ]
    );
  }

  /**
   * @description  Auto Close the BOH Lead if criteria matches for the auto closure
   * @param bc Database.BatchableContext
   * @param leadRecords from start method
   */

  public void execute(Database.BatchableContext bc, List<Lead> leadRecords) {
    BOHLeadActions.autoCloseBOHLeads(leadRecords);
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
  }
}
