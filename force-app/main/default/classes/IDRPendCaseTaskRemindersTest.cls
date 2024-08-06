/**
 * @author Adnan
 * @since  09/2021
 * @description Test class for Pend Case Task Reminders.
 */
@IsTest
public with sharing class IDRPendCaseTaskRemindersTest {
  static User setuser() {
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
      WHERE Name IN :new List<String>{ 'IDR_User' }
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
    return contextUser;
  }
  static User idrUser = setUser();
  static Case caseRecord1 = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = IDRConstants.ON_HOLD_STATUS,
      OwnerId = idrUser.Id
    ),
    new Map<String, List<SObject>>{
      'Tasks' => new List<Task>{
        new Task(
          Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
          Date_Case_on_Hold_From__c = Date.TODAY(),
          Status = IDRConstants.OPEN_STATUS,
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Type = IDRConstants.TASK_TYPE_PEND_CASE
        )
      }
    }
  );

  @IsTest
  static void taskRemindersTest() {
    Case testCase1 = caseRecord1;

    Task taskRecord = testCase1.Tasks[0];
    taskRecord.WhatId = testCase1.Id;

    SchedulableContext sc = null;
    IDRPendCaseTaskRemindersScheduler schedule = new IDRPendCaseTaskRemindersScheduler();
    schedule.execute(sc);

    //Asserts
    //We cannot check if the notification is sent or not, hence verifying the wrapper if its properly built
    List<IDRBankerNotificationWrapper> pendCaseTaskWrapper = IDRPendCaseTaskRemindersHandler.createWrapper(
      new List<Task>{ taskRecord }
    );
    System.assertEquals(
      pendCaseTaskWrapper.size() > 0,
      true,
      'Issue while creating wrapper and sending in app notification'
    );
  }
}
