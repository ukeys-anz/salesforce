/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritorySharingRecalculationBatch is batch class for sharing sobject record created by excluded users.
 * @runTests TerritorySharingRecalBatchTest
 */
global class TerritorySharingRecalculationBatch implements Database.Batchable<sObject> {
  private Territory_Based_Sharing_Config__mdt objShareMetadata;
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  /**
   * @description constructor method
   * @name TerritorySharingRecalculationBatch
   * @author Ashish Kumar
   * @US CC-4493
   */
  public TerritorySharingRecalculationBatch() {
  }
  /**
   * @description This method is used to schedule batch class for sharing sobject record created by excluded users.
   * @name TerritorySharingRecalculationBatch
   * @param objShareMetadata share metadata configuration records
   * @author Ashish Kumar
   * @US CC-4493
   */
  public TerritorySharingRecalculationBatch(
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
    String strWhereClause;
    String strLookupFields = composeLookupFields(this.objShareMetadata);
    DateTime objDateTime = System.Now()
      .addHours(
        (-1) * Integer.valueOf(objShareMetadata.Recalculation_Timeframe__c)
      );
    Set<Id> setOfExcludedUsers = getExcludedUsers(this.objShareMetadata);
    Set<Id> setOfEligibleRT = getEligibleRT(this.objShareMetadata);
    if (setOfEligibleRT != null) {
      strWhereClause = ' WHERE CreatedDate >=:objDateTime AND CreatedById IN: setOfExcludedUsers and RecordTypeId IN: setOfEligibleRT';
    } else {
      strWhereClause = ' WHERE CreatedDate >=:objDateTime AND CreatedById IN: setOfExcludedUsers';
    }
    return Database.getQueryLocator(
      composeQuery(strLookupFields, strWhereClause, this.objShareMetadata)
    );
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
    switch on this.objShareMetadata.Sharing_Scope__c {
      when 'Territory' {
        TerritorySharingUtil.createShareRecordsByTerritory(
          scope,
          this.objShareMetadata
        );
      }
      when 'Franchise' {
        TerritorySharingUtil.createShareRecordsByFranchise(
          scope,
          this.objShareMetadata
        );
      }
      when 'Parent Object' {
        //Method to create share record based on parent object
        TerritorySharingUtil.createShareRecordsForParentObj(
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

  /**
   * @description This method is used to share sobject record when any update happens to territory or user territory records.
   * @name composeLookupFields
   * @param objShareMetadata share metadata record
   * @return string lookup query string
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private string composeLookupFields(
    Territory_Based_Sharing_Config__mdt objShareMetadata
  ) {
    if (objShareMetadata.Lookup_Fields__c == null) {
      return '';
    }
    return String.join(objShareMetadata.Lookup_Fields__c.split(';'), ',') + ',';
  }

  /**
   * @description This method is used get set of excluded user ids
   * @name getExcludedUsers
   * @param objShareMetadata share metadata record
   * @return Set<Id> set of excluded users ids
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private Set<Id> getExcludedUsers(
    Territory_Based_Sharing_Config__mdt objShareMetadata
  ) {
    if (objShareMetadata.Excluded_Users__c == null) {
      return new Set<Id>();
    }
    return USER_REPOSITORY.getUserIdFromListOfUsername(
      objShareMetadata.Excluded_Users__c.split(';')
    );
  }

  /**
   * @description This method is used to share sobject record when any update happens to territory or user territory records.
   * @name getEligibleRT
   * @param objShareMetadata share metadata record
   * @return Set<Id> set of eligible record ids
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private Set<Id> getEligibleRT(
    Territory_Based_Sharing_Config__mdt objShareMetadata
  ) {
    if (objShareMetadata.Eligible_Record_Types__c == null) {
      return new Set<Id>();
    }
    return TerritoryCommonUtils.getRecordTypeIdsByDeveloperName(
      objShareMetadata.Object_Name__c,
      objShareMetadata.Eligible_Record_Types__c.split(';')
    );
  }

  /**
   * @description This method is used to share sobject record when any update happens to territory or user territory records.
   * @name composeQuery
   * @param strLookupFields lookup fields to be queried
   * @param strWhereClause where clause fields to be queried
   * @param objShareMetadata share metadata record
   * @return string composed query string
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private string composeQuery(
    String strLookupFields,
    String strWhereClause,
    Territory_Based_Sharing_Config__mdt objShareMetadata
  ) {
    return 'SELECT Id,OwnerId, ' +
      strLookupFields +
      String.escapeSingleQuotes(objShareMetadata.Territory_Field__c) +
      ' FROM ' +
      String.escapeSingleQuotes(objShareMetadata.Object_Name__c) +
      strWhereClause;
  }
}
