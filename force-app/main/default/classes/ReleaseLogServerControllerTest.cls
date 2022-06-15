@isTest
public with sharing class ReleaseLogServerControllerTest {
  @isTest
  public static void testReleaseLogRetrieval() {
    Release__c newRelease = new Release__c();
    newRelease.Name = 'Release Test';
    newRelease.Version__c = 1.0;
    newRelease.Release_Date__c = Date.Today();
    insert newRelease;

    List<Release__c> releaseList = ReleaseLogServerController.getReleases(1);

    System.assertEquals(
      1,
      releaseList.size(),
      'Release list size should be as expected.'
    );
  }

  @isTest
  public static void testReleaseCount() {
    Release__c newRelease = new Release__c();
    newRelease.Name = 'Release Test';
    newRelease.Version__c = 1.0;
    newRelease.Release_Date__c = Date.Today();
    insert newRelease;

    Integer releaseCount = ReleaseLogServerController.countTotalRecords();

    System.assertEquals(
      1,
      releaseCount,
      'Release list size should be as expected.'
    );
  }
}
