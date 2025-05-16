/**
 * @author Shivam
 * @since  May 2025
 * @description Class to generate Cloud Event Model customer nudge tasks
 */

@SuppressWarnings(
  'PMD.ExcessiveParameterList'
)
public with sharing class CustomerNudgeTaskCEBuilder implements TaskCloudEventBuilder{

    /**
   * @description get Cloud Event Models for Task
   * @param task Task record
   * @param account related Account record
   * @param aemContentData aem content data field value from CustomerTaskData
   * @param ownerModel related owner user
   * @return CustomerNudgeTaskCloudEventModel Task Cloud Event Model
   */
    
    public CloudEventModel build (Task task, Account account, String aemContentData, CloudEventModel.UserModel ownerModel)
    {
        return new CustomerNudgeTaskCloudEventModel(task, account, aemContentData, ownerModel);
    }

    /**
   * @description get applicable recordtypes Models for Task CE Builder
   * @return Eligible Record Types
   */

    public Set<String> getSupportedRecordType()
    {
        return new Set<String> {'Customer_Nudge'};
    }
}