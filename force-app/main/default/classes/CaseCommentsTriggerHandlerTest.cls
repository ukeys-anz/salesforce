@isTest
public with sharing class CaseCommentsTriggerHandlerTest {
  @testSetup
  static void setup() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];
    UserRole bankerRole = [SELECT Id FROM UserRole WHERE Name = 'Banker'];
    UserRole leadershipRole = [
      SELECT Id
      FROM UserRole
      WHERE Name = 'Customer Resolution'
    ];
    User idrUser = (User) FakerFactory.make(new FakerUserFactory());
    idrUser.ProfileId = p.Id;
    idrUser.Business_Function__c = 'CMOS';
    idrUser.Business_Role__c = 'Customer Resolution';
    idrUser.FirstName = 'IDRL3';
    idrUser.IsActive = true;
    idrUser.UserRoleId = bankerRole.id;
    insert idrUser;

    List<String> idrPsets = new List<String>{ 'IDR_User', 'IDR_User_Level_1' };
    List<PermissionSet> idrPsetList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :idrPsets
    ];

    User usr = (User) FakerFactory.make(new FakerUserFactory());
    usr.ProfileId = p.Id;
    usr.Business_Function__c = 'CMOS';
    usr.Business_Role__c = 'Customer Resolution';
    usr.FirstName = 'IDRL1';
    usr.IsActive = true;
    usr.UserRoleId = leadershipRole.Id;
    insert usr;

    List<PermissionSetAssignment> idrPsaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : idrPsetList) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = usr.id,
        PermissionSetId = ps.Id
      );
      idrPsaList.add(psa);
    }
    insert idrPsaList;
  }
  @istest
  static void testCaseCommentsDelete() {
    Case c = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      Origin = 'Phone'
    );
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
      System.assert(
        false,
        'Failed to protect against user deleting case comments'
      );
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('You cannot delete case comments'),
        'Cases comments Cannot be deleted'
      );
    }
    try {
      newCaseComments.get(0).CommentBody = 'Updated Test';
      update newCaseComments;
      System.assert(
        false,
        'Failed to protect against user editing case comments'
      );
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('You cannot edit case comments'),
        'Cases comments cannot be edited'
      );
    }
  }

  @isTest
  static void testCaseCommentMasking() {
    Case c = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      Origin = 'Phone'
    );
    insert c;
    CaseComment[] newCaseComments = new List<CaseComment>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCaseComments.add(
        new CaseComment(
          CommentBody = 'Test comment 1234-5678-9101-7632-3321 check mask',
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
      'Test comment ****************3321 check mask',
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
    Case c = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      Origin = 'Phone'
    );
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
    System.assert(
      deletedComments.size() == 0,
      'Deleted comments size should be as expected.'
    );
  }

  @isTest
  static void testCaseCommentNotification() {
    User idrUser1 = [SELECT Id FROM user WHERE FirstName = 'IDRL3'];
    User idrUser2 = [SELECT Id FROM user WHERE FirstName = 'IDRL1'];

    //Given a compliant case record
    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRConstants.OPEN_STATUS,
          Description = 'Test decription',
          OwnerId = idrUser1.Id,
          IDR_Additional_Correspondence_reviewed__c = false,
          Origin = 'Phone'
        )
      );
    }
    insert newCases;

    // Sharing Case record manually to avoid deployment issues
    CaseShare cs = new CaseShare();
    cs.CaseId = newCases[0].id;
    cs.UserOrGroupId = idrUser2.Id;
    cs.CaseAccessLevel = 'Edit';
    insert cs;

    System.runAs(idrUser2) {
      Test.startTest();
      //When another user adds a case comment
      CaseComment testComment = new CaseComment(
        CommentBody = 'Test',
        ParentId = newCases[0].id
      );
      insert testComment;

      //THEN notification flag is set to true in the case record
      List<Application_Log__c> appLogs = [
        SELECT ID
        FROM Application_Log__c
        WHERE Process_Name__c = 'IDRBankerNotificationBuilder'
      ];
      System.assertEquals(
        0,
        appLogs.size(),
        'The application log size should be 0'
      );
      //when user updates the status to closed
      newCases[0].IDR_Additional_Correspondence_reviewed__c = true;
      newCases[0].Status = 'Closed';
      newCases[0].IDR_Description_of_Outcome__c = 'Test';
      newCases[0].IDR_Complaint_Outcome__c = '1';
      update newCases[0];
      //when user adds a new comment
      CaseComment testComments = new CaseComment(
        CommentBody = 'Test',
        ParentId = newCases[0].id
      );
      insert testComments;
      Test.stopTest();
    }
  }
}
