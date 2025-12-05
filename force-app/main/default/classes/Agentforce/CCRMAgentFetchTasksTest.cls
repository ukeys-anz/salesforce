/**
 * @author       : Amisha Gyani
 * @since        : 2025
 * @description  : Test class for CCRMAgentFetchTasksTest invocable Apex class
 **/
@IsTest
private class CCRMAgentFetchTasksTest {
  static Lib_MockProvider taskRepoMock;

  static void registerMocks() {
    taskRepoMock = Lib_MockProvider.forType(TaskActionRepository.class);
  }

  /**
   * @description Positive test: Validate output JSON contains all open tasks
   */
  @IsTest
  static void testGetOpenTasksPositive() {
    registerMocks();

    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Task> openTasks = new List<Task>{
      new Task(
        Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
        Subject = 'Open Task 1',
        Status = 'Open',
        WhatId = accId,
        ActivityDate = Date.today().addDays(1),
        Priority = 'Normal',
        Description = 'First open task'
      ),
      new Task(
        Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
        Subject = 'Open Task 2',
        Status = 'Open',
        WhatId = accId,
        ActivityDate = Date.today().addDays(2),
        Priority = 'High',
        Description = 'Second open task'
      )
    };
    taskRepoMock.mock('getOpenTasks', openTasks);

    CCRMAgentFetchTasks.Request req = new CCRMAgentFetchTasks.Request();
    req.accountObj = new Account(Id = accId);

    Test.startTest();
    List<CCRMAgentFetchTasks.Response> result = CCRMAgentFetchTasks.getOpenTasks(
      new List<CCRMAgentFetchTasks.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, result.size(), 'Response wrapper must return 1 item.');
    Assert.isNotNull(
      result[0].promptResponse,
      'promptResponse should not be null.'
    );
    Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(
      result[0].promptResponse
    );
    List<Object> tasks = (List<Object>) parsed.get('OpenTasks');
    Assert.areEqual(2, tasks.size(), 'Should include 2 open tasks.');
  }

  /**
   * @description Negative test: No tasks found for the Account
   */
  @IsTest
  static void testGetOpenTasksNoTasks() {
    registerMocks();

    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    taskRepoMock.mock('getOpenTasks', new List<Task>());

    CCRMAgentFetchTasks.Request req = new CCRMAgentFetchTasks.Request();
    req.accountObj = new Account(Id = accId);

    Test.startTest();
    List<CCRMAgentFetchTasks.Response> result = CCRMAgentFetchTasks.getOpenTasks(
      new List<CCRMAgentFetchTasks.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(
      'No open tasks found for this Account.',
      result[0].promptResponse,
      'Should return message when no open tasks exist.'
    );
  }

  /**
   * @description Negative test: Null request or missing Account object
   */
  @IsTest
  static void testGetOpenTasksNullInput() {
    Test.startTest();
    List<CCRMAgentFetchTasks.Response> result = CCRMAgentFetchTasks.getOpenTasks(
      new List<CCRMAgentFetchTasks.Request>()
    );
    Test.stopTest();

    Assert.areEqual(
      'No Account data provided.',
      result[0].promptResponse,
      'Null or empty input should return error message.'
    );
  }
}
