@isTest
public with sharing class CaseCommentsTriggerHandlerTest {
  @istest
  static void testCaseCommentsDelete() {
    Case c = new Case(
      RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID
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
    Case c = new Case(
      RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID
    );
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
    Case c = new Case(
      RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID
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
    System.assert(deletedComments.size() == 0);
  }

  @istest
  static void testCaseCommentsInsertFraudXUser() {
    // Setting up test data
    User fraudXAgent;
    Case generalEnquiryCase;

    // Insert Account, Case, & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      // Create an ANZx Customer
      Faker faker = new Faker('AU');
      Account acc = new Account(
        Name = 'Test 007 Account',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = true
      );
      insert acc;

      // Create a Case record to have a record type other than Fraud
      Id generalEnquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('General_Inquiry')
        .getRecordTypeId();
      generalEnquiryCase = new Case(
        RecordTypeId = generalEnquiryRecordTypeID,
        AccountId = acc.Id
      );
      insert generalEnquiryCase;

      // Create a FraudX User with 'FraudX Agent' role
      Profile profile = [
        SELECT Id
        FROM Profile
        WHERE Name = 'ANZx Standard User'
        LIMIT 1
      ];
      UserRole role = [
        SELECT Id
        FROM UserRole
        WHERE DeveloperName = 'FraudX_Agent'
      ];

      fraudXAgent = (User) FakerFactory.make(new FakerUserFactory());
      fraudXAgent.FirstName = 'FraudX';
      fraudXAgent.ProfileId = profile.Id;
      fraudXAgent.UserRoleId = role.Id;
      insert fraudXAgent;

      // Assign Case related PS
      PermissionSet ps = [
        SELECT Id
        FROM PermissionSet
        WHERE Name = 'Case_Read_Write_Fraud_Agent'
      ];
      insert new PermissionSetAssignment(
        AssigneeId = fraudXAgent.id,
        PermissionSetId = ps.Id
      );

      // Sharing Case record manually with FraudX user, as Criteria Based Sharing Rules won't apply in Test Classes
      CaseShare cs = new CaseShare();
      cs.CaseId = generalEnquiryCase.id;
      cs.UserOrGroupId = fraudXAgent.Id;
      cs.CaseAccessLevel = 'Read';
      insert cs;
    }

    // Try to insert a Case Comment against a General Enquiry Case
    CaseComment comment = new CaseComment(
      CommentBody = 'Test Comment',
      ParentId = generalEnquiryCase.id
    );

    try {
      // Execute tests as a FraudX Agent
      System.runAs(fraudXAgent) {
        Test.startTest();

        insert comment;

        Test.stopTest();
      }
    } catch (DMLexception e) {
      system.assert(
        e.getMessage()
          .contains('You cannot add comments on this Case record type'),
        'FraudX Agents should not be allowed to add Case Comments on non Fraud Cases'
      );
    }
  }

  @istest
  static void testCaseCommentsInsertNonFraudXUser() {
    // Setting up test data
    User coachUser;
    Case generalEnquiryCase;

    // Insert Account, Case, & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      // Create an ANZx Customer
      Faker faker = new Faker('AU');
      Account acc = new Account(
        Name = 'Test 007 Account',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = true
      );
      insert acc;

      // Create a Case record to have a record type other than Fraud
      Id generalEnquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('General_Inquiry')
        .getRecordTypeId();
      generalEnquiryCase = new Case(
        RecordTypeId = generalEnquiryRecordTypeID,
        AccountId = acc.Id
      );
      insert generalEnquiryCase;

      // Create a non-Fraud User
      Profile profile = [
        SELECT Id
        FROM Profile
        WHERE Name = 'ANZx Standard User'
        LIMIT 1
      ];
      UserRole role = [SELECT Id FROM UserRole WHERE DeveloperName = 'Coach'];

      coachUser = (User) FakerFactory.make(new FakerUserFactory());
      coachUser.FirstName = 'Caoch';
      coachUser.ProfileId = profile.Id;
      coachUser.UserRoleId = role.Id;
      insert coachUser;

      // Assign Case related PS
      PermissionSet ps = [
        SELECT Id
        FROM PermissionSet
        WHERE Name = 'Case_Read_Write_Get_Help'
      ];
      insert new PermissionSetAssignment(
        AssigneeId = coachUser.id,
        PermissionSetId = ps.Id
      );

      // Sharing Case record manually with Coach user, as Criteria Based Sharing Rules won't apply in Test Classes
      CaseShare cs = new CaseShare();
      cs.CaseId = generalEnquiryCase.id;
      cs.UserOrGroupId = coachUser.Id;
      cs.CaseAccessLevel = 'Edit';
      insert cs;
    }

    // Try to insert a Case Comment against a General Enquiry Case
    CaseComment comment = new CaseComment(
      CommentBody = 'Test Comment 02',
      ParentId = generalEnquiryCase.id
    );

    // Execute tests as a Cuach User
    System.runAs(coachUser) {
      Test.startTest();

      insert comment;

      Test.stopTest();
    }

    System.assert(
      [
        SELECT COUNT()
        FROM CaseComment
        WHERE
          CommentBody = 'Test Comment 02'
          AND ParentId = :generalEnquiryCase.id
      ] > 0,
      'A non-fraud user was not able to add Case Comments on General Enquiry cases'
    );
  }
}
