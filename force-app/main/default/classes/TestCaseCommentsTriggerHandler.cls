@isTest
public with sharing class TestCaseCommentsTriggerHandler {
  @testSetup
  static void setup() {
    List<Case> newCases = new List<Case>();

    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRConstants.OPEN_STATUS,
          Description = 'Test decription'
        )
      );
    }
    insert newCases;

    User usr = (User) FakerFactory.make(new FakerUserFactory());
    usr.ProfileId = p.Id;
    usr.Business_Function__c = 'CMOS';
    usr.Business_Role__c = 'Customer Resolution';
    insert usr;
  }

  @istest
  static void testCaseCommentsDelete() {
    Case c = [SELECT Id FROM Case LIMIT 1];
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
    Case c = [SELECT Id FROM Case LIMIT 1];
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
      'Test comment ********9101 check mask',
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
    Case c = [SELECT Id FROM Case LIMIT 1];
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

  @isTest
  static void testCaseCommentNotification() {
    List<User> usrlist = [SELECT id FROM User];

    System.runAs(usrlist[0]) {
      //Given a complaint case record
      Case caseRecord = [SELECT Id FROM Case LIMIT 1];

      Test.startTest();
      //When another user adds a case comment
      CaseComment testComment = new CaseComment(
        CommentBody = 'Test',
        ParentId = caseRecord.id
      );
      insert testComment;
      Test.stopTest();

      List<Case> caseList = [
        SELECT Id, IDR_Update_Notification_Flag__c
        FROM Case
      ];
      //THEN notification flag is set to true in the case record
      System.assertEquals(true, caseList[0].IDR_Update_Notification_Flag__c);
    }
  }
}
