@isTest
public with sharing class TestCaseCommentsTriggerHandler {
  @istest
  static void testCaseCommentsDelete() {
    Case c = new Case();
    insert c;
    CaseComment[] newCaseComments = new List<CaseComment>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCaseComments.add(
        new CaseComment(CommentBody = 'Test', ParentId = c.id)
      );
    }
    insert newCaseComments;

    try {
      delete newCaseComments;
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('You cannot delete case comments'),
        'Cases comments Cannot be deleted'
      );
    }
    try {
      newCaseComments.get(0).CommentBody = 'Updated Test';
      update newCaseComments;
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('You cannot edit case comments'),
        'Cases comments cannot be edited'
      );
    }
  }

  @isTest
  static void testCaseCommentMasking() {
    Case c = new Case();
    insert c;
    CaseComment[] newCaseComments = new List<CaseComment>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCaseComments.add(
        new CaseComment(
          CommentBody = 'Test comment 1234-5678-9101 check mask',
          ParentId = c.id
        )
      );
    }
    insert newCaseComments;

    CaseComment[] maskedComments = [
      SELECT CommentBody
      FROM CaseComment
      WHERE ParentId = :c.id
    ];

    System.assertEquals(
      'Test comment ******9101 check mask',
      maskedComments[0].CommentBody,
      'Comment should be masked.'
    );
  }

  @isTest
  static void testWithByPassTriggerSettings() {
    //Give user is has custom settings
    Salesforce_Bypass_Trigger_Actions__c setting = new Salesforce_Bypass_Trigger_Actions__c();
    setting.Object_API_Name__c = 'CaseComment';
    setting.Bypass_Delete__c = true;
    insert setting;
    Case c = new Case();
    insert c;
    CaseComment[] newCaseComments = new List<CaseComment>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCaseComments.add(
        new CaseComment(CommentBody = 'Test', ParentId = c.id)
      );
    }
    insert newCaseComments;

    //when the user tries to delete
    delete newCaseComments;

    //then delete is possible
    CaseComment[] deletedComments = [
      SELECT CommentBody
      FROM CaseComment
      WHERE ParentId = :c.id
    ];
    System.assert(deletedComments.size() == 0);
  }
}
