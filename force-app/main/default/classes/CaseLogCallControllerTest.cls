@isTest
public with sharing class CaseLogCallControllerTest {
  @isTest
  static void createTaskSuccessTest() {
    Map<String, String> fields = new Map<String, String>{
      'subject' => 'Call',
      'auth' => 'Non Customer Call',
      'voiceCall' => 'CF12121212121212121212121212121212',
      'comment' => 'Test'
    };

    Task newTask = CaseLogCallController.createTask(fields);
    Task findTask = [SELECT Id, Subject FROM Task WHERE Subject = 'Call'];

    System.assertEquals(newTask.Id, findTask.Id);
    System.assertEquals(newTask.Subject, 'Call');
  }

  @isTest
  static void createTaskFailTest() {
    try {
      Map<String, String> fields = new Map<String, String>{
        'subject' => 'Call',
        'auth' => 'Non Customer Call',
        'voiceCall' => 'FailTest',
        'comment' => 'Test'
      };

      Task tsk = CaseLogCallController.createTask(fields);

      System.assert(false, 'Task Creation Expected to fail');
    } catch (AuraHandledException e) {
      System.assertEquals(e.getMessage(), 'Script-thrown exception');
    }
  }
}
