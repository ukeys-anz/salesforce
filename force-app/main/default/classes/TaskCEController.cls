/**
 * @author Kopal Goswami
 * @since May 2025
 * @description Class to generate Cloud Event Model for Task object
 */
public without sharing class TaskCEController {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  /**
   * @description method to be called to publish cloud event for Task records
   * @param theTasks list of Task records
   */
  public static void publishCloudEvents(List<Task> theTasks) {
    if (theTasks.isEmpty()) {
      return;
    }
    List<CloudEventModel> cloudEventModels = generateCloudEventModel(theTasks);
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description generate Cloud Event Models for Task
   * @param taskRecords Task records
   * @return List<CloudEventModel> List of Task Cloud Event Model
   */
  public static List<CloudEventModel> generateCloudEventModel(
    List<Task> taskRecords
  ) {
    try {
      List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();

      Set<Id> accountIds = ListUtil.getIds(taskRecords, Task.AccountId);
      Set<Id> customerTaskDataIds = ListUtil.getIds(
        taskRecords,
        Task.Customer_Task_Data__c
      );
      Set<Id> taskIds = ListUtil.getIds(taskRecords, Task.Id);
      Set<Id> ownerIds = ListUtil.getIds(taskRecords, Task.OwnerId);

      List<Task> taskRecordsWithUpdatedValues = PUSH_TO_APP_REPOSITORY.queryTaskRecords(
        taskIds
      );
      Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
        PUSH_TO_APP_REPOSITORY.queryAccountDetails(accountIds)
      );
      Map<Id, Customer_Task_Data__c> customTaskDataIdAndInfoMap = new Map<Id, Customer_Task_Data__c>(
        PUSH_TO_APP_REPOSITORY.queryCustomerTaskDataDetails(customerTaskDataIds)
      );
      Map<Id, User> ownerUsers = new Map<Id, User>(
        PUSH_TO_APP_REPOSITORY.getUsers(ownerIds)
      );

      for (Task taskRec : taskRecordsWithUpdatedValues) {
        Account theAccount = accountIdToAccountInfoMap.containsKey(
            taskRec.AccountId
          )
          ? accountIdToAccountInfoMap.get(taskRec.AccountId)
          : null;
        String aemContentData = customTaskDataIdAndInfoMap.containsKey(
            taskRec.Customer_Task_Data__c
          )
          ? customTaskDataIdAndInfoMap.get(taskRec.Customer_Task_Data__c)
              .AEM_Content_Data__c
          : null;
        CloudEventModel.UserModel theOwner = CloudEventModel.getOwnerModel(
          taskRec.OwnerId,
          ownerUsers,
          QueryQueue.get(ownerIds)
        );
        cloudEventModels.add(
          TaskCloudEventBuildHelper.createCloudEvent(
            taskRec,
            theAccount,
            aemContentData,
            theOwner
          )
        );
      }
      return cloudEventModels;
    } catch (Exception objException) {
      throw CommonUtil.logExceptionWithMessage(
        'Cloud Event Model Creation for Task record failed ',
        objException
      );
    }
  }
}
