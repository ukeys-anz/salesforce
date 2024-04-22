/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRM_TerritorySharingScheduler is schedular class to schedule batch class for sharing sobject record created by excluded users.
 * @runTests MLCRM_TerritoryRecalculationBatchTest
 */
global class MLCRM_TerritorySharingScheduler implements Schedulable {
  /**
   * @description This method is used to schedule batch class for sharing sobject record created by excluded users.
   * @name execute
   * @param objSchedule standard SchedulableContext variable
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void execute(SchedulableContext objSchedule) {
    String strQuery;
    List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMtd = Territory_Based_Sharing_Config__mdt.getAll()
      .Values();
    if (!lstOfTerritoryMtd.isEmpty()) {
      for (
        Territory_Based_Sharing_Config__mdt objTerritoryMtd : lstOfTerritoryMtd
      ) {
        if (
          objTerritoryMtd.Active__c && objTerritoryMtd.Excluded_Users__c != null
        ) {
          MLCRM_TerritorySharingRecalculationBatch objBatch = new MLCRM_TerritorySharingRecalculationBatch(
            objTerritoryMtd
          );
          Database.executeBatch(objBatch);
        }
      }
    }
  }
}
