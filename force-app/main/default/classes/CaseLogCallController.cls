/**
 *
 * @author Stew Mikh (Co Auth: Mouhamed "Mo" Assafiri)
 * @since Aug 2021
 * @description Model for Custom Call Log LWC found within the Case Object View
 */

public with sharing class CaseLogCallController {
  /**
   * @description Creates the Task with the data presented
   * @param fields An Object with <String, String>, must include Subject, Auth, VoiceCall, Comment and RecordID
   * @return Task Returns the newly created Task as a Task Object
   */
  @AuraEnabled
  public static Task createTask(Map<String, String> fields) {
    try {
      String subject = fields.get('subject');
      String auth = fields.get('auth');
      String voiceCall = fields.get('voiceCall');
      String comment = fields.get('comment');
      String recordId = fields.get('recordId');
      Date dueDate = System.today();
      Task newTask = new Task(
        Subject = subject,
        Authentication_Method__c = auth,
        Voice_Call_SID__c = voiceCall,
        Description = comment,
        ActivityDate = dueDate,
        WhatId = recordId,
        Status = 'Completed',
        CallType = 'Inbound',
        RecordTypeId = getCaseRecordTypeIdByDeveloperName('Call_Log')
      );

      if (Task.sObjectType.getDescribe().isCreateable()) {
        insert newTask;
        return newTask;
      } else {
        throw new System.AuraHandledException(
          'Please check you have the permissions to create a Task on this Case'
        );
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
