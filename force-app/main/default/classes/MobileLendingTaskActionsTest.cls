/*
 * @author Ashish Kumar
 * @since  11/2025
 * @description MobileLendingTaskActionsTest is the test class to cover tests for MobileLendingTaskActions
 */
@isTest
public class MobileLendingTaskActionsTest {

  @isTest
  static void testValidateActivityDate() {
    //create task record
    Id taskID = Lib_FakeIdGenerator.getMockId(Task.SObjectType);
    Task newTask = new Task(
      Id = taskID,
      RecordTypeId = RTTask.mlcrmTask,
      ActivityDate = Null,
      isRecurrence = false
    );
    Task oldTask = new Task(
      Id = taskID,
      RecordTypeId = RTTask.mlcrmTask,
      ActivityDate = System.Today().addDays(5),
      isRecurrence = false
    );

    Map<Id, Task> oldMap = new Map<Id, Task>{ taskID => oldTask };
    
    //validate Activity Date  
    Test.startTest();
    MobileLendingtTaskActions.validateActivityDate(
      new List<Task>{ newTask },
      oldMap
    );
    Test.stopTest();
    
    //Assert
    List<Database.Error> errors = newTask.getErrors();
    Database.Error error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'There is no error during Task updation');
    Assert.areEqual(
      'Due date cannot be blank.',
      error.getMessage(),
      'Task Activity updated successfully'
    );
  }
}