@isTest
private with sharing class IDRTaskSendNotificationTest {
  @isTest
  static void testSendNotificationToSystemicIssue() {
    Task tskObj = new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Status = IDRConstants.TASK_STATUS_COMPLETED,
      OwnerId = QueryQueue.get('Systemic_Issue_Team').Id,
      RecordTypeId = RTTask.idrSystemTask,
      Subject = IDRTaskActions.IDR_TASK_SUBJECT
    );

    Boolean exceptionThrown = false;
    String errorMessage = '';

    Test.startTest();
    try {
      IDRTaskSendNotification.sendNotifications(new List<Task>{ tskObj });
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    Assert.areEqual(
      false,
      exceptionThrown,
      'Systemic issue team should be notified'
    );
  }

  @isTest
  static void testSendNotificationToAdminRequest() {
    Task tskObj = new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Status = IDRConstants.TASK_STATUS_COMPLETED,
      OwnerId = QueryQueue.get('Admin_Requests').Id,
      RecordTypeId = RTTask.idrTask
    );

    Boolean exceptionThrown = false;
    String errorMessage = '';

    Test.startTest();
    try {
      IDRTaskSendNotification.sendNotifications(new List<Task>{ tskObj });
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    Assert.areEqual(
      false,
      exceptionThrown,
      'Admin Request team should be notified'
    );
  }
}
