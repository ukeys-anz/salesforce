/**
 * @author Kopal Goswami
 * @since  May 2025
 * @description Class to generate Cloud Event Model objects
 */
public with sharing class TaskCloudEventBuildHelper {
  /**
   * @description get Cloud Event Models for Task
   * @param theTask Task record
   * @param theAccount related Account record
   * @param aemContentData aem content data field value from CustomerTaskData
   * @param theOwner related owner user
   * @return CloudEventModel Task Cloud Event Model
   */
  public static CloudEventModel createCloudEvent(
    Task theTask,
    Account theAccount,
    String aemContentData,
    CloudEventModel.UserModel theOwner
  ) {
    CloudEventModel cloudEventModel;
    String taskRecordType = QueryRT.of(Task.SObjectType)
      .get(theTask.RecordTypeId)
      .getDeveloperName();
    switch on taskRecordType {
      when 'Customer_Nudge' {
        cloudEventModel = new CustomerNudgeTaskCloudEventModel(
          theTask,
          theAccount,
          aemContentData,
          theOwner
        );
        return cloudEventModel;
      }
    }
    return null;
  }
}
