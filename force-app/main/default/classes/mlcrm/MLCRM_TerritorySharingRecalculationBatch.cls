/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRM_TerritorySharingRecalculationBatch is batch class for sharing sobject record created by excluded users.
 */
global class MLCRM_TerritorySharingRecalculationBatch implements Database.Batchable<sObject> {
  private Territory_Based_Sharing_Config__mdt objShareMetadata;

  /**
   * @description This method is used to schedule batch class for sharing sobject record created by excluded users.
   * @name MLCRM_TerritorySharingRecalculationBatch
   * @param objShareMetadata share metadata configuration records
   * @author Ashish Kumar
   * @US CC-4493
   */
  public MLCRM_TerritorySharingRecalculationBatch(
    Territory_Based_Sharing_Config__mdt objShareMetadata
  ) {
    this.objShareMetadata = objShareMetadata;
  }

  /**
   * @description This method is used to collect the data that has be shared with users.
   * @name start
   * @param objBatchable standard database batachable varaible
   * @return Database.QueryLocator query locater instance
   * @author Ashish Kumar
   * @US CC-4493
   */
  global Database.QueryLocator start(Database.BatchableContext objBatchable) {
    String strQuery;
    DateTime objDateTime = System.Now()
      .addHours(
        (-1) * Integer.valueOf(this.objShareMetadata.Recalculation_Timeframe__c)
      );
    Set<Id> setOfExcludedUsers = MLCRMCommonUtils.getUserIdFromUsername(
      this.objShareMetadata.Excluded_Users__c.split(';')
    );
    Set<Id> setOfEligibleRT = MLCRMCommonUtils.getTaskRecordTypeIdByDeveloperName(
      this.objShareMetadata.Object_Name__c,
      this.objShareMetadata.Eligible_Record_Types__c.split(';')
    );
    strQuery =
      'SELECT Id,OwnerId, ' +
      String.escapeSingleQuotes(this.objShareMetadata.Territory_Field__c) +
      ' FROM ' +
      String.escapeSingleQuotes(this.objShareMetadata.Object_Name__c) +
      ' WHERE CreatedDate >=:objDateTime AND CreatedById IN: setOfExcludedUsers and RecordTypeId IN: setOfEligibleRT';
    return Database.getQueryLocator(strQuery);
  }

  /**
   * @description This method is used to schedule batch class for sharing sobject record created by excluded users.
   * @name execute
   * @param objBatchable standard database batachable varaible
   * @param scope List of chunk records for which share records needs to be created.
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void execute(
    Database.BatchableContext objBatchable,
    List<SObject> scope
  ) {
    if (!scope.isEmpty()) {
      MLCRMSharingUtil.createTerritoryShareRecords(
        scope,
        this.objShareMetadata.Sharing_Object__c,
        this.objShareMetadata.Object_Name__c
      );
    }
  }

  /**
   * @description This method runs when all batch job gets completed
   * @name finish
   * @param objBatchable standard database batachable varaible
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void finish(Database.BatchableContext objBatchable) {
  }
}
