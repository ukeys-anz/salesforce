/**
 * @author Afreen Khan
 * @since 07/2021
 * @description  Test Class to test CMOS Milestones features
 */
@IsTest
public class IDRMilestonesTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account a = new Account(
      Name = 'Complaint Entitlement Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = false
    );
    insert a;

    SlaProcess sla = [
      SELECT Id, Name
      FROM SlaProcess
      WHERE Name = 'complaints' AND IsActive = TRUE AND IsVersionDefault = TRUE
      LIMIT 1
    ];
    Entitlement et = new Entitlement(
      Name = 'Complaints Entitlement',
      AccountId = a.Id,
      StartDate = Date.valueOf(System.now().addDays(-2)),
      SlaProcessId = sla.Id
    );
    insert et;

    Product2 p = new Product2(
      Name = 'Test',
      IsActive = true,
      IDR_Product_or_Service_Line__c = '1',
      IDR_Product_or_Service_Category__c = '1',
      IDR_Product_or_Service_Type__c = '1'
    );
    insert p;
  }

  //Helper method created to avoid DML duplicate errors
  static List<Case> createCMOSCustomerComplaintCase() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
          IDR_Customer_Number__c = '1234567890',
          Priority = 'Standard',
          Type = '5',
          IDR_Subsequent_Issue__c = '38',
          Status = 'Open'
        )
      );
    }
    insert newCases;
    return newCases;
  }
  /*GIVEN a CMOS Case
  WHEN the case gets escalated or completed
  THEN the appropriate milestones are set to complete
  */
  @IsTest
  static void testIDRMilestoneCompletion() {
    Case[] newCases = createCMOSCustomerComplaintCase();

    List<Case> cList = [
      SELECT Id, EntitlementId
      FROM Case
      WHERE Id IN :newCases
    ];
    System.assert(
      cList[0].EntitlementId != null,
      'Entitlement Id should not be null.'
    );

    List<CaseMilestone> cmList = [
      SELECT Id
      FROM CaseMilestone
      WHERE CaseId IN :newCases
    ];
    System.assert(
      cmList.size() > 0,
      'The caseMilestone List should have members.'
    );

    newCases[0].Status = 'Escalated';
    newCases[0].IDR_Escalated_to__c = '1';
    newCases[0].IDR_Escalation_Reason__c = '1';
    CheckRecursive.firstCall = false;
    update newCases[0];

    List<CaseMilestone> cmList1 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId = :newCases[0].Id
        AND MilestoneType.Name = 'Open_Escalation_Time'
    ];
    System.assertEquals(
      true,
      cmList1[0].IsCompleted,
      'Escalation milestone should be closed'
    );

    newCases[1].Status = 'Closed';
    newCases[1].IDR_Complaint_Outcome__c = '1';
    newCases[1].IDR_Description_of_Outcome__c = 'test';
    CheckRecursive.firstCall = false;
    update newCases[1];

    List<CaseMilestone> cmList2 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE CaseId = :newCases[1].Id AND IsCompleted = TRUE
    ];
    System.assertEquals(
      2,
      cmList2.size(),
      'Both escalation and Max Timeframe milestone should be completed'
    );
  }
  /*GIVEN a CMOS Case
  WHEN the case gets created or its issue+sub issue types get updated
  THEN the 30-day milestones are appearing given the correct issue+sub issue types defined in https://jira.service.anz/browse/IDR-3464
  */
  @IsTest
  static void testIDR30DayMilestoneCreation() {
    Test.startTest();
    Case[] newCases = createCMOSCustomerComplaintCase();
    List<CaseMilestone> cmList1 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId IN :newCases
        AND MilestoneType.Name = '30-day IDR Response Due'
    ];

    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].Type = '4';
      newCases[i].IDR_Subsequent_Issue__c = '25';
      newCases[i].IDR_Second_Issue__c = true;
      newCases[i].IDR_Third_Issue__c = true;
      newCases[i].IDR_Issue_Type_2__c = '9';
      newCases[i].IDR_Subsequent_Issue_2__c = '57';
      newCases[i].IDR_Issue_Type_3__c = '15';
      newCases[i].IDR_Subsequent_Issue_3__c = '67';
      newCases[i].IDR_Product_2__c = p.Id;
      newCases[i].IDR_Product_3__c = p.Id;
      newCases[i].IDR_Account_Card_Policy_Number_2__c = '1234567890';
      newCases[i].IDR_Account_Card_Policy_Number_3__c = '1234567890';
    }
    update newCases;

    List<CaseMilestone> cmList2 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId IN :newCases
        AND MilestoneType.Name = '30-day IDR Response Due'
    ];
    Test.stopTest();
    System.assertEquals(
      false,
      cmList1.isEmpty(),
      'Case should have 30 Day Milestone'
    );
    System.assertEquals(
      false,
      cmList2.isEmpty(),
      'Case should still have 30 Day Milestone'
    );
  }
  /*GIVEN a CMOS Case
  WHEN the case gets created or its issue+sub issue types get updated
  THEN the 21-day milestones are appearing given the correct issue+sub issue types defined in https://jira.service.anz/browse/IDR-3464
  */
  @IsTest
  static void testIDR21DayMilestoneCreation() {
    Test.startTest();
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
          IDR_Customer_Number__c = '1234567890',
          Priority = 'Standard',
          Type = '4',
          IDR_Subsequent_Issue__c = '96',
          Status = 'Open'
        )
      );
    }
    insert newCases;

    List<CaseMilestone> cmList1 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId IN :newCases
        AND MilestoneType.Name = '21-day IDR Response Due'
    ];

    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].IDR_Second_Issue__c = true;
      newCases[i].IDR_Third_Issue__c = true;
      newCases[i].IDR_Issue_Type_2__c = '4';
      newCases[i].IDR_Subsequent_Issue_2__c = '23';
      newCases[i].IDR_Issue_Type_3__c = '17';
      newCases[i].IDR_Subsequent_Issue_3__c = '97';
      newCases[i].IDR_Product_2__c = p.Id;
      newCases[i].IDR_Product_3__c = p.Id;
      newCases[i].IDR_Account_Card_Policy_Number_2__c = '1234567890';
      newCases[i].IDR_Account_Card_Policy_Number_3__c = '1234567890';
    }
    update newCases;

    List<CaseMilestone> cmList2 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId IN :newCases
        AND MilestoneType.Name = '21-day IDR Response Due'
    ];
    Test.stopTest();

    System.assertEquals(
      false,
      cmList1.isEmpty(),
      'Case should have 21 Day Milestone'
    );
    System.assertEquals(
      false,
      cmList2.isEmpty(),
      'Case should still have 21 Day Milestone'
    );
  }
  /*GIVEN a CMOS Case
  WHEN the cases' issue+sub issue types get updated
  THEN the correct are appearing given the correct issue+sub issue types defined in https://jira.service.anz/browse/IDR-3464
  */
  @IsTest
  static void testIDR21and30DayMilestoneChange() {
    Case[] newCases = createCMOSCustomerComplaintCase();

    Product2 p = [SELECT Id FROM Product2 LIMIT 1];

    Test.startTest();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].Type = '4';
      newCases[i].IDR_Subsequent_Issue__c = '96';
      newCases[i].IDR_Second_Issue__c = true;
      newCases[i].IDR_Third_Issue__c = true;
      newCases[i].IDR_Issue_Type_2__c = '9';
      newCases[i].IDR_Subsequent_Issue_2__c = '57';
      newCases[i].IDR_Issue_Type_3__c = '17';
      newCases[i].IDR_Subsequent_Issue_3__c = '28';
      newCases[i].IDR_Product_2__c = p.Id;
      newCases[i].IDR_Product_3__c = p.Id;
      newCases[i].IDR_Account_Card_Policy_Number_2__c = '1234567890';
      newCases[i].IDR_Account_Card_Policy_Number_3__c = '1234567890';
    }
    update newCases;

    List<CaseMilestone> cmList1 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId IN :newCases
        AND MilestoneType.Name = '21-day IDR Response Due'
    ];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].Type = '4';
      newCases[i].IDR_Subsequent_Issue__c = '25';
      newCases[i].IDR_Issue_Type_2__c = '9';
      newCases[i].IDR_Subsequent_Issue_2__c = '57';
      newCases[i].IDR_Issue_Type_3__c = '15';
      newCases[i].IDR_Subsequent_Issue_3__c = '67';
    }
    update newCases;

    List<CaseMilestone> cmList2 = [
      SELECT Id, IsCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId IN :newCases
        AND MilestoneType.Name = '30-day IDR Response Due'
    ];

    Test.stopTest();

    System.assertEquals(
      false,
      cmList1.isEmpty(),
      'Case should have updated to 21 Day Milestone'
    );
    System.assertEquals(
      false,
      cmList2.isEmpty(),
      'Case should have updated to 30 Day Milestone'
    );
  }
}
