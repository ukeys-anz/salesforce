/**
 * @author Aidan Majewski
 * @since 2020
 * @description Test class for {@link TH_Assignments}
 * @group Trailhead
 */
@isTest
public class TH_AssignmentsTest {
  @testSetup
  static void setup() {
    //Create Test Data
    trailheadapp__Trailmix__c mix = new trailheadapp__Trailmix__c();
    mix.name = 'Test Mix';
    mix.trailheadapp__URL__c = 'https://trailhead.salesforce.com/';
    mix.trailheadapp__Slug__c = 'Test-Mix';
    mix.trailheadapp__External_Id__c = '000001111';
    mix.trailheadapp__Created_By_Profile__c = 'https://trailhead.salesforce.com/';
    mix.trailheadapp__Creator_TH_SFID__c = 'SomeText';
    insert (mix);
    trailheadapp__Badge__c badge = new trailheadapp__Badge__c();
    badge.name = 'Test Badge';
    badge.trailheadapp__Description__c = 'test';
    badge.trailheadapp__URL__c = 'https://trailhead.salesforce.com/';
    badge.trailheadapp__Icon__c = 'https://trailhead.salesforce.com/';
    badge.trailheadapp__API_Name__c = '000001112';
    badge.trailheadapp__Namespace__c = 'namespace';
    insert (badge);
    trailheadapp__User_Trailmix__c uMix = new trailheadapp__User_Trailmix__c();
    uMix.trailheadapp__Trailmix__c = mix.Id;
    uMix.trailheadapp__User__c = UserInfo.getUserId();
    uMix.trailheadapp__Due_At__c = DateTime.Now();
    insert (uMix);
    trailheadapp__User_Badge__c uBadge = new trailheadapp__User_Badge__c();
    uBadge.trailheadapp__Badge__c = badge.Id;
    uBadge.trailheadapp__User__c = UserInfo.getUserId();
    uBadge.trailheadapp__Status__c = 'Assigned';
    uBadge.trailheadapp__Due_Date__c = DateTime.now().AddDays(1);
    insert (uBadge);
  }

  @isTest
  static void testBothEntries() {
    Test.startTest();
    TH_Assignments.TrailheadEntry[] entries = TH_Assignments.getAllAssignedTrailEntries(
      Label.th_TrailheadTypeBoth
    );
    Test.stopTest();
    System.assertEquals(
      2,
      entries.size(),
      'Badge or mix assignment not returned'
    );
  }

  @isTest
  static void testSingleEntries() {
    Test.startTest();
    TH_Assignments.TrailheadEntry[] badgeEntries = TH_Assignments.getAllAssignedTrailEntries(
      Label.th_TrailheadTypeBadge
    );
    TH_Assignments.TrailheadEntry[] mixEntries = TH_Assignments.getAllAssignedTrailEntries(
      Label.th_TrailheadTypeTrailmix
    );
    Test.stopTest();
    System.assertEquals(
      1,
      badgeEntries.size(),
      'Badge assignment not returned'
    );
    System.assertEquals(1, mixEntries.size(), 'Mix assignment not returned');
  }
}
