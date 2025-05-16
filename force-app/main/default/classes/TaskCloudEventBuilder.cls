/**
 * @author Shivam
 * @since May 2025
 * @description Abstract class enforcing building cloud event models for the task records of different record types
 */
 @SuppressWarnings(
  'PMD.ExcessiveParameterList'
)
public interface TaskCloudEventBuilder {

   /**
   * @description Base Interface Cloud Event Models for Task
   * @param task Task record
   * @param account related Account record
   * @param aemContentData aem content data field value from CustomerTaskData
   * @param ownerModel related owner user
   * @return CustomerNudgeTaskCloudEventModel Task Cloud Event Model
   */

    CloudEventModel build(Task task, Account account, String aemContentData, CloudEventModel.UserModel ownerModel);

    Set<String> getSupportedRecordType();
}