/**
 * @author Kopal Goswami
 * @since May 2025
 * @description Class to generate Cloud Event Model for Task object
 */
public without sharing class TaskCEController {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  private static final Map<String, TaskCloudEventBuilder> BUILDER_REGISTRY = new Map<String, TaskCloudEventBuilder>();

  static
  {
    registerBuilder(new CustomerNudgeTaskCEBuilder());
    //Add any future record type builders here specific for the task record type
  }

  private static void registerBuilder(TaskCloudEventBuilder builder)
  {
    for(String recordType : builder.getSupportedRecordType())
    {
      BUILDER_REGISTRY.put(recordType, builder);
    }
  }

  /**
   * @description method to be called to publish cloud event for Task records
   * @param theTasks list of Task records
   */
  public static void publishCloudEvents(List<Task> inputTasks) {
    if (inputTasks.isEmpty()) {
      return;
    }

    Set<Id> taskIds = ListUtil.getIds(inputTasks, Task.Id);

    List<Task> enrichedTasks = PUSH_TO_APP_REPOSITORY.queryTaskRecords(
      taskIds
    );

    TaskCloudEventContext context = buildContext(inputTasks);

    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();

    for(Task task : enrichedTasks)
    {
      cloudEventModels.add(buildCloudEvent(task, context));
    }

    CloudEventController.publishCloudEvents(cloudEventModels);
  }


  private static TaskCloudEventContext buildContext(List<Task> tasks)
  {
    Set<Id> accountIds = ListUtil.getIds(tasks, Task.AccountId);
    Set<Id> customerTaskDataIds = ListUtil.getIds(
      tasks,
        Task.Customer_Task_Data__c
      );
    Set<Id> ownerIds = ListUtil.getIds(tasks, Task.OwnerId);

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
        PUSH_TO_APP_REPOSITORY.queryAccountDetails(accountIds)
      );
    Map<Id, Customer_Task_Data__c> customTaskDataIdAndInfoMap = new Map<Id, Customer_Task_Data__c>(
      PUSH_TO_APP_REPOSITORY.queryCustomerTaskDataDetails(customerTaskDataIds)
    );
    Map<Id, User> ownerUsers = new Map<Id, User>(
      PUSH_TO_APP_REPOSITORY.getUsers(ownerIds)
    );

    return new TaskCloudEventContext(
      accountIdToAccountInfoMap,
      customTaskDataIdAndInfoMap,
      ownerUsers
    );
  }

  private static CloudEventModel buildCloudEvent(Task task, TaskCloudEventContext context)
  {
    String taskRecordType = QueryRT.of(Schema.Task.SObjectType)
          .get(task.RecordTypeId)
          .getDeveloperName();

    TaskCloudEventBuilder builder = BUILDER_REGISTRY.get(taskRecordType);

    Account acc = context.accounts.get(task.AccountId);
    String aemData = context.taskData.get(task.Customer_Task_Data__c).AEM_Content_Data__c;

    CloudEventModel.UserModel ownerModel = CloudEventModel.getOwnerModel(
          task.OwnerId,
          context.owners,
          QueryQueue.getByIds(context.owners.keySet())
        );

        return builder.build(task, acc, aemData, ownerModel);
  }

  private class TaskCloudEventContext{
    public Map<Id, Account> accounts;
    public Map<Id, Customer_Task_Data__c> taskData;
    public Map<Id, User> owners;

    public TaskCloudEventContext(
    Map<Id, Account> accounts,
    Map<Id, Customer_Task_Data__c> taskData,
    Map<Id, User> owners)
    {
        this.accounts = accounts;
        this.taskData = taskData;
        this.owners = owners;
    }
  }
}