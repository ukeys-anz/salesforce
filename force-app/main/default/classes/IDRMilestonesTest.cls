@isTest
public class IDRMilestonesTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    User thisUser = new User(Id = UserInfo.getUserId());

    Account a = new Account(
      Name = 'Complaint Entitlement Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = false
    );
    insert a;

    Slaprocess sla = [
      SELECT Id, NAME
      FROM Slaprocess
      WHERE Name = 'complaints'
      LIMIT 1
    ];
    Entitlement et = new Entitlement(
      Name = 'Complaints Entitlement',
      AccountId = a.Id,
      StartDate = Date.valueof(System.now().addDays(-2)),
      SlaProcessId = sla.Id
    );
    insert et;
  }

  @isTest
  static void testIDRMilestoneCompletion() {
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

    List<Case> cList = [
      SELECT Id, EntitlementId
      FROM Case
      WHERE Id IN :newCases
    ];
    System.assert(cList[0].EntitlementId != null);

    List<CaseMilestone> cmList = [
      SELECT Id
      FROM CaseMilestone
      WHERE CaseId IN :newCases
    ];
    System.assert(cmList.size() > 0);

    newCases[0].Status = 'Escalated';
    newCases[0].IDR_Escalated_to__c = '1';
    newCases[0].IDR_Escalation_Reason__c = '1';
    CheckRecursive.firstCall = false;
    update newCases[0];

    List<CaseMilestone> cmList1 = [
      SELECT Id, isCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE
        CaseId = :newCases[0].id
        AND MilestoneType.Name = 'Open_Escalation_Time'
    ];
    System.assertEquals(
      true,
      cmList1[0].isCompleted,
      'Escalation milestone should be closed'
    );

    newCases[1].Status = 'Closed';
    newCases[1].IDR_Complaint_Outcome__c = '1';
    newCases[1].IDR_Description_of_Outcome__c = 'test';
    CheckRecursive.firstCall = false;
    update newCases[1];

    List<CaseMilestone> cmList2 = [
      SELECT Id, isCompleted, MilestoneType.Name
      FROM CaseMilestone
      WHERE CaseId = :newCases[1].id AND isCompleted = TRUE
    ];
    System.assertEquals(
      2,
      cmList2.size(),
      'Both escalation and Max Timeframe milestone should be completed'
    );
  }
}
