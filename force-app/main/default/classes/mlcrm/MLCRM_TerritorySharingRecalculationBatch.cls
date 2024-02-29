/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRM_TerritorySharingRecalculationBatch is batch class for sharing sobject record created by excluded users.
 * @runTests MLCRM_TerritoryRecalculationBatchTest
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
    String strWhereClause;
    String strLookupFields = '';
    DateTime objDateTime = System.Now()
      .addHours(
        (-1) * Integer.valueOf(this.objShareMetadata.Recalculation_Timeframe__c)
      );
    Set<Id> setOfExcludedUsers = MLCRMCommonUtils.getUserIdFromUsername(
      this.objShareMetadata.Excluded_Users__c.split(';')
    );
    if (this.objShareMetadata.Eligible_Record_Types__c != null) {
      Set<Id> setOfEligibleRT = MLCRMCommonUtils.getRecordTypeIdsByDeveloperName(
        this.objShareMetadata.Object_Name__c,
        this.objShareMetadata.Eligible_Record_Types__c.split(';')
      );
      strWhereClause = ' WHERE CreatedDate >=:objDateTime AND CreatedById IN: setOfExcludedUsers and RecordTypeId IN: setOfEligibleRT';
    } else {
      strWhereClause = ' WHERE CreatedDate >=:objDateTime AND CreatedById IN: setOfExcludedUsers';
    }
    if (objShareMetadata.Lookup_Fields__c != null) {
      strLookupFields =
        String.join(objShareMetadata.Lookup_Fields__c.split(';'), ',') + ',';
    }
    strQuery =
      'SELECT Id,OwnerId, ' +
      strLookupFields +
      String.escapeSingleQuotes(this.objShareMetadata.Territory_Field__c) +
      ' FROM ' +
      String.escapeSingleQuotes(this.objShareMetadata.Object_Name__c) +
      strWhereClause;
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
      if (
        this.objShareMetadata.Sharing_Scope__c == MLCRMConstants.STR_TERRITORY
      ) {
        MLCRMSharingUtil.createTerritoryShareRecords(
          scope,
          this.objShareMetadata
        );
      } else if (
        this.objShareMetadata.Sharing_Scope__c == MLCRMConstants.STR_FRANCHISE
      ) {
        MLCRMSharingUtil.createShareRecordsFranchiseWise(
          scope,
          this.objShareMetadata
        );
      } else if (
        this.objShareMetadata.Sharing_Scope__c ==
        MLCRMConstants.STR_PARENT_OBJECT
      ) {
        //Method to create share record based on parent object
        MLCRMCommonUtils.parentObjectRecordSharing(
          scope,
          this.objShareMetadata
        );
      }
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
