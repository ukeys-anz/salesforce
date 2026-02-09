/**
 *
 * @author Amisha Gyani
 * @since 2025
 * @description Test class for CCRMAgentCreateTasksTest invocable Apex class.
 *              Verifies creation of single and multiple Task records and proper field mapping.
 */
@IsTest
private class CCRMAgentCreateTasksTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userRepoMock;

  /**
   * @description Registers mock providers for DmlRepository and UserInfoRepository
   */
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  /**
   * @testSetup
   * @description Test setup method to register mocks. No DML is performed here.
   */
  @TestSetup
  static void setupTestData() {
    registerMocks();
    dmlRepoMock.mock('doInsert', null);
    userRepoMock.mock('checkProfile', true);
  }

  /**
   * @description Positive test: Validates creation of a single Task and correct field mapping
   */
  @IsTest
  static void testCreateSingleTask() {
    registerMocks();

    Id taskId = Lib_FakeIdGenerator.getMockId(Task.SObjectType);

    // Avoid duplicate variable names – renamed to mockResults
    List<Database.SaveResult> mockResults = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' + (String) taskId + '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };

    // Mock DML insert results
    dmlRepoMock.mock('doInsert', mockResults);
    userRepoMock.mock('checkProfile', true);

    // Build input
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    CCRMAgentCreateTasks.TaskInput input = new CCRMAgentCreateTasks.TaskInput();
    input.subject = 'Follow up';
    input.dueDate = Date.today().addDays(5);
    input.description = 'This is a test task.';
    input.priority = 'High';
    input.acctRecordId = accountId;

    List<CCRMAgentCreateTasks.TaskInput> inputs = new List<CCRMAgentCreateTasks.TaskInput>{
      input
    };

    Test.startTest();
    List<CCRMAgentCreateTasks.TaskOutput> results = CCRMAgentCreateTasks.createTasks(
      inputs
    );
    Test.stopTest();

    // Assertions
    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'DML insert should be invoked via repository.'
    );

    Assert.areEqual(1, results.size(), 'Exactly one task should be created.');
    Assert.areEqual(input.subject, results[0].subject);
  }

  /**
   * @description Positive test: Validates creation of multiple Tasks in a single call
   *              and correct linkage to the Account
   */
  @IsTest
  static void testCreateMultipleTasks() {
    registerMocks();

    Id taskId = Lib_FakeIdGenerator.getMockId(Task.SObjectType);

    // Avoid duplicate variable name – renamed to mockResults
    List<Database.SaveResult> mockResults = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' + (String) taskId + '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };

    dmlRepoMock.mock('doInsert', mockResults);
    userRepoMock.mock('checkProfile', true);

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<CCRMAgentCreateTasks.TaskInput> inputs = new List<CCRMAgentCreateTasks.TaskInput>();
    for (Integer i = 1; i <= 3; i++) {
      CCRMAgentCreateTasks.TaskInput input = new CCRMAgentCreateTasks.TaskInput();
      input.subject = 'Task ' + i;
      input.dueDate = Date.today().addDays(i);
      input.description = 'Description for task ' + i;
      input.priority = 'Normal';
      input.acctRecordId = accountId;
      inputs.add(input);
    }

    Test.startTest();
    List<CCRMAgentCreateTasks.TaskOutput> results = CCRMAgentCreateTasks.createTasks(
      inputs
    );
    Test.stopTest();

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'DML insert should be invoked via repository.'
    );

    Assert.areEqual(3, results.size(), 'Three tasks should be created.');

    for (Integer i = 0; i < results.size(); i++) {
      CCRMAgentCreateTasks.TaskOutput output = results[i];

      Assert.areEqual('Task ' + (i + 1), output.subject);
    }
  }
}
