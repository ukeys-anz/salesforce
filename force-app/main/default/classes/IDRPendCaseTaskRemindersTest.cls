/**
 * @author Adnan
 * @since  09/2021
 * @description Test class for Pend Case Task Reminders.
 */
@IsTest
public with sharing class IDRPendCaseTaskRemindersTest {
  @TestSetup
  static void setup() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'ANZ Standard User'
      LIMIT 1
    ];
    User contextUser = (User) FakerFactory.make(new FakerUserFactory());
    contextUser.FirstName = 'IDRPCTRContextUser';
    contextUser.ProfileId = profile.Id;
    insert contextUser;

    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE
        Name IN :new List<String>{
          'IDR_User',
          'IDR_User_Level_2',
          'IDR_User_Level_3'
        }
    ];
    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = contextUser.id,
        PermissionSetId = ps.Id
      );
      psaList.add(psa);
    }
    insert psaList;

    User contextUserManager = (User) FakerFactory.make(new FakerUserFactory());
    contextUserManager.FirstName = 'IDRPCTRContexmanager';
    contextUserManager.ProfileId = profile.Id;
    insert contextUserManager;
    List<PermissionSet> psListForManager = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'IDR_User'
    ];
    List<PermissionSetAssignment> psaListForManager = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psListForManager) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = contextUserManager.id,
        PermissionSetId = ps.Id
      );
      psaListForManager.add(psa);
    }
    insert psaListForManager;

    contextUser.ManagerId = contextUserManager.Id;
    update contextUser;
  }

  @IsTest
  static void taskRemindersTest() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IDRPCTRContextUser'
      LIMIT 1
    ];
    //Create a case complaint
    Case c = new Case(
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
      IDR_Customer_Number__c = '1234567890',
      Priority = 'Standard',
      Type = '5',
      IDR_Subsequent_Issue__c = '38',
      OwnerId = contextUser.Id
    );
    insert c;
    List<Case> createdCases = [
      SELECT Id, CaseNumber, OwnerId, Owner.Type
      FROM Case
      LIMIT 1
    ];

    //Create a task record and link above case with it
    Task t = new Task(
      RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
      Type = 'Pend Case',
      WhatId = createdCases[0].Id,
      Subject = 'Test task reminder notificaiton',
      Status = 'Open',
      OwnerId = contextUser.Id,
      ActivityDate = Date.today().addDays(3),
      IDR_Key_Contact_Name__c = 'Test KeyContact',
      IDR_Pended_To__c = 'Other',
      IDR_Pend_Reason__c = 'Awaiting information to be provided'
    );
    insert t;

    SchedulableContext sc = null;
    IDRPendCaseTaskRemindersScheduler schedule = new IDRPendCaseTaskRemindersScheduler();
    schedule.execute(sc);

    //Asserts
    //We cannot check if the notification is sent or not, hence verifying the wrapper if its properly built
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapper = IDRPendCaseTaskRemindersHandler.createWrapper(
      new List<Task>{ t }
    );
    System.assertEquals(
      pendCaseTaskWrapper.size() > 0,
      true,
      'Issue while creating wrapper and sending in app notification'
    );
  }

  @isTest
  static void taskReminderForManagersTest() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IDRPCTRContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      Case c = new Case(
        RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
        Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
        IDR_Customer_Number__c = '1234567890',
        Priority = 'Standard',
        Type = '5',
        IDR_Subsequent_Issue__c = '38',
        OwnerId = contextUser.Id
      );
      insert c;
    }

    List<Case> createdCases = [
      SELECT Id, CaseNumber, OwnerId, Owner.Type
      FROM Case
      LIMIT 1
    ];

    //Create a task record and link above case with it
    Task t = new Task(
      RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
      Type = 'Pend Case',
      WhatId = createdCases[0].Id,
      Subject = 'Test task reminder notificaiton',
      Status = 'Open',
      OwnerId = contextUser.Id,
      ActivityDate = Date.today().addDays(1),
      IDR_Key_Contact_Name__c = 'Test KeyContact',
      IDR_Pended_To__c = 'Other',
      IDR_Pend_Reason__c = 'Awaiting information to be provided'
    );
    insert t;

    SchedulableContext sc = null;
    IDRPendCaseTaskRemindersScheduler schedule = new IDRPendCaseTaskRemindersScheduler();
    schedule.execute(sc);

    //Asserts
    //We cannot check if the notification is sent or not, hence verifying the wrapper if its properly built
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapper = IDRPendCaseTaskRemindersHandler.createWrapper(
      new List<Task>{ t }
    );
    System.assertEquals(
      pendCaseTaskWrapper.size() > 0,
      true,
      'Issue while creating wrapper and sending in app notification'
    );
  }
}
