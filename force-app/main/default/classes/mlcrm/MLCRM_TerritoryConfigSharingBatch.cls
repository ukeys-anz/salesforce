/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRM_TerritoryConfigSharingBatch is batch class for sharing sobject record when any update happens to territory or user territory records.
 * @runTests MLCRM_TerritoryConfigSharingBatchTest
 */
global class MLCRM_TerritoryConfigSharingBatch implements Database.Batchable<sObject> {
  private Set<Id> idsOfTerritory;
  private Territory_Based_Sharing_Config__mdt objShareMetadata;

  /**
   * @description This method is used to share sobject record when any update happens to territory or user territory records.
   * @name MLCRM_TerritoryConfigSharingBatch
   * @param objShareMetadata share metadata configuration records
   * @param idsOfTerritory territories ids for which recalculation has to be done
   * @author Ashish Kumar
   * @US CC-4493
   */
  public MLCRM_TerritoryConfigSharingBatch(
    Territory_Based_Sharing_Config__mdt objShareMetadata,
    Set<Id> idsOfTerritory
  ) {
    this.objShareMetadata = objShareMetadata;
    this.idsOfTerritory = idsOfTerritory;
  }

  /**
   * @description This method is used to collect the data that has be shared with users.
   * @name start
   * @param objSchedule standard database batachable varaible
   * @return Database.QueryLocator locator object
   * @author Ashish Kumar
   * @US CC-4493
   */
  global Database.QueryLocator start(Database.BatchableContext objSchedule) {
    String strQuery;
    String strWhereClause;
    Set<Id> setOfEligibleRT;
    if (this.objShareMetadata.Eligible_Record_Types__c != null) {
      setOfEligibleRT = MLCRMCommonUtils.getRecordTypeIdsByDeveloperName(
        this.objShareMetadata.Object_Name__c,
        this.objShareMetadata.Eligible_Record_Types__c.split(';')
      );
      strWhereClause = ' WHERE Territory__c IN :idsOfTerritory AND RecordTypeId IN :setOfEligibleRT';
    } else {
      strWhereClause = ' WHERE Territory__c IN :idsOfTerritory';
    }
    strQuery =
      'SELECT Id,OwnerId,  ' +
      String.escapeSingleQuotes(this.objShareMetadata.Territory_Field__c) +
      ' FROM ' +
      String.escapeSingleQuotes(this.objShareMetadata.Object_Name__c) +
      strWhereClause;
    return Database.getQueryLocator(strQuery);
  }

  /**
   * @description This method is used to share sobject record when any update happens to territory or user territory records.
   * @name execute
   * @param objSchedule standard database batachable varaible
   * @param scope List of chunk records for which share records needs to be created.
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void execute(
    Database.BatchableContext objSchedule,
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
   * @param objSchedule standard database batachable varaible
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void finish(Database.BatchableContext objSchedule) {
  }
}
