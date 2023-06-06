/**
 * @author Boobalakrishnan Duraisamy
 * @since 03/2023
 * @description Temporary batch class to transform and update external id field in financial account role object.
 */

public with sharing class CCRMUpdateFARExternalIdBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all financial account rolew records where external id is not null
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, External_Id__c, Temporary_External_Id__c
        FROM FinServ__FinancialAccountRole__c
        WHERE External_ID__c != NULL AND Temporary_External_ID__c = NULL
      ]
    );
  }

  /**
   * @description  copies the external id into a temporary field, transform the external id and updates the FAR object
   * @param bc Database.BatchableContext
   * @param farRecords from start method
   */

  public void execute(
    Database.BatchableContext bc,
    List<FinServ__FinancialAccountRole__c> farRecords
  ) {
    if (
      FinServ__FinancialAccountRole__c.sObjectType.getDescribe().isUpdateable()
    ) {
      for (FinServ__FinancialAccountRole__c far : farRecords) {
        far.Temporary_External_Id__c = far.External_Id__c;
        far.External_Id__c = far.External_Id__c.substringAfter('_');
      }
      List<Database.saveResult> result = Database.update(farRecords, false);
      Logger.error('', result);
      Logger.saveLog();
    }
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
  }
}
