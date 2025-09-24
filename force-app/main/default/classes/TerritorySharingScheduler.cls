/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritorySharingScheduler is schedular class to schedule batch class for sharing sobject record created by excluded users.
 * @runTests TerritoryRecalculationBatchTest
 */
global class TerritorySharingScheduler implements Schedulable {
  private static final TerritoryConfigSharingRepository CONFIG_SHARING_REPO = (TerritoryConfigSharingRepository) Lib_InstanceProvider.forType(
    TerritoryConfigSharingRepository.class
  );
  /**
   * @description This method is used to schedule batch class for sharing sobject record created by excluded users.
   * @name execute
   * @param objSchedule standard SchedulableContext variable
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void execute(SchedulableContext objSchedule) {
    List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMtd = CONFIG_SHARING_REPO.getActiveTerritoryMetadata();
    if (lstOfTerritoryMtd.isEmpty()) {
      return;
    }
    for (
      Territory_Based_Sharing_Config__mdt objTerritoryMtd : getValidTerritoryMetadata(
        lstOfTerritoryMtd
      )
    ) {
      TerritorySharingRecalculationBatch objBatch = new TerritorySharingRecalculationBatch(
        objTerritoryMtd
      );
      Database.executeBatch(objBatch);
    }
  }

  /**
   * @description This method is used to get user territories record ids
   * @name getActiveTerritoryMetadata
   * @param lstOfTerritoryMtd list of territory config metadata records
   * @return List<Territory_Based_Sharing_Config__mdt> list of active metadata records
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private static List<Territory_Based_Sharing_Config__mdt> getValidTerritoryMetadata(
    List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMtd
  ) {
    return ListUtil.filter(lstOfTerritoryMtd)
      .notEquals(Territory_Based_Sharing_Config__mdt.Excluded_Users__c, null)
      .equals(Territory_Based_Sharing_Config__mdt.Active__c, true)
      .toList();
  }
}
