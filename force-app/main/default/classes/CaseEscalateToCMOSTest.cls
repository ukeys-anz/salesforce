/**
 * @author Mouhamed "Mo" Assafiri
 * @since Sept 2021
 * @description Tests for Case Escalation
 */

@isTest
public class CaseEscalateToCMOSTest {
  @testSetup
  static void setup() {
    List<RecordType> rtList = new List<RecordType>(
      [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Case' AND DeveloperName = 'ANZx_Complaint'
      ]
    );
    Case newCase = new Case(
      Subject = 'Test',
      Status = 'Open',
      Origin = 'Phone',
      RecordTypeId = rtList[0].Id
    );
    insert newCase;

    //Add Chatter Posts to test Chatter -> Case Comments duplication
    List<FeedItem> posts = new List<FeedItem>{
      new FeedItem(ParentID = newCase.id, Body = 'Test Post'),
      new FeedItem(ParentID = newCase.id, Body = 'Test Post 2')
    };

    insert posts;
  }

  /**
   * @description testCaseEscalatetoCMOS to see if ANZx to
   * CMOS Escalation converts Chatter to CaseComments correctly
   */
  @isTest
  public static void testCaseEscalatetoCMOSChatterToComments() {
    List<Case> newCase = [
      SELECT
        Id,
        Customer_Notification_Consent__c,
        AccountID,
        Account.Source_System_ID__c
      FROM Case
    ];

    Test.startTest();
    List<CaseComment> comments = CaseEscalateToCMOS.prepareChatterToCaseComments(
      newCase
    );
    Boolean published = CaseEscalateToCMOS.publishChatterToCaseComments(
      comments
    );
    Test.stopTest();

    system.assert(
      (comments.size() == 2),
      'Expected PrepareChatterToCaseComments list size to be 2'
    );

    system.assert(
      published,
      'Bulk publish chatter to Case Comment Failed at insert'
    );

    List<CaseComment> caseComments = [
      SELECT Id, CommentBody, IsPublished, ParentId
      FROM CaseComment
      WHERE ParentId = :newCase[0].Id
    ];

    system.assert(
      caseComments.size() == 2,
      'ANZx to CMOS Escalation - Chatter did not convert to Case Comments correctly'
    );
  }

  /**
   * @description testCaseEscalatetoCMOS to see if ANZx to CMOS Escalates correctly
   */
  @isTest
  public static void testCaseEscalatetoANZxToCMOS() {
    Case newCase = [
      SELECT Id, Customer_Notification_Consent__c, Account.Source_System_ID__c
      FROM Case
      LIMIT 1
    ];
    CaseEscalateToCMOS.manualEscalateCaseToCMOS(newCase);

    newCase = [
      SELECT
        Id,
        OwnerId,
        IDR_Escalation_Reason__c,
        Customer_Notification_Consent__c,
        Status,
        RecordTypeId,
        IDR_Customer_Notification__c
      FROM Case
      LIMIT 1
    ];

    system.assert(
      newCase.RecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      'Case type did not change to CMOS Complaint correctly'
    );
    system.assert(
      newCase.IDR_Escalation_Reason__c ==
      CaseEscalateToCMOS.MANUAL_ESCALATION_REASON,
      'Did not set Escalation Reason Correctly'
    );
  }
  /**
   * @description testAutoEscalatetoANZxToCMOS to see if ANZx to CMOS Escalates correctly when 5 days milestone breaches.
   */
  @isTest
  public static void testAutoEscalatetoANZxToCMOS() {
    //GIVEN
    //An ANZx Complaint Case
    Case newCase = [
      SELECT Id, Customer_Notification_Consent__c, Account.Source_System_ID__c
      FROM Case
      LIMIT 1
    ];

    //WHEN
    //SLA Status breaches
    Test.startTest();
    newCase.SLA_Status__C = 'Breached';
    update newCase;
    Test.stopTest();

    //THEN
    //Check if the case is (1)automatically escalated and (2)assigned to the right case owner & queue
    newCase = [
      SELECT Id, OwnerId, IDR_Escalation_Reason__c, Status, RecordTypeId
      FROM Case
      LIMIT 1
    ];

    System.assert(
      newCase.RecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      'Case type did not change to CMOS Complaint correctly'
    );
    System.assert(
      newCase.IDR_Escalation_Reason__c ==
      CaseEscalateToCMOS.DAY_5_ESCALATION_REASON,
      'Escalation Reason was not set correctly'
    );
  }
}
