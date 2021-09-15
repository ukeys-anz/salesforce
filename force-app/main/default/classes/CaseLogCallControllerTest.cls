/**
 *
 * @author Mouhamed "Mo" Assafiri
 * @since 09/20201
 * @description Tests Log a call Apex code which powers the Log a Call LWC
 */

@isTest
public with sharing class CaseLogCallControllerTest {
  /**
   * @description createTaskSuccessTest tests creation of a call with a validate SID
   */
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

  /**
   * @description createTaskFailTest tests the validation to ensure SID is valid
   */
  @isTest
  static void createTaskFailTest() {
    try {
      Map<String, String> fields = new Map<String, String>{
        'subject' => 'Call',
        'auth' => 'Non Customer Call',
        'voiceCall' => '123',
        'comment' => 'Test'
      };

      // This should throw an error
      Task tsk = CaseLogCallController.createTask(fields);

      // If we get to here, the test has failed
      System.assert(false, 'Task Creation Expected to fail');
    } catch (AuraHandledException e) {
      System.assertEquals(e.getMessage(), 'Script-thrown exception');
    }
  }

  /**
   * @description createTaskFailEmptyTest tests if the Voicecall is empty
   */
  @isTest
  static void createTaskFailEmptyTest() {
    try {
      Map<String, String> fields = new Map<String, String>{
        'subject' => 'Call',
        'auth' => 'Non Customer Call',
        'voiceCall' => '',
        'comment' => 'Test'
      };

      // This should throw an error because the Voice SID is empty
      Task tsk = CaseLogCallController.createTask(fields);

      System.assert(
        false,
        'Task has an empty Voice ID and was expected to fail'
      );
    } catch (AuraHandledException e) {
      System.assertEquals(e.getMessage(), 'Script-thrown exception');
    }
  }
}
