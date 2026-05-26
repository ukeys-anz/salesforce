/**
 * @author Shivam Swaraj
 * @since 04/2026
 * @description PushToAppConstant to store constants and mappings related to Push To App notifications
 * and task creation configurations. This class provides centralized management of task types,
 * subjects, and template-based configurations following the same pattern as FinancialAccountConstant.
 */
public with sharing class PushToAppConstant {
  /**
   * @description Map to store task type mapping based on template ID
   * Key: Template ID (from Customer_Task_Configuration__c)
   * Value: Task Type value
   */
  public static final Map<String, String> TEMPLATE_TO_TASK_TYPE = new Map<String, String>{
    'get_in_touch_complaint' => 'TASK_TYPE_PUSH_TO_APP',
    'get_in_touch_dispute' => 'TASK_TYPE_PUSH_TO_APP',
    'rescan_your_licence' => 'TASK_TYPE_ID_UPLOAD',
    'rescan_your_passport' => 'TASK_TYPE_ID_UPLOAD',
    'id_check_successful' => 'TASK_TYPE_ID_UPLOAD',
    'id_check_unsuccessful_licence' => 'TASK_TYPE_ID_UPLOAD',
    'id_check_unsuccessful_passport' => 'TASK_TYPE_ID_UPLOAD'
  };

  /**
   * @description Map to store task subject prefix mapping based on template ID
   * Key: Template ID (from Customer_Task_Configuration__c)
   * Value: Task Subject prefix
   */
  public static final Map<String, String> TEMPLATE_TO_TASK_SUBJECT = new Map<String, String>{
    'get_in_touch_complaint' => 'Push to App',
    'get_in_touch_dispute' => 'Push to App',
    'rescan_your_licence' => 'Id Upload',
    'rescan_your_passport' => 'Id Upload',
    'id_check_successful' => 'Id Upload',
    'id_check_unsuccessful_licence' => 'Id Upload',
    'id_check_unsuccessful_passport' => 'Id Upload'
  };

  /**
   * @description Default task type for Push To App notifications
   */
  public static final String PUSH_TO_APP_TASK_TYPE = 'TASK_TYPE_PUSH_TO_APP';

  /**
   * @description Default task type for ID upload customer nudge tasks
   */
  public static final String ID_UPLOAD_TASK_TYPE = 'TASK_TYPE_ID_UPLOAD';

  /**
   * @description Business Hours name used for calculating expiry dates
   */
  public static final String BUSINESS_HOURS_NAME = 'Case Business Hours';

  /**
   * @description Number of milliseconds in a day for date calculations
   */
  public static final Long MILLISECONDS_PER_DAY = 24L * 60L * 60L * 1000L;
}
