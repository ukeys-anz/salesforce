/**
 * @author Peter Charalambous
 * @since 11/2020
 * @description MilestoneUtilsTest is the test class to cover tests for {@link MilestoneUtils}
 * The code is based on https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
 * @group Utils
 */
@isTest
private class MilestoneUtilsTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account[] accnts = new List<Account>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      accnts.add(
        new Account(
          Name = 'TestAccount',
          Display_Name__c = 'TestAccount',
          OCV_ID__c = faker.randomString(10),
          ANZx_Customer__c = true
        )
      );
    }
    insert accnts;

    List<Case> caseList = new List<Case>();

    for (Account acc : accnts) {
      caseList.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id,
          Status = 'Open'
        )
      );
    }
    insert caseList;
  }

  @isTest
  static void completeMilestoneTest() {
    List<Account> accIdList = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    List<Case> caseList = [SELECT Id FROM Case WHERE AccountId IN :accIdList];

    List<Id> caseIdList = new List<Id>();

    for (Case c : caseList) {
      caseIdList.add(c.Id);
    }

    MilestoneUtils.completeMilestone(
      caseIdList,
      'Resolution Time',
      System.now()
    );

    List<CaseMilestone> cmList = [
      SELECT Id, IsCompleted
      FROM CaseMilestone cm
      WHERE caseId IN :caseIdList AND cm.MilestoneType.Name = 'Resolution Time'
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      cmList.size(),
      'CaseMilestone list size should be as expected.'
    );
  }

  @isTest
  static void completeMilestoneFlowTest() {
    List<Account> accIdList = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    List<Case> caseList = [
      SELECT Id, Status
      FROM Case
      WHERE AccountId IN :accIdList
    ];

    List<Id> caseIdList = new List<Id>();

    for (Case c : caseList) {
      c.Status = 'Closed';
      caseIdList.add(c.Id);
    }
    update caseList;

    List<CaseMilestone> cmList = [
      SELECT Id, IsCompleted
      FROM CaseMilestone cm
      WHERE caseId IN :caseIdList AND cm.MilestoneType.Name = 'Resolution Time'
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      cmList.size(),
      'CaseMilestone list size should be as expected.'
    );
  }
}
