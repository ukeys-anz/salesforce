/**
 * @author Olivier Saier
 * @since 12/2020
 * @description Test class for {@link IDRCaseCommentActions}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private inherited sharing class IDRCaseCommentActionsTest {
  @TestSetup
  static void testSetup() {
    //Insert Cases with comments
    Case[] testCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      testCases.add(
        new Case(
          recordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890'
        )
      );
    }
    insert testCases;
    CaseComment[] testComments = new List<CaseComment>();
    for (Case c : testCases) {
      testComments.add(
        new CaseComment(commentBody = 'Comment to escalate', ParentId = c.Id)
      );
    }
    insert testComments;

    //Insert one non-complaint case and one escalated complaint
    testCases.clear();
    Case notAComplaint = new Case(
      recordTypeId = CaseCommonActions.GENERAL_INQUIRY_RT_ID
    );
    Case complaintEscalated = new Case(
      recordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
      IDR_Customer_Number__c = '1234567890',
      IDR_CFMS_Complaint_Number__c = 'COM-1234'
    );
    testCases.add(notAComplaint);
    testCases.add(complaintEscalated);
    insert testCases;
  }

  @isTest
  static void testNewCommentEscalation() {
    //GIVEN Cases, some being escalated complaints
    Case notAComplaint = [
      SELECT Id
      FROM Case
      WHERE recordTypeId != :IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID
      LIMIT 1
    ];
    Case complaintNotEscalated = [
      SELECT Id
      FROM Case
      WHERE
        recordTypeId = :IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID
        AND IDR_CFMS_Complaint_Number__c = ''
      LIMIT 1
    ];
    Case complaintEscalated = [
      SELECT Id
      FROM Case
      WHERE
        recordTypeId = :IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID
        AND IDR_CFMS_Complaint_Number__c = 'COM-1234'
      LIMIT 1
    ];

    //WHEN I comment on them
    CaseComment[] testComments = new List<CaseComment>();
    testComments.add(
      new CaseComment(
        commentBody = 'Comment NOT to escalate',
        ParentId = notAComplaint.Id
      )
    );
    testComments.add(
      new CaseComment(
        commentBody = 'Comment NOT to escalate',
        ParentId = complaintNotEscalated.Id
      )
    );
    for (Integer i = 0; i < 198; i++) {
      testComments.add(
        new CaseComment(
          commentBody = 'Comment to escalate',
          ParentId = complaintEscalated.Id
        )
      );
    }
    insert testComments;

    //THEN events of up to COMMENTS_PER_EVENT comments each are sent for comments on escalated cases
    System.assertEquals(
      Math.floor(198 / IDRCaseCommentActions.COMMENTS_PER_EVENT + 1),
      IDRCaseCommentActions.idrCaseCommentEscalationEvents.size(),
      'Only new comments on escalated cases should escalate.'
    );
  }

  @isTest
  static void testExistingCommentEscalation() {
    //GIVEN Cases with comments
    Case[] testCases = [
      SELECT IDR_CFMS_Complaint_Number__c
      FROM Case
      WHERE Id IN (SELECT parentId FROM CaseComment)
    ];

    //WHEN cases have been successfully escalated to CRP
    for (Case c : testCases) {
      c.IDR_CFMS_Complaint_Number__c = c.Id; //pseudo-random string
    }
    update testCases;

    //THEN case comments events are published (no comments on different cases in the same event and up to COMMENTS_PER_EVENT comments per event)
    System.assertEquals(
      testCases.size() *
      (Math.floor(
        Integer.valueOf(Label.Test_Bulk_Size) /
        IDRCaseCommentActions.COMMENTS_PER_EVENT + 1
      )),
      IDRCaseCommentActions.idrCaseCommentEscalationEvents.size(),
      'Exisitng comments on escalated cases should also escalate.'
    );

    //AND WHEN I retry
    IDRCaseCommentActions.idrCaseCommentEscalationEvents.clear();
    Set<Id> commentIds = (new Map<Id, CaseComment>(
        [SELECT Id FROM CaseComment]
      ))
      .keySet()
      .clone();
    IDRCaseCommentActions.retryCommentEscalation(commentIds);

    //THEN case comments events are republished
    System.assertEquals(
      testCases.size() *
      (Math.floor(
        Integer.valueOf(Label.Test_Bulk_Size) /
        IDRCaseCommentActions.COMMENTS_PER_EVENT + 1
      )),
      IDRCaseCommentActions.idrCaseCommentEscalationEvents.size(),
      'All exisitng comments on escalated cases should be republished.'
    );
  }
}
