@isTest
private with sharing class IDRTaskActionsTest {
  @TestSetup
  static void testSetup() {
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Priority = 'Normal',
          Subject = '000001234',
          Description = 'Test description 1234-5678-9101 check mask'
        )
      );
    }
    insert newTasks;
  }

  @isTest
  static void testTaskFieldMasking() {
    //GIVEN tasks
    //WHEN they're inserted
    //THEN long numbers in free text fields are masked, showing only the last four digits
    Task t = [SELECT Subject, Description FROM Task LIMIT 1];
    System.assertEquals('*****1234', t.Subject, 'Subject should be masked.');
    System.assertEquals(
      'Test description ********9101 check mask',
      t.Description,
      'Description should be masked.'
    );
    //AND WHEN updated
    t.Subject = '987654321';
    update t;
    //THEN long numbers in free text fields are masked, showing only the last four digits
    t = [SELECT Subject FROM Task LIMIT 1];
    System.assertEquals('*****4321', t.Subject, 'Subject should be masked.');
  }
}
