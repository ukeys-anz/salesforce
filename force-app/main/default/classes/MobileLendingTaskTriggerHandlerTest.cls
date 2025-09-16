/*
 * @author Pragya Awasthi
 * @since  09/2025
 * @description MobileLendingTaskTriggerHandlerTest is the test class to cover tests for TaskTriggerHandler
 */
@isTest
public class MobileLendingTaskTriggerHandlerTest {
  /**
   * @description create test data
   * @return Task
   */
  static Task getTask() {
    return new Task(
      RecordTypeId = RTTask.mlcrmTask,
      ActivityDate = System.Today(),
      OwnerID = UserInfo.getUserID(),
      Description = 'A sample text with Passport12345678',
      Subject = 'A sample text with Passport12345678'
    );
  }

  @isTest
  static void testMaskingBeforeInsert() {
    //create task record
    Task newTask = getTask();

    Test.startTest();
    TaskTriggerHandler handler = new TaskTriggerHandler();
    handler.records = new List<Task>{ newTask };
    handler.onBeforeInsert();
    Test.stopTest();

    //assert
    Assert.areEqual(
      'A sample text with Passport****5678',
      newTask.Description,
      'Keyword entered in Description should be masked'
    );
    Assert.areEqual(
      'A sample text with Passport****5678',
      newTask.Subject,
      'Keyword entered in Subject should be masked'
    );
  }

  @isTest
  static void testMaskingBeforeUpdate() {
    //task record
    Task newTask = getTask();

    newTask.Description = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    newTask.Subject = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';

    //setting oldmap
    Map<Id, Task> oldMap = new Map<Id, Task>{ newTask.Id => newTask };

    Test.startTest();
    TaskTriggerHandler handler = new TaskTriggerHandler();
    handler.records = new List<Task>{ newTask };
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      newTask.Description,
      'Keyword entered in Description should be masked'
    );
    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      newTask.Subject,
      'Keyword entered in Subject should be masked'
    );
  }
}
