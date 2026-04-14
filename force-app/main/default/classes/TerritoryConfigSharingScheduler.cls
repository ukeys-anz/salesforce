/**
 * @author Ashish Kumar
 * @since  07/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritoryConfigSharingScheduler is schedular class to schedule batch class for sharing sobject record when any update happens to territory or user territory records.
 * @runTests TerritoryConfigSharingBatchTest
 */
global class TerritoryConfigSharingScheduler implements Schedulable {
  private static final TerritoryConfigSharingRepository CONFIG_SHARING_REPO = (TerritoryConfigSharingRepository) Lib_InstanceProvider.forType(
    TerritoryConfigSharingRepository.class
  );

  /**
   * @description This method is used for sharing sobject record when any update happens to territory or user territory records.
   * @name execute
   * @param objSchedule standard SchedulableContext variable
   * @author Ashish Kumar
   * @US CC-4493
   */
  global void execute(SchedulableContext objSchedule) {
    List<Territory_Based_Sharing_Config__mdt> lstOfAllTerritoryMtd = Territory_Based_Sharing_Config__mdt.getAll()
      .values();
    List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMtd = ListUtil.filter(
        lstOfAllTerritoryMtd
      )
      .equals(Territory_Based_Sharing_Config__mdt.Active__c, true)
      .toList();
    DateTime objDateTime = getRecalcStartTime();
    List<User_Territory__c> lstOfUserTerritories = getUserTerritoriesToRecalc(
      objDateTime
    );

    Set<Id> idsOfTerritories = ListUtil.getIds(
      lstOfUserTerritories,
      User_Territory__c.Territory__c
    );
    if (idsOfTerritories.isEmpty()) {
      return;
    }

    // submit territory recalc batch for each Sobject in Mtd
    for (
      Territory_Based_Sharing_Config__mdt objTerritoryMtd : lstOfTerritoryMtd
    ) {
      TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch(
        objTerritoryMtd,
        idsOfTerritories
      );
      processBatch(objBatch);
    }
  }

  /**
   * @description This method is used to calculate sharing recalculation time
   * @name getRecalcStartTime
   * @return DateTime recalculation time
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private DateTime getRecalcStartTime() {
    Territory_Based_Sharing_Config__mdt objUTRecalculationtime = CONFIG_SHARING_REPO.getTerritoryRecalculationTimeFrame();
    DateTime objDateTime;
    if (objUTRecalculationtime?.Recalculation_Timeframe__c == null) {
      return null;
    }
    objDateTime = System.Now()
      .addHours(
        -1 * Integer.valueOf(objUTRecalculationtime.Recalculation_Timeframe__c)
      );

    return objDateTime;
  }

  /**
   * @description This method is used to get user territories record to be recalculated
   * @name getUserTerritoriesToRecalc
   * @param objDateTime
   * @return List<User_Territory__c> list of modified user territories records
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private List<User_Territory__c> getUserTerritoriesToRecalc(
    DateTime objDateTime
  ) {
    String statusActive = 'Active';
    String strUserTerritoryQuery = '';
    List<Territory__c> lstOfTerritories = CONFIG_SHARING_REPO.getListOfTerritories(
      objDateTime
    );
    if (!lstOfTerritories.isEmpty()) {
      strUserTerritoryQuery = 'SELECT ML_Role__c,Status__c,User__c,Territory__c FROM User_Territory__c WHERE (Territory__c IN: lstOfTerritories OR lastModifiedDate >= :objDateTime)';
    } else {
      strUserTerritoryQuery = 'SELECT ML_Role__c,Status__c,User__c,Territory__c FROM User_Territory__c WHERE lastModifiedDate >= :objDateTime';
    }
    return CONFIG_SHARING_REPO.getUserTerritoriesToRecalc(
      strUserTerritoryQuery,
      lstOfTerritories,
      objDateTime,
      statusActive
    );
  }

  /**
   * @description This method is used to get user territories record ids
   * @name processBatch
   * @param objBatch batch class object
   * @author Ashish Kumar
   * @US CC-4493
   */
  @TestVisible
  private static void processBatch(TerritoryConfigSharingBatch objBatch) {
    Database.executeBatch(objBatch);
  }
}
