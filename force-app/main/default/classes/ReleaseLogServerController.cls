public with sharing class ReleaseLogServerController {
  @AuraEnabled
  public static List<Release__c> getReleases() {
    List<Release__c> releases;
    if (Release__c.sObjectType.getDescribe().isQueryable()) {
      releases = [
        SELECT Id, Name, Additions__c, Changes__c, Fixes__c, Release_Date__c, Release_Notes__c, Version__c
        FROM Release__c
        ORDER BY Release_Date__c DESC
      ];
    }

    if (releases.isEmpty()) {
      return null;
    }

    return releases;
  }
}
