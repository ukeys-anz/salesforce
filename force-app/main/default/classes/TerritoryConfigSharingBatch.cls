/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritoryConfigSharingBatch is batch class for sharing sobject record when any update happens to territory or user territory records.
 * UnusedLocalVariable Surpressed : Used variable in dynamic query
 * @runTests TerritoryConfigSharingBatchTest
 */
@SuppressWarnings('PMD.UnusedLocalVariable')
global class TerritoryConfigSharingBatch implements Database.Batchable<sObject> {
  private Set<Id> idsOfTerritory;
  private Territory_Based_Sharing_Config__mdt objShareMetadata;
  private Set<Id> setOfEligibleRT;

  /**
   * @description constructor method
   * @name TerritoryConfigSharingBatch
   * @author Ashish Kumar
   * @US CC-4493
   */
  public TerritoryConfigSharingBatch() {
  }
  /**
   * @description This method is used to share sobject record when any update happens to territory or user territory records.
   * @name TerritoryConfigSharingBatch
   * @param objShareMetadata share metadata configuration records
   * @param idsOfTerritory territories ids for which recalculation has to be done
   * @author Ashish Kumar
   * @US CC-4493
   */
  public TerritoryConfigSharingBatch(
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
    String strWhereClause;
    String strExpiredWhereClause = getExpiredWhereClause(this.objShareMetadata);
    String strLookupFields = composeLookupFields(this.objShareMetadata);
    Set<Id> setOfEligibleRT = getEligibleRT(this.objShareMetadata);
    String strRecordTypeWhereClause = objShareMetadata.Eligible_Record_Types__c !=
      null
      ? 'AND RecordTypeId IN :setOfEligibleRT '
      : ' ';
    strWhereClause =
      ' WHERE Territory__c IN :idsOfTerritory ' +
      strRecordTypeWhereClause +
      strExpiredWhereClause;

    return Database.getQueryLocator(
      composeQuery(strLookupFields, strWhereClause, this.objShareMetadata)
    );
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
    if (scope.isEmpty()) {
      return;
    }
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
   * @param objSchedule standard database batachable varaible
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void finish(Database.BatchableContext objSchedule) {
  }

  /* @description This method is used get set of excluded user ids
   * @name getExpiredWhereClause
   * @param objShareMetadata share metadata record
   * @return String Expired where clause
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private String getExpiredWhereClause(
    Territory_Based_Sharing_Config__mdt objShareMetadata
  ) {
    return objShareMetadata.Object_Name__c == 'Lead'
      ? ' AND Status != \'Expired\''
      : '';
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
    Set<Id> setOfEligibleRT = new Set<Id>();
    if (objShareMetadata.Eligible_Record_Types__c == null) {
      return new Set<Id>();
    }
    setOfEligibleRT = CommonUtil.getRecordTypeIdsByDeveloperName(
      objShareMetadata.Object_Name__c,
      objShareMetadata.Eligible_Record_Types__c.split(';')
    );
    return setOfEligibleRT;
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
    return objShareMetadata.Lookup_Fields__c != null
      ? String.join(objShareMetadata.Lookup_Fields__c.split(';'), ',') + ','
      : '';
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
    return 'SELECT Id,OwnerId,  ' +
      strLookupFields +
      String.escapeSingleQuotes(objShareMetadata.Territory_Field__c) +
      ' FROM ' +
      String.escapeSingleQuotes(objShareMetadata.Object_Name__c) +
      strWhereClause;
  }
}
