/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRM_TerritoryConfigSharingScheduler is schedular class to schedule batch class for sharing sobject record when any update happens to territory or user territory records.
 * @runTests MLCRM_TerritoryConfigSharingBatchTest
 */
global class MLCRM_TerritoryConfigSharingScheduler implements Schedulable {
  /**
   * @description This method is used for sharing sobject record when any update happens to territory or user territory records.
   * @name execute
   * @param objSchedule standard SchedulableContext variable
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void execute(SchedulableContext objSchedule) {
    Territory_Based_Sharing_Config__mdt objUTRecalculationtime = Territory_Based_Sharing_Config__mdt.getInstance(
      'Territory_Recalculation_TImeFrame'
    );
    DateTime objDateTime;
    if (
      objUTRecalculationtime != null &&
      objUTRecalculationtime.Recalculation_Timeframe__c != null
    ) {
      objDateTime = System.Now()
        .addHours(
          -1 *
          Integer.valueOf(objUTRecalculationtime.Recalculation_Timeframe__c)
        );
    } else {
      return;
    }
    Set<Id> idsOfTerritory = new Set<Id>();
    String strTerritoryQuery;
    String strStatus = MLCRMConstants.STATUS_ACTIVE;
    List<Territory__c> lstOfTerritory = [
      SELECT Id, Access_Scope__c
      FROM Territory__c
      WHERE lastModifiedDate >= :objDateTime
    ];
    if (!lstOfTerritory.isEmpty()) {
      strTerritoryQuery = 'SELECT ML_Role__c,Status__c,User__c,Territory__c FROM User_Territory__c WHERE (Territory__c IN: lstOfTerritory OR lastModifiedDate >= :objDateTime) AND Status__c = :strStatus';
    } else {
      strTerritoryQuery = 'SELECT ML_Role__c,Status__c,User__c,Territory__c FROM User_Territory__c WHERE lastModifiedDate >= :objDateTime AND Status__c = :strStatus';
    }
    List<User_Territory__c> lstOfUserTerritory = Database.query(
      strTerritoryQuery
    );
    if (!lstOfUserTerritory.isEmpty()) {
      for (User_Territory__c objUT : lstOfUserTerritory) {
        idsOfTerritory.add(objUT.Territory__c);
      }
    }

    if (!idsOfTerritory.isEmpty()) {
      List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMtd = Territory_Based_Sharing_Config__mdt.getAll()
        .Values();
      if (!lstOfTerritoryMtd.isEmpty()) {
        for (
          Territory_Based_Sharing_Config__mdt objTerritoryMtd : lstOfTerritoryMtd
        ) {
          if (objTerritoryMtd.Active__c) {
            MLCRM_TerritoryConfigSharingBatch objBatch = new MLCRM_TerritoryConfigSharingBatch(
              objTerritoryMtd,
              idsOfTerritory
            );
            Database.executeBatch(objBatch);
          }
        }
      }
    }
  }
}
