/**
 * @author Kopal Goswami
 * @since April 2025
 * @description This class is used to perform Task DML operations on Customer action on Mobile App
 */
public with sharing class PushToAppAction {
  /**
   * @description create task cloud event
   * @param taskRecords list of Customer Nudge task records
   */
  public static void createTaskCloudEvent(List<Task> taskRecords) {
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();

    for (Task taskRec : taskRecords) {
      cloudEventModels.add(new CustomerNudgeTaskCloudEventModel(taskRec));
    }

    CloudEventController.publishCloudEvents(cloudEventModels);
  }
}
