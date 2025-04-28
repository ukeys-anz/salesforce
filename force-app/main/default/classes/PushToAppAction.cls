/**
 * @author Kopal Goswami
 * @since April 2025
 * @description This class is used to perform Task DML operations on Customer action on Mobile App
 */
public with sharing class PushToAppAction {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  /**
   * @description this method is used to append TaskNumber field autonumber value to the Subject after creation and taskid into pubSubEventId
   * @param taskRecords list of Customer Nudge task records for which update to be done
   */
  public static void updateCustomerNudgeTask(List<Task> taskRecords) {
    try {
      List<Task> tasksToUpdate = new List<Task>();
      for (Task taskRec : taskRecords) {
        Task taskRecRef = new Task(Id = taskRec.Id);
        taskRecRef.Subject = taskRec.TaskNumber__c + ' - ' + taskRec.Subject;
        taskRecRef.Pub_Sub_Event_Id__c =
          taskRec.Pub_Sub_Event_Id__c +
          '_' +
          taskRec.Id;
        tasksToUpdate.add(taskRecRef);
      }
      DML_REPOSITORY.doUpdate(tasksToUpdate);
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description create task cloud event
   * @param taskRecords list of Customer Nudge task records
   * @param operationMode holds creation or updated operation
   */
  public static void createTaskCloudEvent(
    List<Task> taskRecords,
    String operationMode
  ) {
    Set<Id> accountIds = ListUtil.getIds(taskRecords, Task.AccountId);
    Set<Id> customerTaskDataIds = ListUtil.getIds(
      taskRecords,
      Task.Customer_Task_Data__c
    );

    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      PUSH_TO_APP_REPOSITORY.queryAccountOcvId(accountIds)
    );
    Map<Id, Customer_Task_Data__c> customTaskDataIdAndInfoMap = new Map<Id, Customer_Task_Data__c>(
      PUSH_TO_APP_REPOSITORY.queryCustomerTaskDataDetails(customerTaskDataIds)
    );

    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();

    for (Task taskRec : taskRecords) {
      String ocvId = accountIdToAccountInfoMap.containsKey(taskRec.AccountId)
        ? accountIdToAccountInfoMap.get(taskRec.AccountId).OCV_ID__c
        : null;
      String aemContentData = customTaskDataIdAndInfoMap.containsKey(
          taskRec.Customer_Task_Data__c
        )
        ? customTaskDataIdAndInfoMap.get(taskRec.Customer_Task_Data__c)
            .AEM_Content_Data__c
        : null;
      cloudEventModels.add(
        new CustomerNudgeTaskCloudEventModel(
          taskRec,
          operationMode,
          ocvId,
          aemContentData
        )
      );
    }

    CloudEventController.publishCloudEvents(cloudEventModels);
  }
}
