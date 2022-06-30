/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description ReleaseLogServerController is the apex side controller for releaseLog LWC
 */
public with sharing class ReleaseLogServerController {
  /**
   * @description The Release Log component uses this to fetch the records to display.
   *
   * @param recordLimit the amount of records to retrieve
   * @return List<Release__c>
   */
  @AuraEnabled
  public static List<Release__c> getReleases(Integer recordLimit) {
    List<Release__c> releases;
    if (Release__c.sObjectType.getDescribe().isQueryable()) {
      releases = [
        SELECT
          Id,
          Name,
          Additions__c,
          Changes__c,
          Fixes__c,
          Release_Date__c,
          Release_Notes__c,
          Version__c,
          Release_Image__c
        FROM Release__c
        ORDER BY Release_Date__c DESC, Version__c DESC
        LIMIT :recordLimit
      ];
    }

    if (releases.isEmpty()) {
      return null;
    }

    return releases;
  }

  /**
   * @description The Release Log component uses this retrieve a total count of all records.
   * @return Interger
   */
  @AuraEnabled
  public static Integer countTotalRecords() {
    Integer count;
    if (Release__c.sObjectType.getDescribe().isQueryable()) {
      count = [SELECT COUNT() FROM Release__c WHERE Name != NULL];
    }

    return count;
  }
}
