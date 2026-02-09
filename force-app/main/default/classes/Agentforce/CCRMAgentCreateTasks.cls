/**
 *
 * @author Amisha Gyani
 * @since 2025
 * @description CCRMAgentCreateTasks is an invocable Apex class that allows the creation of Task records
 *              from user-provided input data and returns the details of the created tasks.
 */
public with sharing class CCRMAgentCreateTasks {
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Wrapper class for input task details provided to the invocable method
   */
  public class TaskInput {
    @InvocableVariable(required=true)
    public String subject;

    @InvocableVariable(required=false)
    public Date dueDate;

    @InvocableVariable(required=false)
    public String description;

    @InvocableVariable(required=true)
    public String priority;

    @InvocableVariable(required=true)
    public Id acctRecordId;
  }

  /**
   * @description Wrapper class for output details of created tasks
   */
  public class TaskOutput {
    @InvocableVariable
    public Id taskId;

    @InvocableVariable
    public String subject;
  }

  /**
   * @description Invocable method to create Task records from a list of TaskInput and return their details
   * @param inputs List of TaskInput objects containing task details
   * @return List of Task sObjects ready for insertion
   */
  private static List<Task> buildTasksList(List<TaskInput> inputs) {
    List<Task> tasks = new List<Task>();
    for (TaskInput input : inputs) {
      Task t = new Task(
        Subject = input.subject,
        ActivityDate = input.dueDate,
        Description = input.description,
        Status = 'Open',
        AI_Generated__c = true,
        Priority = input.priority,
        WhatId = input.acctRecordId,
        RecordTypeId = RTTask.ccrmTask,
        OwnerId = new UserInfoRepository().getUser().Id
      );
      tasks.add(t);
    }
    return tasks;
  }
  /**
   * @description Helper method to map Task sObjects to TaskOutput wrapper objects
   * @param tasks List of Task sObjects
   * @return List of TaskOutput wrapper objects
   */

  private static List<TaskOutput> mapToOutputs(List<Task> tasks) {
    List<TaskOutput> outputs = new List<TaskOutput>();
    for (Task t : tasks) {
      TaskOutput output = new TaskOutput();
      output.taskId = t.Id;
      output.subject = t.Subject;
      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Invocable method to create Task records from a list of TaskInput and return their details
   * @param inputs List of TaskInput wrapper objects containing task details
   * @return List of TaskOutput wrapper objects containing the IDs and details of created tasks
   */
  @InvocableMethod(
    label='Agent Action to Create Tasks for Customer'
    description='Creates tasks from user-provided input data and returns their details.'
  )
  public static List<TaskOutput> createTasks(List<TaskInput> inputs) {
    List<Task> tasksToCreate = new List<Task>();
    List<TaskOutput> results = new List<TaskOutput>();
    try {
      tasksToCreate = buildTasksList(inputs);
      DML_REPO.doInsert(tasksToCreate);
      results = mapToOutputs(tasksToCreate);
    } catch (Exception error) {
      Logger.error('Task DML failed' + error.getMessage(), error);
      Logger.saveLog();
      throw new AuraHandledException(
        'An unexpected error occurred while creating tasks. Please contact your System Administrator.'
      );
    }
    return results;
  }
}
