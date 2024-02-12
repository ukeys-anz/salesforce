/**
 * @author Hrushikesh Pathak
 * @since 11/2023
 * @description  Test Class for the BOHLeadAutoClosureBatch created to auto close BOH Lead
 */
@isTest
public with sharing class BOHLeadAutoClosureBatchTest {
  @TestSetup
  static void setup() {
    List<Lead> leadRecords = new List<Lead>();
    for (Integer i = 0; i < 200; i++) {
      if (i < 100) {
        Lead record = new Lead();
        record.Firstname = 'Test' + i;
        record.Lastname = 'Lead' + i;
        record.Email = 'testlead12' + i + '@mail.com';
        record.MobilePhone = '04012212344' + i;
        record.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;
        record.LeadSource = 'Masterclass';
        record.OpportunityType__c = 'Other';
        leadRecords.add(record);
      } else {
        Lead record = new Lead();
        record.Firstname = 'Test' + i;
        record.Lastname = 'Lead' + i;
        record.Email = 'testlead78' + i + '@mail.com';
        record.MobilePhone = '04014512344' + i;
        record.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;
        record.LeadSource = 'Referral from ANZ';
        record.OpportunityType__c = 'Financial Well Being';
        leadRecords.add(record);
      }
    }
    insert leadRecords;

    for (Lead record : leadRecords) {
      // Setting the created date of six days back
      Test.setCreatedDate(record.Id, DateTime.now().addDays(-6));
    }
  }

  // Method to check if BOH Lead are getting auto closed.
  @isTest
  public static void testAutoClosureOfLead() {
    Test.startTest();
    List<Lead> records = [
      SELECT
        Id,
        FirstName,
        LastName,
        Is_BOH_Lead__c,
        Email,
        MobilePhone,
        Status,
        LeadSource,
        OpportunityType__c,
        SubStatus__c,
        CreatedDate
      FROM Lead
    ];
    Database.executeBatch(new BOHLeadAutoClosureBatch());
    Test.stopTest();
    List<Lead> testRecords = [
      SELECT Id, SubStatus__c, Status
      FROM Lead
      WHERE
        Status = :BOHConstants.BOH_CLOSED_STATUS
        AND SubStatus__c = :BOHConstants.BOH_AUTO_CLOSED_SUB_STATUS
    ];

    Assert.areEqual(100, testRecords.size(), 'Incorrect Count of records');
  }

  // Method to check BOH Lead should not be auto closed.
  @isTest
  public static void testNotAutoClosureOfLead() {
    Test.startTest();
    List<Lead> records = [
      SELECT
        Id,
        FirstName,
        LastName,
        Is_BOH_Lead__c,
        Email,
        MobilePhone,
        Status,
        LeadSource,
        OpportunityType__c,
        SubStatus__c,
        CreatedDate
      FROM Lead
    ];
    Database.executeBatch(new BOHLeadAutoClosureBatch());
    Test.stopTest();
    List<Lead> testRecords = [
      SELECT Id, SubStatus__c, Status
      FROM Lead
      WHERE Status = :BOHConstants.BOH_NEW_STATUS
    ];

    Assert.areEqual(100, testRecords.size(), 'Incorrect Count of records');
  }
}
